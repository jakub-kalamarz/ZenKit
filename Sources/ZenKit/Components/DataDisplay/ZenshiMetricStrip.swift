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
    public static let iconBadgeSize: CGFloat = 28
    public static let iconBadgeIconSize: CGFloat = 18
    public static let compactIconBadgeSize: CGFloat = 24
    public static let compactIconBadgeIconSize: CGFloat = 14
    public static let iconBadgeCornerRadius: CGFloat = 8
    public static let contentSpacing: CGFloat = ZenSpacing.xSmall
    public static let textSpacing: CGFloat = 2
    public static let comparisonSpacing: CGFloat = 2
    public static let comparisonStackSpacing: CGFloat = 4
    public static let comparisonIconSize: CGFloat = 10
    public static let gridComparisonBreakpoint: CGFloat = 132
    public static let gridIconBreakpoint: CGFloat = 168

    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @State private var availableWidth: CGFloat = 0
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
                let columnCount = max(columns, 1)
                let measuredWidth = availableWidth > 0 ? availableWidth : fallbackGridWidth(for: columnCount)
                let tileWidth = resolvedTileWidth(availableWidth: measuredWidth, columns: columnCount)
                let gridContentMode = gridContentMode(for: tileWidth)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: columnCount),
                    spacing: ZenSpacing.small
                ) {
                    metricTiles(tileCornerRadius: tileCornerRadius, gridContentMode: gridContentMode)
                }
            case .row:
                HStack(spacing: ZenSpacing.small) {
                    metricTiles(tileCornerRadius: tileCornerRadius, gridContentMode: nil)
                }
            }
        }
        .zenReadSize { size in
            availableWidth = size.width
        }
    }

    @ViewBuilder
    private func metricTile(for value: ZenMetricValue, gridContentMode: GridMetricContentMode?) -> some View {
        switch style {
        case .default:
            metricText(for: value, gridContentMode: gridContentMode)
        case .compact:
            HStack(alignment: .center, spacing: Self.contentSpacing) {
                if let iconSource = value.iconSource {
                    iconBadge(
                        for: iconSource,
                        tint: value.tint,
                        badgeSize: Self.compactIconBadgeSize,
                        iconSize: Self.compactIconBadgeIconSize
                    )
                }

                compactMetricValue(for: value)
            }
        }
    }

    @ViewBuilder
    private func metricTiles(tileCornerRadius: CGFloat, gridContentMode: GridMetricContentMode?) -> some View {
        ForEach(Array(values.enumerated()), id: \.offset) { _, value in
            metricTile(for: value, gridContentMode: gridContentMode)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func iconBadge(
        for iconSource: ZenIconSource,
        tint: Color?,
        badgeSize: CGFloat = Self.iconBadgeSize,
        iconSize: CGFloat = Self.iconBadgeIconSize
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Self.iconBadgeCornerRadius, style: .continuous)
                .fill(Color.zenSurface)
                .frame(width: badgeSize, height: badgeSize)

            ZenIcon(source: iconSource, size: iconSize)
                .foregroundStyle(tint ?? Color.zenTextMuted)
        }
    }

    @ViewBuilder
    private func metricText(for value: ZenMetricValue, gridContentMode: GridMetricContentMode?) -> some View {
        if let gridContentMode {
            metricTextContent(
                for: value,
                showsIcon: gridContentMode.showsIcon,
                showsComparison: gridContentMode.showsComparison
            )
        } else {
            ViewThatFits(in: .horizontal) {
                metricTextContent(for: value, showsIcon: true, showsComparison: true)
                metricTextContent(for: value, showsIcon: false, showsComparison: true)
                metricTextContent(for: value, showsIcon: false, showsComparison: false)
            }
        }
    }

    private func compactMetricValue(for value: ZenMetricValue) -> some View {
        ViewThatFits(in: .horizontal) {
            compactMetricValueContent(for: value, showsComparison: true)
            compactMetricValueContent(for: value, showsComparison: false)
        }
    }

    private func metricTextContent(for value: ZenMetricValue, showsIcon: Bool, showsComparison: Bool) -> some View {
        HStack(alignment: .center, spacing: Self.contentSpacing) {
            if showsIcon, let iconSource = value.iconSource {
                iconBadge(for: iconSource, tint: value.tint)
            }

            VStack(alignment: .leading, spacing: Self.textSpacing) {
                Text(value.label)
                    .font(.zenCaption.weight(.medium))
                    .foregroundStyle(Color.zenTextMuted)
                    .lineLimit(1)

                metricValueWithComparison(
                    for: value,
                    font: .zenTitle.weight(.semibold),
                    minimumScaleFactor: 0.8,
                    showsComparison: showsComparison
                )
            }
        }
    }

    private func compactMetricValueContent(for value: ZenMetricValue, showsComparison: Bool) -> some View {
        metricValueWithComparison(
            for: value,
            font: .zenLabel.weight(.semibold),
            minimumScaleFactor: 0.75,
            showsComparison: showsComparison
        )
    }

    @ViewBuilder
    private func metricValueWithComparison(
        for value: ZenMetricValue,
        font: Font,
        minimumScaleFactor: CGFloat,
        showsComparison: Bool
    ) -> some View {
        if showsComparison, value.comparisonValue != nil {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: Self.contentSpacing) {
                    metricValueText(for: value, font: font, minimumScaleFactor: minimumScaleFactor)
                    comparisonAccessory(for: value)
                }

                VStack(alignment: .leading, spacing: Self.comparisonStackSpacing) {
                    metricValueText(for: value, font: font, minimumScaleFactor: minimumScaleFactor)
                    comparisonAccessory(for: value)
                }
            }
        } else {
            metricValueText(for: value, font: font, minimumScaleFactor: minimumScaleFactor)
        }
    }

    private func metricValueText(for value: ZenMetricValue, font: Font, minimumScaleFactor: CGFloat) -> some View {
        Text(value.value)
            .font(font)
            .monospacedDigit()
            .foregroundStyle(value.tint ?? Color.zenTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(minimumScaleFactor)
    }

    @ViewBuilder
    private func comparisonAccessory(for value: ZenMetricValue) -> some View {
        if let comparisonValue = value.comparisonValue {
            HStack(spacing: Self.comparisonSpacing) {
                if let trend = value.trend {
                    ZenIcon(systemName: comparisonIconSystemName(for: trend), size: Self.comparisonIconSize)
                        .foregroundStyle(comparisonColor(for: value))
                }

                Text(comparisonValue)
                    .font(.zenCaption.weight(.semibold))
                    .foregroundStyle(comparisonColor(for: value))
                    .lineLimit(1)
                    .monospacedDigit()
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

    private func comparisonIconSystemName(for trend: ZenMetricTrend) -> String {
        switch trend {
        case .up:
            return "chevron.up"
        case .down:
            return "chevron.down"
        case .neutral:
            return "minus"
        }
    }

    private func resolvedTileWidth(availableWidth: CGFloat, columns: Int) -> CGFloat {
        let totalSpacing = CGFloat(max(columns - 1, 0)) * ZenSpacing.small
        return max((availableWidth - totalSpacing) / CGFloat(max(columns, 1)), 0)
    }

    private func gridContentMode(for tileWidth: CGFloat) -> GridMetricContentMode {
        if tileWidth >= Self.gridIconBreakpoint {
            return .iconAndComparison
        }

        if tileWidth >= Self.gridComparisonBreakpoint {
            return .comparisonOnly
        }

        return .valueOnly
    }

    private func fallbackGridWidth(for columns: Int) -> CGFloat {
        let estimatedTileWidth = Self.gridIconBreakpoint
        let totalSpacing = CGFloat(max(columns - 1, 0)) * ZenSpacing.small
        return (estimatedTileWidth * CGFloat(columns)) + totalSpacing
    }
}

private enum GridMetricContentMode {
    case iconAndComparison
    case comparisonOnly
    case valueOnly

    var showsIcon: Bool {
        switch self {
        case .iconAndComparison:
            return true
        case .comparisonOnly, .valueOnly:
            return false
        }
    }

    var showsComparison: Bool {
        switch self {
        case .iconAndComparison, .comparisonOnly:
            return true
        case .valueOnly:
            return false
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
