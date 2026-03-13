import SwiftUI

public struct ZenProgressBar: View {
    public let progress: Double

    public init(progress: Double) {
        self.progress = min(max(progress, 0), 1)
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedFullyRoundedCornerRadius(for: 8)

        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.zenBorder)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.zenPrimary)
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
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextPrimary)
            ZenProgressBar(progress: 0.35)
        }

        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            Text("Sync complete")
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextPrimary)
            ZenProgressBar(progress: 1)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
