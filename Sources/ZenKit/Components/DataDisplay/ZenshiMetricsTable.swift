import SwiftUI

public struct ZenMetricsTableSegment<ID: Hashable & Sendable>: Equatable, Sendable {
    public let id: ID
    public let count: Int
    public let icon: ZenIconSource?
    public let title: String
    public let isDisabled: Bool

    public var iconAssetName: String? {
        guard case .asset(let assetName)? = icon else { return nil }
        return assetName
    }
    
    public init(
        id: ID,
        count: Int,
        icon: ZenIconSource? = nil,
        iconAssetName: String? = nil,
        title: String,
        isDisabled: Bool = false
    ) {
        self.id = id
        self.count = count
        self.icon = icon ?? iconAssetName.map(ZenIconSource.asset)
        self.title = title
        self.isDisabled = isDisabled
    }
}

public struct ZenMetricsTableValues: Equatable, Sendable {
    public struct Palette: Equatable, Sendable {
        public enum Role: String, Equatable, Sendable {
            case clicks
            case impressions
            case ctr
            case position
        }
        
        public let clicks: Color
        public let impressions: Color
        public let ctr: Color
        public let position: Color
        public let clicksRole: Role
        public let impressionsRole: Role
        public let ctrRole: Role
        public let positionRole: Role
        
        public init(
            clicks: Color,
            impressions: Color,
            ctr: Color,
            position: Color,
            clicksRole: Role,
            impressionsRole: Role,
            ctrRole: Role,
            positionRole: Role
        ) {
            self.clicks = clicks
            self.impressions = impressions
            self.ctr = ctr
            self.position = position
            self.clicksRole = clicksRole
            self.impressionsRole = impressionsRole
            self.ctrRole = ctrRole
            self.positionRole = positionRole
        }
    }
    
    public static let defaultPalette = Palette(
        clicks: .zenMetricClicks,
        impressions: .zenMetricImpressions,
        ctr: .zenMetricCtr,
        position: .zenMetricPosition,
        clicksRole: .clicks,
        impressionsRole: .impressions,
        ctrRole: .ctr,
        positionRole: .position
    )
    
    public let clicks: String
    public let impressions: String
    public let ctr: String
    public let position: String
    
    public init(clicks: String, impressions: String, ctr: String, position: String) {
        self.clicks = clicks
        self.impressions = impressions
        self.ctr = ctr
        self.position = position
    }
}

public struct ZenMetricsTable<ID: Hashable & Sendable, Content: View>: View {
    private let title: String
    private let icon: ZenIconSource?
    private let segments: [ZenMetricsTableSegment<ID>]
    private let isEmpty: Bool
    private let noDataDescription: String
    @Binding private var selection: ID
    private let content: () -> Content
    
    public init(
        title: String,
        icon: ZenIconSource? = nil,
        iconAssetName: String? = nil,
        segments: [ZenMetricsTableSegment<ID>] = [],
        isEmpty: Bool = false,
        noDataDescription: String = "No data available for this selection.",
        selection: Binding<ID>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon ?? iconAssetName.map(ZenIconSource.asset)
        self.segments = segments
        self.isEmpty = isEmpty
        self.noDataDescription = noDataDescription
        self._selection = selection
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            HStack(spacing: ZenSpacing.small) {
                if let icon {
                    ZenIcon(source: icon, size: 16)
                        .foregroundStyle(Color.zenAccent)
                }
                
                Text(title)
                    .font(.zenStat)
                    .foregroundStyle(Color.zenTextPrimary)
                
                Spacer()
                
                if !segments.isEmpty {
                    ZenSegmentedControl(
                        selection: $selection,
                        segments: segments.map(\.id),
                        disabledSegments: Set(segments.filter(\.isDisabled).map(\.id))
                    ) { value, isSelected in
                        if let segment = segments.first(where: { $0.id == value }) {
                            metricsSegmentLabel(segment, isSelected: isSelected)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                if isEmpty {
                    ZenEmpty {
                        ZenEmptyHeader {
                            ZenEmptyMedia(variant: .icon) {
                                if let icon {
                                    ZenIcon(source: icon, size: 24)
                                } else {
                                    ZenIcon(systemName: "info.circle", size: 24)
                                }
                            }
                            ZenEmptyDescription {
                                Text(noDataDescription)
                            }
                        }
                    }
                    .padding(.vertical, ZenSpacing.large)
                } else {
                    content()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private func metricsSegmentLabel(_ segment: ZenMetricsTableSegment<ID>, isSelected: Bool) -> some View {
        if let icon = segment.icon {
            ViewThatFits {
                HStack(spacing: 6) {
                    ZenIcon(source: icon, size: 12)
                    Text("\(segment.title) (\(segment.count))")
                }
                ZenIcon(source: icon, size: 12)
            }
        } else {
            Text("\(segment.title) (\(segment.count))")
        }
    }
}

public struct ZenMetricsTableHeader: View {
    public static let defaultTitles = ["Clicks", "Impr.", "CTR", "Pos."]
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            HStack(spacing: ZenSpacing.small) {
                Color.clear
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(Self.defaultTitles, id: \.self) { title in
                    metricLabel(title)
                }
            }
            
            Divider()
                .overlay(Color.zenBorder)
        }
    }
    
    private func metricLabel(_ title: String) -> some View {
        Text(title)
            .font(.zen(.group, weight: .semibold))
            .foregroundStyle(Color.zenTextMuted)
            .frame(minWidth: 52, alignment: .trailing)
    }
}

public struct ZenMetricsTableRow<LeadingAccessory: View>: View {
    private let title: String
    private let leadingAccessory: LeadingAccessory
    private let values: ZenMetricsTableValues
    private let palette: ZenMetricsTableValues.Palette
    
    public init(
        title: String,
        palette: ZenMetricsTableValues.Palette = ZenMetricsTableValues.defaultPalette,
        @ViewBuilder leadingAccessory: () -> LeadingAccessory,
        values: ZenMetricsTableValues
    ) {
        self.title = title
        self.leadingAccessory = leadingAccessory()
        self.values = values
        self.palette = palette
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Color.clear
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .top, spacing: ZenSpacing.small) {
                HStack(alignment: .top, spacing: ZenSpacing.xSmall) {
                    leadingAccessory
                    Text(title)
                        .font(.zenIntro)
                        .foregroundStyle(Color.zenTextPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                metricValue(values.clicks, tint: palette.clicks)
                metricValue(values.impressions, tint: palette.impressions)
                metricValue(values.ctr, tint: palette.ctr)
                metricValue(values.position, tint: palette.position)
            }
            
            Divider()
                .overlay(Color.zenBorder.opacity(0.65))
        }
    }
    
    private func metricValue(_ value: String, tint: Color) -> some View {
        Text(value)
            .font(.zen(.body2, weight: .medium))
            .foregroundStyle(tint)
            .frame(minWidth: 52, alignment: .trailing)
    }
}

public extension ZenMetricsTableRow where LeadingAccessory == EmptyView {
    init(
        title: String,
        palette: ZenMetricsTableValues.Palette = ZenMetricsTableValues.defaultPalette,
        values: ZenMetricsTableValues
    ) {
        self.init(title: title, palette: palette, leadingAccessory: { EmptyView() }, values: values)
    }
}

#Preview {
    ZenMetricsTable(
        title: "Top Queries",
        segments: [
            ZenMetricsTableSegment(id: "7d", count: 7, title: "Last 7 days"),
            ZenMetricsTableSegment(id: "28d", count: 28, title: "Last 28 days"),
            ZenMetricsTableSegment(id: "90d", count: 90, title: "Last 90 days")
        ],
        selection: .constant("7d")
    ) {
        ZenMetricsTableHeader()
        
        ZenMetricsTableRow(
            title: "query1.com",
            values: ZenMetricsTableValues(clicks: "1.2K", impressions: "10K", ctr: "12%", position: "3.4")
        )
        
        ZenMetricsTableRow(
            title: "query2.com",
            values: ZenMetricsTableValues(clicks: "800", impressions: "8K", ctr: "10%", position: "5.6")
        )
        
        ZenMetricsTableRow(
            title: "query3.com",
            values: ZenMetricsTableValues(clicks: "500", impressions: "5K", ctr: "10%", position: "7.8")
        )
    }
}
