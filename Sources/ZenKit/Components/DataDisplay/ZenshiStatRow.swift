import SwiftUI

public struct ZenStatRow: View {
    private let title: String
    private let subtitle: String?
    private let metrics: [ZenMetricValue]

    public init(title: String, subtitle: String? = nil, metrics: [ZenMetricValue]) {
        self.title = title
        self.subtitle = subtitle
        self.metrics = metrics
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedFullyRoundedCornerRadius(for: 38)

        HStack(alignment: .center, spacing: ZenSpacing.small) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.zenSurfaceMuted)
                .frame(width: 38, height: 38)
                .overlay(
                    Text(String(title.prefix(1)).uppercased())
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(Color.zenTextPrimary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zen(.body2, weight: .medium))
                    .foregroundStyle(Color.zenTextPrimary)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenGroup)
                        .foregroundStyle(Color.zenTextMuted)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: ZenSpacing.small)

            ForEach(Array(metrics.prefix(2).enumerated()), id: \.offset) { _, metric in
                VStack(alignment: .trailing, spacing: 2) {
                    Text(metric.value)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(metric.tint ?? Color.zenTextPrimary)
                    Text(metric.label)
                        .font(.zenGroup)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            ZenIcon(systemName: "chevron.right", size: 12)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.zenTextMuted)
        }
        .padding(.vertical, 6)
    }
}
