import SwiftUI
import simd

#if canImport(MetalKit)
import MetalKit

/// Uniform block handed to the globe fragment program. Field order and `simd` types mirror the
/// `GlobeUniforms` struct in the shader exactly (all `float4`, 16-byte aligned).
struct GlobeUniforms {
    var resolutionOffset = simd_float4(0, 0, 0, 0) // (resX, resY, offsetX, offsetY)
    var rotationDotsScale = simd_float4(0, 0, 16000, 1) // (phi, theta, dots, scale)
    var baseColor = simd_float4(0.3, 0.3, 0.3, 0)
    var glowColor = simd_float4(1, 1, 1, 0)
    var renderParams = simd_float4(6, 1.2, 0, 1) // (mapBrightness, diffuse, dark, opacity)
    var misc = simd_float4(0, 0, 0, 0) // (mapBaseBrightness, _, _, _)
    var dotColor = simd_float4(0.3, 0.3, 0.3, 0) // land-dot color (r, g, b, _)
    var selection = simd_float4(0, 0, 0, -1) // selected-country highlight (r, g, b, index; -1 = none)
}

/// Mirrors the shader's `MarkerUniforms` (color first keeps the 16-byte alignment trivial).
struct MarkerUniforms {
    var markerColor = simd_float4(1, 0.5, 0, 0)
    var resolution = simd_float2(1, 1)
    var offset = simd_float2(0, 0)
    var phiTheta = simd_float2(0, 0)
    var scale: Float = 1
    var markerElevation: Float = 0
}

/// Mirrors the shader's `ArcUniforms`.
struct ArcUniforms {
    var arcColor = simd_float4(0.3, 0.6, 1, 0)
    var resolution = simd_float2(1, 1)
    var offset = simd_float2(0, 0)
    var phiTheta = simd_float2(0, 0)
    var scale: Float = 1
    var markerElevation: Float = 0
}

/// Holds the live rotation that both the drag gesture (writes) and the render loop
/// (advances) share. The render loop is the animation clock — matching cobe's `onRender`
/// model — so this is a plain reference type, not observable.
final class GlobeMotion {
    var phi: Double = 0
    var theta: Double = 0.3
    var autoRotate = true
    /// Radians per rendered frame (cobe's per-frame increment).
    var rotationSpeed = 0.005
    var reduceMotion = false
    /// One-shot guard so the caller's initial `phi`/`theta` are applied exactly once.
    var didInit = false
    /// Per-frame hook (cobe's `onRender`). Called after auto-rotate/drag advance the rotation,
    /// so a consumer can override `phi`/`theta` — e.g. to spin toward a location.
    var onRender: ((GlobeMotion) -> Void)?
    /// When set, `advance()` eases `phi`/`theta` toward this rotation (a "fly to"), clearing it
    /// on arrival. Auto-rotate and inertia pause during the flight.
    var flyTarget: (phi: Double, theta: Double)?

    private var velocityPhi = 0.0
    private var velocityTheta = 0.0
    private var isDragging = false
    private var lastTranslation = CGSize.zero

    private static let thetaLimit = Double.pi / 2 - 0.05

    /// Advance one frame. Called by the renderer's `draw(in:)`.
    func advance() {
        guard !isDragging else { return }

        // Fly-to easing takes priority over auto-rotate/inertia until it arrives.
        if let t = flyTarget {
            let dPhi = atan2(sin(t.phi - phi), cos(t.phi - phi)) // shortest angular path
            let dTheta = t.theta - theta
            phi += dPhi * 0.12
            theta = min(max(theta + dTheta * 0.12, -Self.thetaLimit), Self.thetaLimit)
            if abs(dPhi) < 0.003 && abs(dTheta) < 0.003 { flyTarget = nil }
            return
        }

        if autoRotate && !reduceMotion { phi += rotationSpeed }
        if !reduceMotion {
            phi += velocityPhi
            theta += velocityTheta
            velocityPhi *= 0.92
            velocityTheta *= 0.92
            if abs(velocityPhi) < 1e-5 { velocityPhi = 0 }
            if abs(velocityTheta) < 1e-5 { velocityTheta = 0 }
        }
        theta = min(max(theta, -Self.thetaLimit), Self.thetaLimit)
    }

    func dragChanged(_ translation: CGSize) {
        isDragging = true
        flyTarget = nil // a manual drag cancels any in-progress fly-to
        let dPhi = Double(translation.width - lastTranslation.width) / 300
        let dTheta = Double(translation.height - lastTranslation.height) / 1000
        phi += dPhi
        theta = min(max(theta - dTheta, -Self.thetaLimit), Self.thetaLimit)
        velocityPhi = dPhi
        velocityTheta = -dTheta
        lastTranslation = translation
    }

    func dragEnded() {
        isDragging = false
        lastTranslation = .zero
    }
}

/// Renders a cobe-style globe into a transparent `MTKView` in three passes per frame —
/// globe (full-screen quad), arcs (instanced Bézier ribbons), markers (instanced quads) —
/// all in one render encoder so they share the globe's rotation and occlude correctly.
final class GlobeRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    private let queue: MTLCommandQueue
    private var globePipeline: MTLRenderPipelineState?
    private var markerPipeline: MTLRenderPipelineState?
    private var arcPipeline: MTLRenderPipelineState?
    private var quadBuffer: MTLBuffer?
    private var arcSegmentBuffer: MTLBuffer?
    private var markerInstanceBuffer: MTLBuffer?
    private var arcInstanceBuffer: MTLBuffer?
    private var markerCount = 0
    private var arcCount = 0
    private var texture: MTLTexture?
    private var countryTexture: MTLTexture?
    private var sampler: MTLSamplerState?

    /// Static config (colors, dots, brightness…). Rotation is overwritten from `motion`.
    var uniforms = GlobeUniforms()
    var motion = GlobeMotion()
    /// Initial rotation, applied once via `motion.didInit`.
    var initialPhi: Double = 0
    var initialTheta: Double = 0.3
    /// Marker/arc render params not carried in `GlobeUniforms`.
    var markerColor = simd_float3(1, 0.5, 0)
    var arcColor = simd_float3(0.3, 0.6, 1)
    var markerElevation: Float = 0
    /// Pan offset in points (logical). Converted to pixels per frame using the view's scale.
    var offset = simd_float2(0, 0)

    /// Backing-store size in pixels (drawableSize). Used to fill `resolution`.
    private var drawableSize = CGSize(width: 1, height: 1)
    private static let arcSegmentCount = 66 // (32 + 1) * 2

    init?(device: MTLDevice) {
        guard let queue = device.makeCommandQueue() else { return nil }
        self.device = device
        self.queue = queue
        super.init()
        guard buildPipelines(), buildResources() else { return nil }
    }

    private func buildPipelines() -> Bool {
        guard let library = try? device.makeLibrary(source: ZenGlobeShader.source, options: nil)
        else { return false }

        func pipeline(_ vfn: String, _ ffn: String) -> MTLRenderPipelineState? {
            guard let v = library.makeFunction(name: vfn),
                  let f = library.makeFunction(name: ffn) else { return nil }
            let desc = MTLRenderPipelineDescriptor()
            desc.vertexFunction = v
            desc.fragmentFunction = f
            let color = desc.colorAttachments[0]!
            color.pixelFormat = .bgra8Unorm
            // Straight (non-premultiplied) alpha blending, matching cobe's GL setup.
            color.isBlendingEnabled = true
            color.rgbBlendOperation = .add
            color.alphaBlendOperation = .add
            color.sourceRGBBlendFactor = .sourceAlpha
            color.sourceAlphaBlendFactor = .sourceAlpha
            color.destinationRGBBlendFactor = .oneMinusSourceAlpha
            color.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            return try? device.makeRenderPipelineState(descriptor: desc)
        }

        globePipeline = pipeline("zenGlobeVertex", "zenGlobeFragment")
        markerPipeline = pipeline("zenMarkerVertex", "zenMarkerFragment")
        arcPipeline = pipeline("zenArcVertex", "zenArcFragment")
        return globePipeline != nil && markerPipeline != nil && arcPipeline != nil
    }

    private func buildResources() -> Bool {
        // Two triangles covering clip space (also reused as the marker quad).
        let quad: [simd_float2] = [
            simd_float2(-1, -1), simd_float2(1, -1), simd_float2(-1, 1),
            simd_float2(-1, 1), simd_float2(1, -1), simd_float2(1, 1),
        ]
        quadBuffer = device.makeBuffer(bytes: quad,
                                       length: MemoryLayout<simd_float2>.stride * quad.count,
                                       options: [])

        // Arc ribbon: (t, side) pairs along the curve, drawn as a triangle strip.
        var segs: [simd_float2] = []
        for i in 0...32 {
            let t = Float(i) / 32
            segs.append(simd_float2(t, -1))
            segs.append(simd_float2(t, 1))
        }
        arcSegmentBuffer = device.makeBuffer(bytes: segs,
                                             length: MemoryLayout<simd_float2>.stride * segs.count,
                                             options: [])

        let loader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
        ]
        texture = try? loader.newTexture(data: ZenGlobeMap.pngData, options: options)
        countryTexture = try? loader.newTexture(data: ZenGlobeCountryMap.pngData, options: options)

        let sd = MTLSamplerDescriptor()
        sd.minFilter = .linear
        sd.magFilter = .linear
        sd.sAddressMode = .repeat
        sd.tAddressMode = .repeat
        sampler = device.makeSamplerState(descriptor: sd)

        return quadBuffer != nil && arcSegmentBuffer != nil && texture != nil && sampler != nil
    }

    /// Upload marker instance data (8 floats each: dir.xyz, size, color.rgb, hasColor).
    func setMarkerData(_ data: [Float]) {
        markerCount = data.count / 8
        guard markerCount > 0 else { markerInstanceBuffer = nil; return }
        markerInstanceBuffer = device.makeBuffer(bytes: data,
                                                 length: MemoryLayout<Float>.stride * data.count,
                                                 options: [])
    }

    /// Upload arc instance data (12 floats each: from.xyz, to.xyz, height, width, color.rgb, hasColor).
    func setArcData(_ data: [Float]) {
        arcCount = data.count / 12
        guard arcCount > 0 else { arcInstanceBuffer = nil; return }
        arcInstanceBuffer = device.makeBuffer(bytes: data,
                                              length: MemoryLayout<Float>.stride * data.count,
                                              options: [])
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        drawableSize = size
    }

    func draw(in view: MTKView) {
        guard let globePipeline, let quadBuffer, let texture, let sampler,
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let cmd = queue.makeCommandBuffer(),
              let encoder = cmd.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        motion.advance()
        motion.onRender?(motion)

        let res = simd_float2(Float(drawableSize.width), Float(drawableSize.height))
        let contentScale = Float(drawableSize.width / max(view.bounds.width, 1))
        let offsetPx = offset * contentScale
        let phiTheta = simd_float2(Float(motion.phi), Float(motion.theta))

        // === Pass 1: Globe ===
        var u = uniforms
        u.resolutionOffset = simd_float4(res.x, res.y, offsetPx.x, offsetPx.y)
        u.rotationDotsScale.x = phiTheta.x
        u.rotationDotsScale.y = phiTheta.y
        let scaleVal = u.rotationDotsScale.w

        encoder.setRenderPipelineState(globePipeline)
        encoder.setVertexBuffer(quadBuffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&u, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentTexture(countryTexture, index: 1)
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        // === Pass 2: Arcs ===
        if arcCount > 0, let arcPipeline, let arcInstanceBuffer, let arcSegmentBuffer {
            var au = ArcUniforms()
            au.arcColor = simd_float4(arcColor.x, arcColor.y, arcColor.z, 0)
            au.resolution = res
            au.offset = offsetPx
            au.phiTheta = phiTheta
            au.scale = scaleVal
            au.markerElevation = markerElevation

            encoder.setRenderPipelineState(arcPipeline)
            encoder.setVertexBuffer(arcSegmentBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(arcInstanceBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&au, length: MemoryLayout<ArcUniforms>.stride, index: 2)
            encoder.setFragmentBytes(&au, length: MemoryLayout<ArcUniforms>.stride, index: 0)
            encoder.drawPrimitives(type: .triangleStrip,
                                   vertexStart: 0,
                                   vertexCount: Self.arcSegmentCount,
                                   instanceCount: arcCount)
        }

        // === Pass 3: Markers ===
        if markerCount > 0, let markerPipeline, let markerInstanceBuffer {
            var mu = MarkerUniforms()
            mu.markerColor = simd_float4(markerColor.x, markerColor.y, markerColor.z, 0)
            mu.resolution = res
            mu.offset = offsetPx
            mu.phiTheta = phiTheta
            mu.scale = scaleVal
            mu.markerElevation = markerElevation

            encoder.setRenderPipelineState(markerPipeline)
            encoder.setVertexBuffer(quadBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(markerInstanceBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&mu, length: MemoryLayout<MarkerUniforms>.stride, index: 2)
            encoder.setFragmentBytes(&mu, length: MemoryLayout<MarkerUniforms>.stride, index: 0)
            encoder.drawPrimitives(type: .triangle,
                                   vertexStart: 0,
                                   vertexCount: 6,
                                   instanceCount: markerCount)
        }

        encoder.endEncoding()
        cmd.present(drawable)
        cmd.commit()
    }
}

/// SwiftUI bridge for `GlobeRenderer`'s `MTKView`. The view renders continuously at 60fps;
/// the render loop advances `motion`, so the globe spins without SwiftUI re-evaluating.
/// `updateUIView` only pushes the latest static config (colors, brightness, motion settings).
struct GlobeRenderView {
    var uniforms: GlobeUniforms
    var motion: GlobeMotion
    var autoRotate: Bool
    var rotationSpeed: Double
    var reduceMotion: Bool
    var initialPhi: Double
    var initialTheta: Double
    var markerColor: simd_float3
    var arcColor: simd_float3
    var markerElevation: Float
    var offset: simd_float2
    var markerData: [Float]
    var arcData: [Float]
    var onRender: ((GlobeMotion) -> Void)?

    private func makeMTKView(coordinator renderer: GlobeRenderer?) -> MTKView {
        let view = MTKView()
        view.device = renderer?.device ?? MTLCreateSystemDefaultDevice()
        view.delegate = renderer
        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = true
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        #if canImport(UIKit)
        view.isOpaque = false
        view.backgroundColor = .clear
        #elseif canImport(AppKit)
        view.layer?.isOpaque = false
        #endif
        return view
    }

    private func sync(_ renderer: GlobeRenderer?) {
        guard let renderer else { return }
        renderer.uniforms = uniforms
        renderer.motion = motion
        motion.autoRotate = autoRotate
        motion.rotationSpeed = rotationSpeed
        motion.reduceMotion = reduceMotion
        motion.onRender = onRender
        if !motion.didInit {
            motion.phi = initialPhi
            motion.theta = initialTheta
            motion.didInit = true
        }
        renderer.markerColor = markerColor
        renderer.arcColor = arcColor
        renderer.markerElevation = markerElevation
        renderer.offset = offset
        renderer.setMarkerData(markerData)
        renderer.setArcData(arcData)
    }

    func makeCoordinator() -> GlobeRenderer? {
        let renderer = MTLCreateSystemDefaultDevice().flatMap { GlobeRenderer(device: $0) }
        renderer?.motion = motion
        return renderer
    }
}

#if canImport(UIKit)
extension GlobeRenderView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView { makeMTKView(coordinator: context.coordinator) }
    func updateUIView(_ view: MTKView, context: Context) { sync(context.coordinator) }
}
#elseif canImport(AppKit)
extension GlobeRenderView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView { makeMTKView(coordinator: context.coordinator) }
    func updateNSView(_ view: MTKView, context: Context) { sync(context.coordinator) }
}
#endif

#endif // canImport(MetalKit)
