import SwiftUI

public struct ZenMetricValue {
    public let label: String
    public let value: String
    public let tint: Color?

    public init(label: String, value: String, tint: Color? = nil) {
        self.label = label
        self.value = value
        self.tint = tint
    }
}

public struct ZenMetricStrip: View {
    private let values: [ZenMetricValue]

    public init(values: [ZenMetricValue]) {
        self.values = values
    }

    public var body: some View {
        let theme = ZenTheme.current

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: ZenSpacing.small) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                VStack(alignment: .leading, spacing: 4) {
                    Text(value.label.uppercased())
                        .font(.zenCaption.weight(.semibold))
                        .foregroundStyle(Color.zenTextMuted)

                    Text(value.value)
                        .font(.zenTitle)
                        .foregroundStyle(value.tint ?? Color.zenTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, ZenSpacing.small)
                .padding(.horizontal, 12)
                .background(Color.zenSurfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small)))
            }
        }
    }
}

#Preview {
    ZenMetricStrip(values: [
        ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent),
        ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess),
        ZenMetricValue(label: "CTR", value: "4%"),
        ZenMetricValue(label: "Position", value: "16", tint: .zenWarning),
    ])
    .padding()
    .background(Color.zenBackground)
}
