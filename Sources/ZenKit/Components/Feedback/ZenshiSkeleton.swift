import SwiftUI

public struct ZenSkeleton: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat

    public init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = ZenRadius.small) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: ZenTheme.current.resolvedCornerRadius(for: cornerRadius), style: .continuous)
            .fill(baseGradient)
            .overlay(overlayGradient)
            .frame(width: width, height: height)
            .redacted(reason: .placeholder)
            .accessibilityHidden(true)
    }

    private var baseGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.zenSurfaceMuted,
                Color.zenBorder.opacity(0.75),
                Color.zenSurfaceMuted,
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    @ViewBuilder
    private var overlayGradient: some View {
        if accessibilityReduceMotion || ZenTheme.current.motion == .reduced {
            EmptyView()
        } else {
            TimelineView(.animation) { context in
                let phase = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.6) / 1.6

                RoundedRectangle(cornerRadius: ZenTheme.current.resolvedCornerRadius(for: cornerRadius), style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: max(0, phase - 0.25)),
                                .init(color: Color.white.opacity(0.18), location: phase),
                                .init(color: .clear, location: min(1, phase + 0.25)),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blendMode(.plusLighter)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: ZenSpacing.small) {
        ZenSkeleton(width: 160, height: 16)
        ZenSkeleton(height: 44)
        ZenSkeleton(width: 84, height: 28, cornerRadius: 14)
    }
    .padding()
    .background(Color.zenBackground)
}
