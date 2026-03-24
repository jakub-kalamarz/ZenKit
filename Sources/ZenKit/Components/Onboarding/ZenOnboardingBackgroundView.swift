import SwiftUI

struct ZenOnboardingBackgroundView: View {
    let pageIndex: Int
    let style: ZenOnboardingBackgroundStyle
    private let meshBlobs: [MeshBlobPreset]

    init(pageIndex: Int, style: ZenOnboardingBackgroundStyle) {
        self.pageIndex = pageIndex
        self.style = style
        self.meshBlobs = ZenOnboardingBackgroundPlan.makeMeshBlobs(pageIndex: pageIndex, style: style)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let minDimension = min(size.width, size.height)

            ZStack {
                Color.zenBackground

                LinearGradient(
                    colors: [
                        Color.zenSurface.opacity(0.75),
                        Color.zenBackground.opacity(0.88),
                        Color.zenSurfaceMuted.opacity(0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ForEach(meshBlobs) { blob in
                    RadialGradient(
                        colors: [blob.color, blob.color.opacity(0.0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: blob.radius * minDimension
                    )
                    .frame(
                        width: blob.diameter * minDimension,
                        height: blob.diameter * minDimension
                    )
                    .position(
                        x: blob.position.x * size.width,
                        y: blob.position.y * size.height
                    )
                    .blur(radius: blob.blur)
                    .blendMode(.plusLighter)
                }

                ZenOnboardingGrainOverlay(
                    pattern: GrainPattern.make(
                        pageIndex: pageIndex,
                        style: style,
                        size: size
                    )
                )
            }
            .overlay(
                Rectangle()
                    .strokeBorder(Color.zenBorder.opacity(0.22), lineWidth: 1)
            )
            .compositingGroup()
        }
    }
}

private struct ZenOnboardingBackgroundPlan {
    static func makeMeshBlobs(pageIndex: Int, style: ZenOnboardingBackgroundStyle) -> [MeshBlobPreset] {
        let intensityScale: Double = style.intensity == .expressive ? 1.35 : 1.0
        let pageSeed = pageIndex &* 31

        return [
            MeshBlobPreset(
                id: 0,
                position: CGPoint(
                    x: animatedUnitValue(base: 0.18, amplitude: 0.05 * intensityScale, phase: 0.0, seed: pageSeed + 1),
                    y: animatedUnitValue(base: 0.24, amplitude: 0.05 * intensityScale, phase: 0.25, seed: pageSeed + 1)
                ),
                diameter: 0.78 + 0.08 * intensityScale,
                radius: 0.36 + 0.05 * intensityScale,
                blur: 30,
                color: Color.zenPrimary.opacity(style.intensity == .expressive ? 0.46 : 0.32)
            ),
            MeshBlobPreset(
                id: 1,
                position: CGPoint(
                    x: animatedUnitValue(base: 0.82, amplitude: 0.06 * intensityScale, phase: 0.4, seed: pageSeed + 7),
                    y: animatedUnitValue(base: 0.20, amplitude: 0.06 * intensityScale, phase: 0.9, seed: pageSeed + 7)
                ),
                diameter: 0.70 + 0.06 * intensityScale,
                radius: 0.34 + 0.04 * intensityScale,
                blur: 28,
                color: Color.zenAccent.opacity(style.intensity == .expressive ? 0.40 : 0.28)
            ),
            MeshBlobPreset(
                id: 2,
                position: CGPoint(
                    x: animatedUnitValue(base: 0.72, amplitude: 0.04 * intensityScale, phase: 1.1, seed: pageSeed + 13),
                    y: animatedUnitValue(base: 0.78, amplitude: 0.04 * intensityScale, phase: 1.5, seed: pageSeed + 13)
                ),
                diameter: 0.64 + 0.04 * intensityScale,
                radius: 0.28 + 0.03 * intensityScale,
                blur: 22,
                color: Color.zenSuccess.opacity(style.intensity == .expressive ? 0.26 : 0.18)
            ),
            MeshBlobPreset(
                id: 3,
                position: CGPoint(
                    x: animatedUnitValue(base: 0.22, amplitude: 0.03 * intensityScale, phase: 1.8, seed: pageSeed + 19),
                    y: animatedUnitValue(base: 0.84, amplitude: 0.03 * intensityScale, phase: 2.2, seed: pageSeed + 19)
                ),
                diameter: 0.48 + 0.03 * intensityScale,
                radius: 0.20 + 0.02 * intensityScale,
                blur: 18,
                color: Color.zenWarning.opacity(style.intensity == .expressive ? 0.18 : 0.12)
            )
        ]
    }

    private static func animatedUnitValue(base: Double, amplitude: Double, phase: Double, seed: Int) -> Double {
        let horizontal = amplitude * sin(phase + Double(seed % 11))
        return clamp(base + horizontal, lower: 0.10, upper: 0.90)
    }

    private static func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
        min(max(value, lower), upper)
    }
}

private struct MeshBlobPreset: Identifiable {
    let id: Int
    let position: CGPoint
    let diameter: Double
    let radius: Double
    let blur: CGFloat
    let color: Color
}
