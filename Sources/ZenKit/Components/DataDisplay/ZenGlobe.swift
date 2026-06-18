import SwiftUI
import simd

/// A marker pinned to a latitude/longitude on a ``ZenGlobe``.
public struct ZenGlobeMarker: Identifiable {
    public let id: UUID
    /// Geographic location in degrees.
    public let latitude: Double
    public let longitude: Double
    /// Marker diameter as a fraction of the globe's on-screen size (cobe-style, ~0.02–0.1).
    public let size: Double
    /// Marker fill; falls back to the globe's `markerColor` when nil.
    public let color: Color?

    public init(
        latitude: Double,
        longitude: Double,
        size: Double = 0.04,
        color: Color? = nil
    ) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.size = size
        self.color = color
    }
}

/// An interactive, auto-rotating dotted globe — a native Metal reimplementation of the
/// [cobe](https://github.com/shuding/cobe) WebGL globe. Continents emerge as bright dot
/// clusters on a glowing sphere; drag to spin, and pin markers at lat/lon coordinates.
///
/// The globe respects Reduce Motion (it stops auto-rotating but stays draggable) and renders
/// transparently, so it composes over any background.
///
/// ```swift
/// ZenGlobe(markers: [
///     ZenGlobeMarker(latitude: 37.7595, longitude: -122.4367, size: 0.05),
///     ZenGlobeMarker(latitude: 40.7128, longitude: -74.006, size: 0.07, color: .red),
/// ])
/// .frame(width: 300, height: 300)
/// ```
public struct ZenGlobe: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let markers: [ZenGlobeMarker]
    private let autoRotate: Bool
    private let rotationSpeed: Double
    private let dark: Double?
    private let diffuse: Double
    private let mapBrightness: Double
    private let mapBaseBrightness: Double
    private let mapSamples: Int
    private let scale: Double
    private let baseColor: Color?
    private let dotColor: Color?
    private let glowColor: Color?
    private let markerColor: Color

    /// - Parameters:
    ///   - markers: Points to pin on the globe.
    ///   - autoRotate: Continuously spin the globe (ignored when Reduce Motion is on).
    ///   - rotationSpeed: Auto-rotation increment in radians per frame.
    ///   - dark: 0 = light globe (pale sphere, tinted land dots), 1 = dark globe with glowing
    ///     land. Values in-between blend. Defaults to the current color scheme (light → 0, dark → 1).
    ///   - diffuse: Lighting falloff exponent toward the silhouette (higher = sharper).
    ///   - mapBrightness: Brightness multiplier for land dots.
    ///   - mapBaseBrightness: Floor brightness for ocean dots (>0 makes oceans faintly visible).
    ///   - mapSamples: Number of dots on the sphere (more = finer continents).
    ///   - scale: Zoom of the sphere within its frame.
    ///   - baseColor: Sphere body color (the "ocean"). Defaults to a theme-appropriate pale fill.
    ///   - dotColor: Land-dot color. Defaults to a soft blue.
    ///   - glowColor: Halo / rim-glow color. Defaults to a theme-appropriate glow.
    ///   - markerColor: Default marker fill.
    public init(
        markers: [ZenGlobeMarker] = [],
        autoRotate: Bool = true,
        rotationSpeed: Double = 0.005,
        dark: Double? = nil,
        diffuse: Double = 1.2,
        mapBrightness: Double = 6,
        mapBaseBrightness: Double = 0,
        mapSamples: Int = 16000,
        scale: Double = 1,
        baseColor: Color? = nil,
        dotColor: Color? = nil,
        glowColor: Color? = nil,
        markerColor: Color = .zenAccent
    ) {
        self.markers = markers
        self.autoRotate = autoRotate
        self.rotationSpeed = rotationSpeed
        self.dark = dark
        self.diffuse = diffuse
        self.mapBrightness = mapBrightness
        self.mapBaseBrightness = mapBaseBrightness
        self.mapSamples = mapSamples
        self.scale = scale
        self.baseColor = baseColor
        self.dotColor = dotColor
        self.glowColor = glowColor
        self.markerColor = markerColor
    }

    #if canImport(MetalKit)
    @State private var motion = GlobeMotion()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                GlobeRenderView(
                    uniforms: uniforms,
                    motion: motion,
                    autoRotate: autoRotate,
                    rotationSpeed: rotationSpeed,
                    reduceMotion: reduceMotion
                )

                if !markers.isEmpty {
                    TimelineView(.animation) { _ in
                        markerLayer(in: geo.size)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { motion.dragChanged($0.translation) }
                    .onEnded { _ in motion.dragEnded() }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var uniforms: GlobeUniforms {
        let isDark = colorScheme == .dark
        // Default to the light "pale sphere" look in light mode and the glowing-land globe in dark.
        let resolvedDark = dark ?? (isDark ? 1.0 : 0.0)
        let sphere = baseColor ?? (isDark ? Color(red: 0.10, green: 0.12, blue: 0.16) : .white)
        let land = dotColor ?? Color(red: 0.42, green: 0.50, blue: 0.85) // soft periwinkle blue
        let glow = glowColor ?? (isDark ? Color(red: 0.30, green: 0.42, blue: 0.78) : .white)

        var u = GlobeUniforms()
        u.rotationDotsScale = simd_float4(0, 0, Float(mapSamples), Float(scale))
        let base = sphere.zenGlobeRGB(colorScheme)
        let dot = land.zenGlobeRGB(colorScheme)
        let glowRGB = glow.zenGlobeRGB(colorScheme)
        u.baseColor = simd_float4(base.x, base.y, base.z, 0)
        u.dotColor = simd_float4(dot.x, dot.y, dot.z, 0)
        u.glowColor = simd_float4(glowRGB.x, glowRGB.y, glowRGB.z, 0)
        u.renderParams = simd_float4(Float(mapBrightness), Float(diffuse), Float(resolvedDark), 1)
        u.misc = simd_float4(Float(mapBaseBrightness), 0, 0, 0)
        return u
    }

    @ViewBuilder
    private func markerLayer(in size: CGSize) -> some View {
        let resolved = markerColor
        ForEach(markers) { marker in
            let p = project(marker, in: size)
            if p.visible {
                Circle()
                    .fill(marker.color ?? resolved)
                    .frame(width: p.diameter, height: p.diameter)
                    .position(p.point)
                    .opacity(p.opacity)
                    .allowsHitTesting(false)
            }
        }
    }

    /// Port of cobe's `latLonTo3D` + `applyRotation` + `project` (src/index.js).
    private func project(_ marker: ZenGlobeMarker, in size: CGSize)
        -> (point: CGPoint, visible: Bool, opacity: Double, diameter: CGFloat) {
        let elevation = 0.02
        let r = 0.8 + elevation

        let latRad = marker.latitude * .pi / 180
        let lonRad = marker.longitude * .pi / 180 - .pi
        let cosLat = cos(latRad)
        let px = -cosLat * cos(lonRad) * r
        let py = sin(latRad) * r
        let pz = cosLat * sin(lonRad) * r

        let phi = motion.phi
        let theta = motion.theta
        let cx = cos(theta), cy = cos(phi), sx = sin(theta), sy = sin(phi)
        let rx = cy * px + sy * pz
        let ry = sy * sx * px + cx * py - cy * sx * pz
        let rz = -sy * cx * px + sx * py + cy * cx * pz

        let aspect = size.height > 0 ? size.width / size.height : 1
        let nx = ((rx / aspect) * scale + 1) / 2
        let ny = (-ry * scale + 1) / 2
        let visible = rz >= 0 || (rx * rx + ry * ry) >= 0.64

        let depth = max(0, min(1, (rz + 1) / 2))
        let diameter = CGFloat(marker.size) * min(size.width, size.height)
        return (
            CGPoint(x: nx * size.width, y: ny * size.height),
            visible,
            0.5 + 0.5 * depth,
            diameter
        )
    }
    #else
    public var body: some View {
        Color.clear.aspectRatio(1, contentMode: .fit)
    }
    #endif
}

#if canImport(MetalKit)
private extension Color {
    /// sRGB components (0–1) for handing to the Metal shader. cobe consumes plain RGB triples.
    ///
    /// Resolves dynamic (theme-aware) colors against the view's actual `colorScheme` rather than
    /// the ambient `UITraitCollection.current`, which during SwiftUI view evaluation often doesn't
    /// match — that mismatch pinned the globe to one appearance regardless of light/dark theme.
    func zenGlobeRGB(_ scheme: ColorScheme) -> simd_float3 {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if canImport(UIKit)
        let traits = UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light)
        UIColor(self).resolvedColor(with: traits).getRed(&r, green: &g, blue: &b, alpha: &a)
        #elseif canImport(AppKit)
        let appearance = NSAppearance(named: scheme == .dark ? .darkAqua : .aqua)
        var native = NSColor(self)
        appearance?.performAsCurrentDrawingAppearance {
            native = (NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self))
        }
        native.usingColorSpace(.sRGB)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return simd_float3(Float(r), Float(g), Float(b))
    }
}
#endif

#Preview("ZenGlobe") {
    ZStack {
        Color.zenBackground.ignoresSafeArea()
        ZenGlobe(
            markers: [
                ZenGlobeMarker(latitude: 37.7595, longitude: -122.4367, size: 0.05),
                ZenGlobeMarker(latitude: 40.7128, longitude: -74.006, size: 0.07, color: .red),
                ZenGlobeMarker(latitude: 51.5074, longitude: -0.1278, size: 0.05),
                ZenGlobeMarker(latitude: 35.6762, longitude: 139.6503, size: 0.05),
            ]
        )
        .frame(width: 300, height: 300)
        .padding()
    }
}
