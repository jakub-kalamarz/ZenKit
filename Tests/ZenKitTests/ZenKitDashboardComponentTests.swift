import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitDashboardComponentTests {
    private enum PreviewRange: String, CaseIterable {
        case week = "7D"
        case month = "28D"
        case quarter = "3M"
        case year = "1Y"
    }

    private var baseDate: Date {
        Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 1))!
    }

    @Test
    func dashboardComponentsComposeTogether() {
        let values = [
            ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent),
            ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess),
            ZenMetricValue(label: "Position", value: "16", tint: .zenWarning),
        ]
        let points = [
            ZenTrendPoint(
                date: baseDate,
                clicks: 10,
                impressions: 100,
                ctr: 10,
                position: 4,
                compareClicks: 8,
                compareImpressions: 92,
                compareCTR: 8.7,
                comparePosition: 2
            ),
            ZenTrendPoint(
                date: Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!,
                clicks: 20,
                impressions: 160,
                ctr: 12.5,
                position: 6,
                compareClicks: 18,
                compareImpressions: 150,
                compareCTR: 12,
                comparePosition: 4
            ),
            ZenTrendPoint(
                date: Calendar.current.date(byAdding: .day, value: 2, to: baseDate)!,
                clicks: 14,
                impressions: 140,
                ctr: 10,
                position: 5,
                compareClicks: 12,
                compareImpressions: 130,
                compareCTR: 9.2,
                comparePosition: 3
            ),
        ]

        let view = VStack {
            ZenSegmentedRangePicker(
                title: "Range",
                selection: .constant("28D"),
                options: ["7D", "28D", "3M", "1Y"]
            )

            ZenCollectionCard(title: "Residential", subtitle: "3 sites") {
                ZenMetricStrip(values: values)
                ZenTrendChartCard(title: "Trend", points: points)
                ZenStatRow(
                    title: "example.com",
                    subtitle: "Top site",
                    metrics: values.prefix(2).map { $0 }
                )
            }
        }

        _ = view
    }

    @Test
    func metricStripSupportsPerMetricIcons() {
        let values = [
            ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent, iconSource: .asset("CursorClick")),
            ZenMetricValue(label: "CTR", value: "4%", iconSource: .system("percent")),
        ]

        let view = ZenMetricStrip(values: values)

        #expect(values[0].iconSource == .asset("CursorClick"))
        #expect(values[1].iconSource == .system("percent"))
        _ = view
    }

    @Test
    func metricStripUsesSubtleIconBadgeLayoutMetrics() {
        #expect(ZenMetricStrip.iconBadgeSize == 28)
        #expect(ZenMetricStrip.iconBadgeIconSize == 18)
        #expect(ZenMetricStrip.compactIconBadgeSize == 24)
        #expect(ZenMetricStrip.compactIconBadgeIconSize == 14)
        #expect(ZenMetricStrip.iconBadgeCornerRadius == 8)
        #expect(ZenMetricStrip.contentSpacing == ZenSpacing.xSmall)
        #expect(ZenMetricStrip.textSpacing == 2)
        #expect(ZenMetricStrip.comparisonSpacing == 2)
        #expect(ZenMetricStrip.comparisonIconSize == 10)
    }

    @Test
    func metricStripSupportsConfigurableStyleAndLayout() {
        let gridStrip = ZenMetricStrip(
            values: [
                ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent, iconSource: .asset("CursorClick"))
            ]
        )
        let compactRowStrip = ZenMetricStrip(
            values: [
                ZenMetricValue(label: "CTR", value: "4%", iconSource: .system("percent"))
            ],
            style: .compact,
            layout: .row
        )

        #expect(gridStrip.style == .default)
        #expect(gridStrip.layout == .grid(columns: 2))
        #expect(compactRowStrip.style == .compact)
        #expect(compactRowStrip.layout == .row)
    }

    @Test
    func trendChartAcceptsPrimaryOnlySeriesWithoutCompareValues() {
        let points = [
            ZenTrendPoint(date: baseDate, clicks: 10, impressions: 100, ctr: 10, position: 4),
            ZenTrendPoint(
                date: Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!,
                clicks: 20,
                impressions: 160,
                ctr: 12.5,
                position: 6
            ),
        ]

        let view = ZenTrendChartCard(title: "Trend", points: points)

        _ = view
    }

    @Test
    func trendChartPrefersImpressionsAsAdaptiveBaseMetric() {
        let points = [
            ZenTrendPoint(date: baseDate, clicks: 2, impressions: 120, ctr: 8, position: 4),
            ZenTrendPoint(
                date: Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!,
                clicks: 4,
                impressions: 240,
                ctr: 10,
                position: 6
            ),
        ]

        let scale = ZenTrendChartCard.resolveScale(for: points)

        #expect(scale.baseMetricID == "impressions")
        #expect(scale.isNeutral == false)
        #expect(scale.domain.lowerBound == 120)
        #expect(scale.domain.upperBound == 240)
    }

    @Test
    func trendChartFallsBackToClicksWhenImpressionsAreFlat() {
        let points = [
            ZenTrendPoint(date: baseDate, clicks: 2, impressions: 100, ctr: 8, position: 4),
            ZenTrendPoint(
                date: Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!,
                clicks: 7,
                impressions: 100,
                ctr: 11,
                position: 6
            ),
        ]

        let scale = ZenTrendChartCard.resolveScale(for: points)

        #expect(scale.baseMetricID == "clicks")
        #expect(scale.isNeutral == false)
        #expect(scale.domain.lowerBound == 2)
        #expect(scale.domain.upperBound == 7)
    }

    @Test
    func trendChartUsesNeutralScaleWhenClicksAndImpressionsAreTooWeak() {
        let points = [
            ZenTrendPoint(date: baseDate, clicks: 1, impressions: 100, ctr: 8, position: 4),
            ZenTrendPoint(
                date: Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!,
                clicks: 1,
                impressions: 100,
                ctr: 11,
                position: 6
            ),
        ]

        let scale = ZenTrendChartCard.resolveScale(for: points)

        #expect(scale.baseMetricID == nil)
        #expect(scale.isNeutral)
        #expect(scale.domain.lowerBound == 0)
        #expect(scale.domain.upperBound == 100)
    }

    @Test
    func trendChartProjectionDomainIncludesCompareOutliers() {
        let domain = ZenTrendChartCard.projectionDomain(
            primaryValues: [5, 10],
            compareValues: [3, 12]
        )

        #expect(domain?.lowerBound == 3)
        #expect(domain?.upperBound == 12)
    }

    @Test
    func trendChartProjectsCollapsedZeroDomainToBottomEdge() {
        let projectedValue = ZenTrendChartCard.remappedValueForTesting(
            0,
            from: 0...0,
            to: 0...100
        )

        #expect(projectedValue == 0)
    }

    @Test
    func trendChartProjectsNaNInputToSafeLowerBound() {
        let projectedValue = ZenTrendChartCard.remappedValueForTesting(
            .nan,
            from: 0...10,
            to: 0...100
        )

        #expect(projectedValue.isFinite)
        #expect(projectedValue == 0)
    }

    @Test
    func trendChartUsesMoreVisibleGridStyling() {
        #expect(ZenTrendChartCard.gridLineWidth == 0.75)
        #expect(ZenTrendChartCard.gridLineOpacity == 0.5)
        #expect(ZenTrendChartCard.tickLineOpacity == 0.7)
    }

    @Test
    func segmentedControlSupportsTypedSelectionAndCustomLabels() {
        let view = ZenSegmentedControl(
            title: "Range",
            selection: .constant(PreviewRange.quarter),
            segments: PreviewRange.allCases
        ) { value, isSelected in
            HStack(spacing: 6) {
                if isSelected {
                    ZenIcon(assetName: "Check", size: 12)
                }

                Text(value.rawValue)
            }
        }

        _ = view
    }

    @Test
    func metricsTableCardSupportsIconHeaderAndSegmentedLabels() {
        let view = ZenMetricsTable(
            title: "Queries",
            iconAssetName: "MagnifyingGlass",
            segments: [
                .init(id: "all", count: 12, iconAssetName: "Hash", title: "All"),
                .init(id: "growing", count: 4, iconAssetName: "TrendUp", title: "Growing"),
            ],
            selection: .constant("all")
        ) {
            ZenMetricsTableHeader()
            ZenMetricsTableRow(
                title: "best query",
                leadingAccessory: {
                    ZenIcon(assetName: "Star", size: 12)
                },
                values: .init(clicks: "120", impressions: "4.2K", ctr: "2.9%", position: "3.1")
            )
        }

        _ = view
    }

    @Test
    func metricStripSupportsComparisons() {
        let metric = ZenMetricValue(
            label: "Test",
            value: "100",
            comparisonValue: "+10%",
            trend: .up,
            comparisonLogic: .moreIsBetter
        )
        
        #expect(metric.comparisonValue == "+10%")
        #expect(metric.trend == .up)
        #expect(metric.comparisonLogic == .moreIsBetter)
    }
}
