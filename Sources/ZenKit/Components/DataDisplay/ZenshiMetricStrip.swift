import SwiftUI

public enum ZenMetricTrend: String, Sendable {
    case up, down, neutral
}

public enum ZenMetricComparisonLogic: String, Sendable {
    case moreIsBetter, lessIsBetter, neutral
}

public struct ZenMetricValue {
    public let label: String
    public let value: String
    public let tint: Color?
    public let iconSource: ZenIconSource?
    public let comparisonValue: String?
    public let trend: ZenMetricTrend?
    public let comparisonLogic: ZenMetricComparisonLogic
    
    public init(
        label: String,
        value: String,
        tint: Color? = nil,
        iconSource: ZenIconSource? = nil,
        comparisonValue: String? = nil,
        trend: ZenMetricTrend? = nil,
        comparisonLogic: ZenMetricComparisonLogic = .moreIsBetter
    ) {
        self.label = label
        self.value = value
        self.tint = tint
        self.iconSource = iconSource
        self.comparisonValue = comparisonValue
        self.trend = trend
        self.comparisonLogic = comparisonLogic
    }
}

public enum ZenMetricStripStyle: Equatable {
    case `default`
    case compact
}

public enum ZenMetricStripLayout: Equatable {
    case grid(columns: Int)
    case row
}

public struct ZenMetricStrip: View {
    public static let iconBadgeSize: CGFloat = 40
    public static let iconBadgeIconSize: CGFloat = 24
    public static let iconBadgeCornerRadius: CGFloat = 10
    public static let contentSpacing: CGFloat = 12
    public static let textSpacing: CGFloat = 2

    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    private let values: [ZenMetricValue]
    public let style: ZenMetricStripStyle
    public let layout: ZenMetricStripLayout
    
    public init(
        values: [ZenMetricValue],
        style: ZenMetricStripStyle = .default,
        layout: ZenMetricStripLayout = .grid(columns: 2)
    ) {
        self.values = values
        self.style = style
        self.layout = layout
    }
    
    public var body: some View {
        let theme = ZenTheme.current
        let tileCornerRadius = theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: parentCornerRadius)

        Group {
            switch layout {
            case let .grid(columns):
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: max(columns, 1)),
                    spacing: ZenSpacing.small
                ) {
                    metricTiles(tileCornerRadius: tileCornerRadius)
                }
            case .row:
                HStack(spacing: ZenSpacing.small) {
                    metricTiles(tileCornerRadius: tileCornerRadius)
                }
            }
        }
    }

    @ViewBuilder
    private func metricTile(for value: ZenMetricValue) -> some View {
        switch style {
        case .default:
            if let iconSource = value.iconSource {
                HStack(alignment: .top, spacing: Self.contentSpacing) {
                    iconBadge(for: iconSource, tint: value.tint)
                    metricText(for: value)
                }
            } else {
                metricText(for: value)
            }
        case .compact:
            HStack(alignment: .center, spacing: Self.contentSpacing) {
                if let iconSource = value.iconSource {
                    iconBadge(for: iconSource, tint: value.tint)
                }

                compactMetricValue(for: value)
            }
        }
    }

    @ViewBuilder
    private func metricTiles(tileCornerRadius: CGFloat) -> some View {
        ForEach(Array(values.enumerated()), id: \.offset) { _, value in
            metricTile(for: value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, ZenSpacing.small)
                .padding(.horizontal, 12)
                .background(Color.zenSurfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: tileCornerRadius))
        }
    }

    private func iconBadge(for iconSource: ZenIconSource, tint: Color?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Self.iconBadgeCornerRadius, style: .continuous)
                .fill(Color.zenSurface)
                .frame(width: Self.iconBadgeSize, height: Self.iconBadgeSize)

            ZenIcon(source: iconSource, size: Self.iconBadgeIconSize)
                .foregroundStyle(tint ?? Color.zenTextMuted)
        }
    }

    private func metricText(for value: ZenMetricValue) -> some View {
        VStack(alignment: .leading, spacing: Self.textSpacing) {
            Text(value.label)
                .font(.zenCaption.weight(.medium))
                .foregroundStyle(Color.zenTextMuted)
                .lineLimit(1)

            Text(value.value)
                .font(.zenTitle.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(value.tint ?? Color.zenTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            if let comparisonValue = value.comparisonValue {
                Text(comparisonValue)
                    .font(.zenCaption)
                    .foregroundStyle(comparisonColor(for: value))
                    .lineLimit(1)
            }
        }
    }

    private func compactMetricValue(for value: ZenMetricValue) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value.value)
                .font(.zenTitle.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(value.tint ?? Color.zenTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            if let comparisonValue = value.comparisonValue {
                Text(comparisonValue)
                    .font(.zenCaption)
                    .foregroundStyle(comparisonColor(for: value))
                    .lineLimit(1)
            }
        }
    }
    
    private func comparisonColor(for value: ZenMetricValue) -> Color {
        guard let trend = value.trend else { return .zenTextMuted }
        
        switch (trend, value.comparisonLogic) {
        case (.up, .moreIsBetter), (.down, .lessIsBetter):
            return .zenSuccess
        case (.down, .moreIsBetter), (.up, .lessIsBetter):
            return .zenCritical
        default:
            return .zenTextMuted
        }
    }
}

#Preview {
    ZenMetricStrip(values: [
        ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent, iconSource: .asset("CursorClick"), comparisonValue: "+12%", trend: .up),
        ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess, iconSource: .asset("ChartBar"), comparisonValue: "-2%", trend: .down),
        ZenMetricValue(label: "CTR", value: "4%", iconSource: .system("percent"), comparisonValue: "0%", trend: .neutral),
        ZenMetricValue(label: "Position", value: "16", tint: .zenWarning, iconSource: .asset("TrendUp"), comparisonValue: "+2", trend: .up, comparisonLogic: .lessIsBetter),
    ])
    .padding()
    .background(Color.zenBackground)
}
