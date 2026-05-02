import SwiftUI

public struct ZenProgressBar: View {
    public let progress: Double
    public let tint: Color?

    public init(progress: Double, tint: Color? = nil) {
        self.progress = min(max(progress, 0), 1)
        self.tint = tint
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedFullyRoundedCornerRadius(for: 8)
        let barColor = tint ?? Color.zenPrimary

        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.zenBorder)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(barColor)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 8)
        .accessibilityValue(Text("\(Int(progress * 100)) percent"))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: ZenSpacing.medium) {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            Text("Uploading")
                .font(.zen(.body2, weight: .medium))
                .foregroundStyle(Color.zenTextPrimary)
            ZenProgressBar(progress: 0.35)
        }

        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            Text("Sync complete")
                .font(.zen(.body2, weight: .medium))
                .foregroundStyle(Color.zenTextPrimary)
            ZenProgressBar(progress: 1)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
