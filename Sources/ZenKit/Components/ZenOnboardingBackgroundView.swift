import SwiftUI

struct ZenOnboardingBackgroundView: View {
    let pageIndex: Int
    let style: ZenOnboardingBackgroundStyle

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let blobs = backgroundBlobs(in: proxy.size, date: timeline.date)

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

                    ForEach(Array(blobs.enumerated()), id: \.offset) { _, blob in
                        RadialGradient(
                            colors: [blob.color, blob.color.opacity(0.0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: blob.radius
                        )
                        .frame(width: blob.diameter, height: blob.diameter)
                        .position(blob.position)
                        .blur(radius: blob.blur)
                        .blendMode(.plusLighter)
                    }

                    ZenOnboardingGrainOverlay(
                        pageIndex: pageIndex,
                        style: style
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

    private func backgroundBlobs(in size: CGSize, date: Date) -> [MeshBlob] {
        let phase = date.timeIntervalSinceReferenceDate
        let intensityScale = style.intensity == .expressive ? 1.35 : 1.0
        let pageSeed = pageIndex &* 31

        return [
            MeshBlob(
                position: animatedPoint(
                    baseX: 0.18,
                    baseY: 0.24,
                    amplitude: 0.05 * intensityScale,
                    phase: phase,
                    seed: pageSeed + 1,
                    in: size
                ),
                diameter: min(size.width, size.height) * (0.78 + 0.08 * intensityScale),
                radius: min(size.width, size.height) * (0.36 + 0.05 * intensityScale),
                blur: 30,
                color: Color.zenPrimary.opacity(style.intensity == .expressive ? 0.46 : 0.32)
            ),
            MeshBlob(
                position: animatedPoint(
                    baseX: 0.82,
                    baseY: 0.20,
                    amplitude: 0.06 * intensityScale,
                    phase: phase * 0.9,
                    seed: pageSeed + 7,
                    in: size
                ),
                diameter: min(size.width, size.height) * (0.70 + 0.06 * intensityScale),
                radius: min(size.width, size.height) * (0.34 + 0.04 * intensityScale),
                blur: 28,
                color: Color.zenAccent.opacity(style.intensity == .expressive ? 0.40 : 0.28)
            ),
            MeshBlob(
                position: animatedPoint(
                    baseX: 0.72,
                    baseY: 0.78,
                    amplitude: 0.04 * intensityScale,
                    phase: phase * 1.15,
                    seed: pageSeed + 13,
                    in: size
                ),
                diameter: min(size.width, size.height) * (0.64 + 0.04 * intensityScale),
                radius: min(size.width, size.height) * (0.28 + 0.03 * intensityScale),
                blur: 22,
                color: Color.zenSuccess.opacity(style.intensity == .expressive ? 0.26 : 0.18)
            ),
            MeshBlob(
                position: animatedPoint(
                    baseX: 0.22,
                    baseY: 0.84,
                    amplitude: 0.03 * intensityScale,
                    phase: phase * 0.8,
                    seed: pageSeed + 19,
                    in: size
                ),
                diameter: min(size.width, size.height) * (0.48 + 0.03 * intensityScale),
                radius: min(size.width, size.height) * (0.20 + 0.02 * intensityScale),
                blur: 18,
                color: Color.zenWarning.opacity(style.intensity == .expressive ? 0.18 : 0.12)
            )
        ]
    }

    private func animatedPoint(
        baseX: Double,
        baseY: Double,
        amplitude: Double,
        phase: Double,
        seed: Int,
        in size: CGSize
    ) -> CGPoint {
        let horizontal = amplitude * sin(phase + Double(seed % 11))
        let vertical = amplitude * cos(phase * 0.92 + Double(seed % 7))
        let x = clamp(baseX + horizontal, lower: 0.10, upper: 0.90)
        let y = clamp(baseY + vertical, lower: 0.10, upper: 0.90)
        return CGPoint(x: size.width * x, y: size.height * y)
    }

    private func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
        min(max(value, lower), upper)
    }
}

private struct MeshBlob {
    let position: CGPoint
    let diameter: CGFloat
    let radius: CGFloat
    let blur: CGFloat
    let color: Color
}
