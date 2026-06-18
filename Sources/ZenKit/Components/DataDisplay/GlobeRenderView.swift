import SwiftUI
import simd

#if canImport(MetalKit)
import MetalKit

/// Uniform block handed to `ZenGlobe.metal`. Field order and `simd` types mirror the
/// `GlobeUniforms` struct in the shader exactly (all `float4`, 16-byte aligned).
struct GlobeUniforms {
    var resolutionOffset = simd_float4(0, 0, 0, 0) // (resX, resY, offsetX, offsetY)
    var rotationDotsScale = simd_float4(0, 0, 16000, 1) // (phi, theta, dots, scale)
    var baseColor = simd_float4(0.3, 0.3, 0.3, 0)
    var glowColor = simd_float4(1, 1, 1, 0)
    var renderParams = simd_float4(6, 1.2, 0, 1) // (mapBrightness, diffuse, dark, opacity)
    var misc = simd_float4(0, 0, 0, 0) // (mapBaseBrightness, _, _, _)
    var dotColor = simd_float4(0.3, 0.3, 0.3, 0) // land-dot color (r, g, b, _)
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

    private var velocityPhi = 0.0
    private var velocityTheta = 0.0
    private var isDragging = false
    private var lastTranslation = CGSize.zero

    private static let thetaLimit = Double.pi / 2 - 0.05

    /// Advance one frame. Called by the renderer's `draw(in:)`.
    func advance() {
        guard !isDragging else { return }
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

/// Renders a single cobe-style globe into a transparent `MTKView`. One draw call per frame:
/// a full-screen quad shaded entirely in the fragment program. The render loop advances
/// `motion` each frame so the globe spins even when SwiftUI isn't re-evaluating.
final class GlobeRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    private let queue: MTLCommandQueue
    private var pipeline: MTLRenderPipelineState?
    private var quadBuffer: MTLBuffer?
    private var texture: MTLTexture?
    private var sampler: MTLSamplerState?

    /// Static config (colors, dots, brightness…). Rotation is overwritten from `motion`.
    var uniforms = GlobeUniforms()
    var motion = GlobeMotion()
    /// Backing-store size in pixels (drawableSize). Used to fill `resolution`.
    private var drawableSize = CGSize(width: 1, height: 1)

    init?(device: MTLDevice) {
        guard let queue = device.makeCommandQueue() else { return nil }
        self.device = device
        self.queue = queue
        super.init()
        guard buildPipeline(), buildResources() else { return nil }
    }

    private func buildPipeline() -> Bool {
        guard let library = try? device.makeLibrary(source: ZenGlobeShader.source, options: nil),
              let vfn = library.makeFunction(name: "zenGlobeVertex"),
              let ffn = library.makeFunction(name: "zenGlobeFragment") else { return false }

        let desc = MTLRenderPipelineDescriptor()
        desc.vertexFunction = vfn
        desc.fragmentFunction = ffn
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

        pipeline = try? device.makeRenderPipelineState(descriptor: desc)
        return pipeline != nil
    }

    private func buildResources() -> Bool {
        // Two triangles covering clip space.
        let quad: [simd_float2] = [
            simd_float2(-1, -1), simd_float2(1, -1), simd_float2(-1, 1),
            simd_float2(-1, 1), simd_float2(1, -1), simd_float2(1, 1),
        ]
        quadBuffer = device.makeBuffer(bytes: quad,
                                       length: MemoryLayout<simd_float2>.stride * quad.count,
                                       options: [])

        let loader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
        ]
        texture = try? loader.newTexture(data: ZenGlobeMap.pngData, options: options)

        let sd = MTLSamplerDescriptor()
        sd.minFilter = .linear
        sd.magFilter = .linear
        sd.sAddressMode = .repeat
        sd.tAddressMode = .repeat
        sampler = device.makeSamplerState(descriptor: sd)

        return quadBuffer != nil && texture != nil && sampler != nil
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        drawableSize = size
    }

    func draw(in view: MTKView) {
        guard let pipeline, let quadBuffer, let texture, let sampler,
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let cmd = queue.makeCommandBuffer(),
              let encoder = cmd.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        motion.advance()

        var u = uniforms
        u.resolutionOffset.x = Float(drawableSize.width)
        u.resolutionOffset.y = Float(drawableSize.height)
        u.rotationDotsScale.x = Float(motion.phi)
        u.rotationDotsScale.y = Float(motion.theta)

        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(quadBuffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&u, length: MemoryLayout<GlobeUniforms>.stride, index: 0)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
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
        renderer?.uniforms = uniforms
        renderer?.motion = motion
        motion.autoRotate = autoRotate
        motion.rotationSpeed = rotationSpeed
        motion.reduceMotion = reduceMotion
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
