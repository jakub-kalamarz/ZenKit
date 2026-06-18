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

/// A great-circle arc drawn between two lat/lon points on a ``ZenGlobe`` (cobe v2 arcs).
public struct ZenGlobeArc: Identifiable {
    public let id: UUID
    public let from: (latitude: Double, longitude: Double)
    public let to: (latitude: Double, longitude: Double)
    /// Arc color; falls back to the globe's `arcColor` when nil.
    public let color: Color?

    public init(
        from: (latitude: Double, longitude: Double),
        to: (latitude: Double, longitude: Double),
        color: Color? = nil
    ) {
        self.id = UUID()
        self.from = from
        self.to = to
        self.color = color
    }
}

/// A location on the globe resolved from a tap (see ``ZenGlobe``'s `onTapLocation`).
public struct ZenGlobeTap {
    /// Geographic coordinates in degrees.
    public let latitude: Double
    public let longitude: Double
}

/// A selected location on the globe. Bind it to ``ZenGlobe``'s `selection` to fly the globe to
/// the point and mark it as selected — set it from code (e.g. a country picker) or let a tap set it.
public struct ZenGlobeSelection: Equatable {
    /// Geographic coordinates in degrees.
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    /// A selection at the centroid of a country (ISO 3166-1 alpha-2), or nil if unknown.
    /// Selecting it flies to and highlights that whole country.
    public init?(countryISO iso: String) {
        #if canImport(CoreGraphics)
        guard let c = ZenGlobeCountryMap.centroid(iso: iso) else { return nil }
        self.latitude = c.latitude
        self.longitude = c.longitude
        #else
        return nil
        #endif
    }
}

/// Mutable rotation state handed to ``ZenGlobe``'s `onRender` callback each frame (cobe's
/// `onRender`). Set `phi`/`theta` to drive the globe — e.g. to spin toward a location.
public final class ZenGlobeRenderState {
    /// Rotation around the vertical axis (longitude), in radians.
    public var phi: Double
    /// Tilt toward/away from the viewer (latitude), in radians.
    public var theta: Double

    init(phi: Double, theta: Double) {
        self.phi = phi
        self.theta = theta
    }
}

/// An interactive, auto-rotating dotted globe — a native Metal reimplementation of the
/// [cobe](https://github.com/shuding/cobe) WebGL globe. Continents emerge as bright dot
/// clusters on a glowing sphere; drag to spin, pin markers at lat/lon coordinates, and draw
/// great-circle arcs between points. Markers and arcs render in Metal alongside the globe, so
/// they stay perfectly in sync with its rotation and occlude correctly behind it.
///
/// The globe respects Reduce Motion (it stops auto-rotating but stays draggable) and renders
/// transparently, so it composes over any background.
///
/// ```swift
/// ZenGlobe(
///     markers: [
///         ZenGlobeMarker(latitude: 37.7595, longitude: -122.4367, size: 0.05),
///         ZenGlobeMarker(latitude: 40.7128, longitude: -74.006, size: 0.07, color: .red),
///     ],
///     arcs: [
///         ZenGlobeArc(from: (37.77, -122.43), to: (40.71, -74.0)),
///     ]
/// )
/// .frame(width: 300, height: 300)
/// ```
public struct ZenGlobe: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let markers: [ZenGlobeMarker]
    private let arcs: [ZenGlobeArc]
    private let autoRotate: Bool
    private let rotationSpeed: Double
    private let phi: Double
    private let theta: Double
    private let dark: Double?
    private let diffuse: Double
    private let mapBrightness: Double
    private let mapBaseBrightness: Double
    private let mapSamples: Int
    private let scale: Double
    private let offset: CGSize
    private let opacity: Double
    private let markerElevation: Double
    private let baseColor: Color?
    private let dotColor: Color?
    private let glowColor: Color?
    private let markerColor: Color
    private let arcColor: Color
    private let arcWidth: Double
    private let arcHeight: Double
    private let onRender: ((ZenGlobeRenderState) -> Void)?
    private let markerLabel: ((ZenGlobeMarker) -> AnyView)?
    private let onTapLocation: ((ZenGlobeTap) -> Void)?
    private let selection: Binding<ZenGlobeSelection?>?
    private let flyToSelection: Bool
    private let selectionColor: Color
    private let highlightSelectedCountry: Bool
    private let countryHighlightColor: Color

    /// - Parameters:
    ///   - markers: Points to pin on the globe.
    ///   - arcs: Great-circle arcs to draw between lat/lon pairs.
    ///   - autoRotate: Continuously spin the globe (ignored when Reduce Motion is on).
    ///   - rotationSpeed: Auto-rotation increment in radians per frame.
    ///   - phi: Initial rotation around the vertical axis, in radians.
    ///   - theta: Initial tilt toward/away from the viewer, in radians.
    ///   - dark: 0 = light globe (pale sphere, tinted land dots), 1 = dark globe with glowing
    ///     land. Values in-between blend. Defaults to the current color scheme (light → 0, dark → 1).
    ///   - diffuse: Lighting falloff exponent toward the silhouette (higher = sharper).
    ///   - mapBrightness: Brightness multiplier for land dots.
    ///   - mapBaseBrightness: Floor brightness for ocean dots (>0 makes oceans faintly visible).
    ///   - mapSamples: Number of dots on the sphere (more = finer continents).
    ///   - scale: Zoom of the sphere within its frame.
    ///   - offset: Pan of the sphere within its frame, in points.
    ///   - opacity: Globe body opacity (cobe-style; 1 = full).
    ///   - markerElevation: Height markers/arc endpoints float above the surface (sphere radius units).
    ///   - baseColor: Sphere body color (the "ocean"). Defaults to a theme-appropriate pale fill.
    ///   - dotColor: Land-dot color. Defaults to a soft blue.
    ///   - glowColor: Halo / rim-glow color. Defaults to a theme-appropriate glow.
    ///   - markerColor: Default marker fill.
    ///   - arcColor: Default arc color.
    ///   - arcWidth: Arc ribbon width (cobe units).
    ///   - arcHeight: How high arcs bow off the surface (sphere radius units).
    ///   - onRender: Per-frame hook to drive rotation (cobe's `onRender`). Mutate the supplied
    ///     state's `phi`/`theta`; runs after auto-rotate/drag each frame.
    ///   - markerLabel: Optional SwiftUI label anchored to each marker's projected position
    ///     (cobe's CSS anchors). Fades out as the marker rotates behind the globe.
    ///   - onTapLocation: Called when the globe is tapped, with the lat/lon under the touch.
    ///     Not called when the tap misses the sphere (lands outside the silhouette).
    ///   - selection: Two-way selected location. Setting it (from code or a tap) flies the globe
    ///     to bring the point front-and-center and renders a "selected" indicator there.
    ///   - flyToSelection: Animate the rotation to center the selection (default true).
    ///   - selectionColor: Tint of the selected-location pin indicator.
    ///   - highlightSelectedCountry: Tint every dot of the selected location's country (default true).
    ///   - countryHighlightColor: Color used to fill the highlighted country's dots.
    public init(
        markers: [ZenGlobeMarker] = [],
        arcs: [ZenGlobeArc] = [],
        autoRotate: Bool = true,
        rotationSpeed: Double = 0.005,
        phi: Double = 0,
        theta: Double = 0.3,
        dark: Double? = nil,
        diffuse: Double = 1.2,
        mapBrightness: Double = 6,
        mapBaseBrightness: Double = 0,
        mapSamples: Int = 16000,
        scale: Double = 1,
        offset: CGSize = .zero,
        opacity: Double = 1,
        markerElevation: Double = 0,
        baseColor: Color? = nil,
        dotColor: Color? = nil,
        glowColor: Color? = nil,
        markerColor: Color = .zenAccent,
        arcColor: Color = .zenAccent,
        arcWidth: Double = 1,
        arcHeight: Double = 0.2,
        onRender: ((ZenGlobeRenderState) -> Void)? = nil,
        markerLabel: ((ZenGlobeMarker) -> AnyView)? = nil,
        onTapLocation: ((ZenGlobeTap) -> Void)? = nil,
        selection: Binding<ZenGlobeSelection?>? = nil,
        flyToSelection: Bool = true,
        selectionColor: Color = .zenAccent,
        highlightSelectedCountry: Bool = true,
        countryHighlightColor: Color = .zenAccent
    ) {
        self.markers = markers
        self.arcs = arcs
        self.autoRotate = autoRotate
        self.rotationSpeed = rotationSpeed
        self.phi = phi
        self.theta = theta
        self.dark = dark
        self.diffuse = diffuse
        self.mapBrightness = mapBrightness
        self.mapBaseBrightness = mapBaseBrightness
        self.mapSamples = mapSamples
        self.scale = scale
        self.offset = offset
        self.opacity = opacity
        self.markerElevation = markerElevation
        self.baseColor = baseColor
        self.dotColor = dotColor
        self.glowColor = glowColor
        self.markerColor = markerColor
        self.arcColor = arcColor
        self.arcWidth = arcWidth
        self.arcHeight = arcHeight
        self.onRender = onRender
        self.markerLabel = markerLabel
        self.onTapLocation = onTapLocation
        self.selection = selection
        self.flyToSelection = flyToSelection
        self.selectionColor = selectionColor
        self.highlightSelectedCountry = highlightSelectedCountry
        self.countryHighlightColor = countryHighlightColor
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
                    reduceMotion: reduceMotion,
                    initialPhi: phi,
                    initialTheta: theta,
                    markerColor: markerColor.zenGlobeRGB(colorScheme),
                    arcColor: arcColor.zenGlobeRGB(colorScheme),
                    markerElevation: Float(markerElevation),
                    offset: simd_float2(Float(offset.width), Float(offset.height)),
                    markerData: markerData,
                    arcData: arcData,
                    onRender: bridgedOnRender
                )

                if markerLabel != nil || selection != nil {
                    TimelineView(.animation) { ctx in
                        ZStack {
                            if markerLabel != nil { labelLayer(in: geo.size) }
                            // Show the pin only when the selection isn't already shown as a
                            // highlighted country (e.g. an ocean point, or highlighting disabled).
                            if let sel = selection?.wrappedValue, !highlightsCountry(sel) {
                                selectionIndicator(sel, in: geo.size, date: ctx.date)
                            }
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { motion.dragChanged($0.translation) }
                    .onEnded { _ in motion.dragEnded() }
            )
            .modifier(TapLocationModifier(enabled: onTapLocation != nil || selection != nil) { point in
                guard let tap = hitTest(point, in: geo.size) else { return }
                onTapLocation?(tap)
                selection?.wrappedValue = ZenGlobeSelection(latitude: tap.latitude, longitude: tap.longitude)
            })
            .onAppear { flyTo(selection?.wrappedValue) }
            .onChange(of: selection?.wrappedValue) { newValue in flyTo(newValue) }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    /// Eases the globe so `location` ends up front-and-center (solves for the rotation that
    /// rotates the point toward the viewer). No-op when fly-to is disabled or `location` is nil.
    private func flyTo(_ location: ZenGlobeSelection?) {
        guard flyToSelection, let location else { return }
        let d = Self.latLonTo3D(location.latitude, location.longitude)
        let px = Double(d.x), py = Double(d.y), pz = Double(d.z)
        let targetTheta = asin(max(-1, min(1, py)))
        let targetPhi = atan2(-px, pz)
        motion.flyTarget = (phi: targetPhi, theta: targetTheta)
    }

    /// Whether the selected point is rendered as a highlighted country (so the pin is redundant).
    private func highlightsCountry(_ sel: ZenGlobeSelection) -> Bool {
        highlightSelectedCountry && ZenGlobeCountryMap.index(latitude: sel.latitude, longitude: sel.longitude) > 0
    }

    /// Pulsing "selected" indicator anchored at the selection's projected position.
    @ViewBuilder
    private func selectionIndicator(_ sel: ZenGlobeSelection, in size: CGSize, date: Date) -> some View {
        let p = projectCoordinate(sel.latitude, sel.longitude, in: size)
        if p.opacity > 0.01 {
            let pulse = 1 + 0.35 * sin(date.timeIntervalSinceReferenceDate * 3)
            ZStack {
                Circle()
                    .stroke(selectionColor, lineWidth: 2)
                    .frame(width: 30 * pulse, height: 30 * pulse)
                    .opacity(0.9 - 0.35 * (pulse - 1) / 0.35)
                Circle()
                    .fill(selectionColor)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
            .position(p.point)
            .opacity(p.opacity)
            .allowsHitTesting(false)
        }
    }

    /// Inverse of the marker projection: a tap point (view coords) → lat/lon on the surface.
    /// Returns `nil` when the tap lands outside the globe's silhouette.
    private func hitTest(_ point: CGPoint, in size: CGSize) -> ZenGlobeTap? {
        let w = Double(max(size.width, 1)), h = Double(max(size.height, 1))
        let clipX = Double(point.x) / w * 2 - 1
        let clipY = 1 - Double(point.y) / h * 2
        let ia = h / w

        // Undo aspect / scale / offset to recover the rotated sphere's x,y.
        let rx = (clipX - Double(offset.width) * scale / w) / (ia * scale)
        let ry = (clipY + Double(offset.height) * scale / h) / scale

        let kR = 0.8
        let rho = rx * rx + ry * ry
        guard rho <= kR * kR else { return nil } // missed the globe
        let rz = (kR * kR - rho).squareRoot() // front hemisphere faces the viewer

        // Un-rotate (transpose of the marker rotation matrix R) to world space.
        let cx = cos(motion.theta), cy = cos(motion.phi)
        let sx = sin(motion.theta), sy = sin(motion.phi)
        let px = cy * rx + sy * sx * ry - sy * cx * rz
        let py = cx * ry + sx * rz
        let pz = sy * rx - cy * sx * ry + cy * cx * rz

        // Invert latLonTo3D on the unit direction.
        let inv = 1.0 / kR
        let dx = px * inv, dy = py * inv, dz = pz * inv
        let lat = asin(max(-1, min(1, dy))) * 180 / .pi
        let lonRad = atan2(dz, -dx)
        var lon = (lonRad + .pi) * 180 / .pi
        if lon > 180 { lon -= 360 }
        if lon < -180 { lon += 360 }
        return ZenGlobeTap(latitude: lat, longitude: lon)
    }

    /// Anchors each marker's label at its projected screen position (cobe's CSS anchors),
    /// fading it out as the marker rotates behind the globe's terminator.
    @ViewBuilder
    private func labelLayer(in size: CGSize) -> some View {
        ForEach(markers) { marker in
            let p = projectLabel(marker, in: size)
            markerLabel?(marker)
                .position(p.point)
                .opacity(p.opacity)
                .allowsHitTesting(p.opacity > 0.01)
        }
    }

    private func projectLabel(_ marker: ZenGlobeMarker, in size: CGSize) -> (point: CGPoint, opacity: Double) {
        projectCoordinate(marker.latitude, marker.longitude, in: size)
    }

    /// CPU port of the marker vertex shader's center transform — places an overlay (label or
    /// selection indicator) exactly where the GPU draws a marker at this lat/lon. Returns the
    /// screen point and a terminator fade in [0, 1].
    private func projectCoordinate(_ lat: Double, _ lon: Double, in size: CGSize) -> (point: CGPoint, opacity: Double) {
        let r = 0.8 + markerElevation
        let d = Self.latLonTo3D(lat, lon)
        let px = Double(d.x) * r, py = Double(d.y) * r, pz = Double(d.z) * r

        let cx = cos(motion.theta), cy = cos(motion.phi)
        let sx = sin(motion.theta), sy = sin(motion.phi)
        let rx = cy * px + sy * pz
        let ry = sy * sx * px + cx * py - cy * sx * pz
        let rz = -sy * cx * px + sx * py + cy * cx * pz

        let w = max(size.width, 1), h = max(size.height, 1)
        let ia = h / w
        let clipX = rx * ia * scale + Double(offset.width) * scale / w
        let clipY = ry * scale - Double(offset.height) * scale / h
        let point = CGPoint(x: (clipX + 1) / 2 * w, y: (1 - clipY) / 2 * h)
        let edgeFade = max(0, min(1, rz / 0.1))
        return (point, edgeFade)
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
        u.renderParams = simd_float4(Float(mapBrightness), Float(diffuse), Float(resolvedDark), Float(opacity))
        u.misc = simd_float4(Float(mapBaseBrightness), 0, 0, 0)

        // Highlight the whole country containing the selected point (GPU index-map lookup).
        if highlightSelectedCountry, let sel = selection?.wrappedValue {
            let idx = ZenGlobeCountryMap.index(latitude: sel.latitude, longitude: sel.longitude)
            if idx > 0 {
                let c = countryHighlightColor.zenGlobeRGB(colorScheme)
                u.selection = simd_float4(c.x, c.y, c.z, Float(idx))
            }
        }
        return u
    }

    /// Marker instance data: 8 floats each (dir.xyz, size, color.rgb, hasColor).
    private var markerData: [Float] {
        var data = [Float]()
        data.reserveCapacity(markers.count * 8)
        for m in markers {
            let d = Self.latLonTo3D(m.latitude, m.longitude)
            data.append(contentsOf: [d.x, d.y, d.z, Float(m.size)])
            if let c = m.color?.zenGlobeRGB(colorScheme) {
                data.append(contentsOf: [c.x, c.y, c.z, 1])
            } else {
                data.append(contentsOf: [0, 0, 0, 0])
            }
        }
        return data
    }

    /// Arc instance data: 12 floats each (from.xyz, to.xyz, height, width, color.rgb, hasColor).
    private var arcData: [Float] {
        var data = [Float]()
        data.reserveCapacity(arcs.count * 12)
        let height = Float(arcHeight + markerElevation)
        let width = Float(arcWidth * 0.005)
        for a in arcs {
            let f = Self.latLonTo3D(a.from.latitude, a.from.longitude)
            let t = Self.latLonTo3D(a.to.latitude, a.to.longitude)
            data.append(contentsOf: [f.x, f.y, f.z, t.x, t.y, t.z, height, width])
            if let c = a.color?.zenGlobeRGB(colorScheme) {
                data.append(contentsOf: [c.x, c.y, c.z, 1])
            } else {
                data.append(contentsOf: [0, 0, 0, 0])
            }
        }
        return data
    }

    /// Bridges the public `onRender` closure to the internal `GlobeMotion`-based hook.
    private var bridgedOnRender: ((GlobeMotion) -> Void)? {
        guard let onRender else { return nil }
        return { motion in
            let state = ZenGlobeRenderState(phi: motion.phi, theta: motion.theta)
            onRender(state)
            motion.phi = state.phi
            motion.theta = state.theta
        }
    }

    /// Port of cobe's `latLonTo3D` (src/index.js): lat/lon in degrees → unit direction.
    private static func latLonTo3D(_ lat: Double, _ lon: Double) -> simd_float3 {
        let latRad = lat * .pi / 180
        let lonRad = lon * .pi / 180 - .pi
        let cosLat = cos(latRad)
        return simd_float3(
            Float(-cosLat * cos(lonRad)),
            Float(sin(latRad)),
            Float(cosLat * sin(lonRad))
        )
    }
    #else
    public var body: some View {
        Color.clear.aspectRatio(1, contentMode: .fit)
    }
    #endif
}

#if canImport(MetalKit)
/// Adds a tap gesture (reporting the touch location) only when a handler is attached, so the
/// globe stays free of extra gestures when `onTapLocation` is nil. Simultaneous with the drag,
/// so a quick tap detects a location while a drag still spins the globe.
private struct TapLocationModifier: ViewModifier {
    let enabled: Bool
    let action: (CGPoint) -> Void

    func body(content: Content) -> some View {
        if enabled {
            content.simultaneousGesture(
                SpatialTapGesture().onEnded { action($0.location) }
            )
        } else {
            content
        }
    }
}

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
            ],
            arcs: [
                ZenGlobeArc(from: (37.7595, -122.4367), to: (40.7128, -74.006)),
                ZenGlobeArc(from: (40.7128, -74.006), to: (51.5074, -0.1278), color: .orange),
                ZenGlobeArc(from: (51.5074, -0.1278), to: (35.6762, 139.6503)),
            ]
        )
        .frame(width: 300, height: 300)
        .padding()
    }
}
