import Charts
import SwiftUI

public struct ZenTrendPoint: Equatable, Sendable, Identifiable {
    public let date: Date
    public let clicks: Double?
    public let impressions: Double?
    public let ctr: Double?
    public let position: Double?
    public let compareClicks: Double?
    public let compareImpressions: Double?
    public let compareCTR: Double?
    public let comparePosition: Double?

    public var id: Date { date }

    public init(
        date: Date,
        clicks: Double? = nil,
        impressions: Double? = nil,
        ctr: Double? = nil,
        position: Double? = nil,
        compareClicks: Double? = nil,
        compareImpressions: Double? = nil,
        compareCTR: Double? = nil,
        comparePosition: Double? = nil
    ) {
        self.date = date
        self.clicks = clicks
        self.impressions = impressions
        self.ctr = ctr
        self.position = position
        self.compareClicks = compareClicks
        self.compareImpressions = compareImpressions
        self.compareCTR = compareCTR
        self.comparePosition = comparePosition
    }
}

public struct ZenTrendChartCard: View {
    private enum ChartSpacing {
        static let xStartPadding: CGFloat = 12
        static let xEndPadding: CGFloat = 20
    }

    static let gridLineWidth: CGFloat = 0.75
    static let gridLineOpacity: Double = 0.5
    static let tickLineWidth: CGFloat = 0.5
    static let tickLineOpacity: Double = 0.7

    struct AdaptiveScale: Equatable {
        let baseMetricID: String?
        let domain: ClosedRange<Double>

        var isNeutral: Bool {
            baseMetricID == nil
        }
    }

    static func projectionDomain(primaryValues: [Double], compareValues: [Double]) -> ClosedRange<Double>? {
        let finiteValues = (primaryValues + compareValues).filter(\.isFinite)
        guard !finiteValues.isEmpty else { return nil }
        let minimum = finiteValues.min() ?? 0
        let maximum = finiteValues.max() ?? 0
        return minimum...maximum
    }

    private struct MetricDescriptor {
        let id: String
        let title: String
        let color: Color
        let primaryValue: (ZenTrendPoint) -> Double?
        let compareValue: (ZenTrendPoint) -> Double?
    }

    private struct ChartSeriesPoint: Identifiable {
        let id: String
        let date: Date
        let series: String
        let value: Double
        let color: Color
        let lineStyle: StrokeStyle
    }

    private struct LegendItem: Identifiable {
        let id: String
        let title: String
        let color: Color
    }

    private let title: String?
    private let points: [ZenTrendPoint]
    private let metrics: [MetricDescriptor] = [
        MetricDescriptor(
            id: "clicks",
            title: "Clicks",
            color: .zenMetricClicks,
            primaryValue: { $0.clicks },
            compareValue: { $0.compareClicks }
        ),
        MetricDescriptor(
            id: "impressions",
            title: "Impr.",
            color: .zenMetricImpressions,
            primaryValue: { $0.impressions },
            compareValue: { $0.compareImpressions }
        ),
        MetricDescriptor(
            id: "ctr",
            title: "CTR",
            color: .zenMetricCtr,
            primaryValue: { $0.ctr },
            compareValue: { $0.compareCTR }
        ),
        MetricDescriptor(
            id: "position",
            title: "Pos.",
            color: .zenMetricPosition,
            primaryValue: { $0.position },
            compareValue: { $0.comparePosition }
        ),
    ]

    public init(title: String? = nil, points: [ZenTrendPoint]) {
        self.title = title
        self.points = points
    }

    public var body: some View {
        let theme = ZenTheme.current
        let scale = Self.resolveScale(for: points)
        let seriesPoints = chartSeriesPoints(scale: scale)

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            if let title {
                Text(title)
                    .font(.zenTextSM.weight(.medium))
                    .foregroundStyle(Color.zenTextPrimary)
            }

            Chart(seriesPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Trend", point.value),
                    series: .value("Series", point.series)
                )
                .interpolationMethod(.linear)
                .lineStyle(point.lineStyle)
                .foregroundStyle(point.color)
            }
            .chartXScale(
                range: .plotDimension(
                    startPadding: ChartSpacing.xStartPadding,
                    endPadding: ChartSpacing.xEndPadding
                )
            )
            .chartYScale(domain: scale.domain)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: Self.gridLineWidth))
                        .foregroundStyle(Color.zenBorder.opacity(Self.gridLineOpacity))
                    AxisTick(stroke: StrokeStyle(lineWidth: Self.tickLineWidth))
                        .foregroundStyle(Color.zenBorder.opacity(Self.tickLineOpacity))
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: false)
                        .font(.zenTextXS)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: Self.gridLineWidth))
                        .foregroundStyle(Color.zenBorder.opacity(Self.gridLineOpacity))

                    if !scale.isNeutral,
                       let axisValue = value.as(Double.self),
                       let label = axisLabel(for: axisValue)
                    {
                        AxisTick(stroke: StrokeStyle(lineWidth: Self.tickLineWidth))
                            .foregroundStyle(Color.zenBorder.opacity(Self.tickLineOpacity))
                        AxisValueLabel {
                            Text(label)
                                .font(.zenTextXS)
                                .foregroundStyle(Color.zenTextMuted)
                        }
                    }
                }
            }
            .allowsHitTesting(false)
            .frame(height: 160)
            .animation(.easeInOut(duration: 0.24), value: points)
            .animation(.easeInOut(duration: 0.24), value: scale)

            HStack(spacing: ZenSpacing.small) {
                ForEach(legendItems) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 7, height: 7)
                        Text(item.title)
                            .font(.zenTextXS)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }
        }
        .padding(theme.resolvedMetrics.cardPadding)
        .clipShape(RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.medium)))
    }

    var xAxisStride: Int {
        guard let first = points.first?.date, let last = points.last?.date else { return 1 }
        let totalDays = Calendar.current.dateComponents([.day], from: first, to: last).day ?? 1
        return max(1, totalDays / 4)
    }

    private var legendItems: [LegendItem] {
        metrics.map { metric in
            LegendItem(id: metric.id, title: metric.title, color: metric.color)
        }
    }

    static func resolveScale(for points: [ZenTrendPoint]) -> AdaptiveScale {
        if let domain = semanticDomain(for: points.flatMap { point in
            [point.impressions, point.compareImpressions].compactMap { $0 }
        }) {
            return AdaptiveScale(baseMetricID: "impressions", domain: domain)
        }

        if let domain = semanticDomain(for: points.flatMap { point in
            [point.clicks, point.compareClicks].compactMap { $0 }
        }) {
            return AdaptiveScale(baseMetricID: "clicks", domain: domain)
        }

        return AdaptiveScale(baseMetricID: nil, domain: neutralDomain)
    }

    private func chartSeriesPoints(scale: AdaptiveScale) -> [ChartSeriesPoint] {
        metrics.flatMap { metric -> [ChartSeriesPoint] in
            let primaryValues = points.compactMap(metric.primaryValue)
            let compareValues = points.compactMap(metric.compareValue)
            guard let sourceDomain = Self.projectionDomain(
                primaryValues: primaryValues,
                compareValues: compareValues
            ) else {
                return []
            }

            let primarySeries = points.compactMap { point -> ChartSeriesPoint? in
                guard let rawValue = metric.primaryValue(point) else { return nil }
                guard let projectedValue = safeProjectedValue(
                    rawValue,
                    metricID: metric.id,
                    sourceDomain: sourceDomain,
                    scale: scale
                ) else {
                    return nil
                }
                return ChartSeriesPoint(
                    id: "\(metric.id)-primary-\(point.date.timeIntervalSinceReferenceDate)",
                    date: point.date,
                    series: metric.title,
                    value: projectedValue,
                    color: metric.color,
                    lineStyle: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }

            let compareSeries = points.compactMap { point -> ChartSeriesPoint? in
                guard let rawValue = metric.compareValue(point) else { return nil }
                guard let projectedValue = safeProjectedValue(
                    rawValue,
                    metricID: metric.id,
                    sourceDomain: sourceDomain,
                    scale: scale
                ) else {
                    return nil
                }
                return ChartSeriesPoint(
                    id: "\(metric.id)-compare-\(point.date.timeIntervalSinceReferenceDate)",
                    date: point.date,
                    series: "\(metric.title) Compare",
                    value: projectedValue,
                    color: metric.color.opacity(0.7),
                    lineStyle: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round, dash: [4, 4])
                )
            }

            return primarySeries + compareSeries
        }
    }

    private static let neutralDomain: ClosedRange<Double> = 0...100

    private static func semanticDomain(for values: [Double]) -> ClosedRange<Double>? {
        let finiteValues = values.filter(\.isFinite)
        guard finiteValues.count >= 2 else { return nil }
        let minimum = finiteValues.min() ?? 0
        let maximum = finiteValues.max() ?? 0
        guard maximum > minimum else { return nil }
        return minimum...maximum
    }

    private func projectedValue(
        _ value: Double,
        metricID: String,
        sourceDomain: ClosedRange<Double>,
        scale: AdaptiveScale
    ) -> Double {
        if scale.isNeutral {
            return normalizedValue(value, domain: sourceDomain)
        }

        if metricID == scale.baseMetricID {
            return value
        }

        return remappedValue(value, from: sourceDomain, to: scale.domain)
    }

    private func safeProjectedValue(
        _ value: Double,
        metricID: String,
        sourceDomain: ClosedRange<Double>,
        scale: AdaptiveScale
    ) -> Double? {
        let projected = projectedValue(
            value,
            metricID: metricID,
            sourceDomain: sourceDomain,
            scale: scale
        )
        return projected.isFinite ? projected : nil
    }

    private func normalizedValue(_ value: Double, domain: ClosedRange<Double>) -> Double {
        Self.remappedValueForTesting(value, from: domain, to: Self.neutralDomain)
    }

    private func remappedValue(
        _ value: Double,
        from sourceDomain: ClosedRange<Double>,
        to targetDomain: ClosedRange<Double>
    ) -> Double {
        Self.remappedValueForTesting(value, from: sourceDomain, to: targetDomain)
    }

    static func remappedValueForTesting(
        _ value: Double,
        from sourceDomain: ClosedRange<Double>,
        to targetDomain: ClosedRange<Double>
    ) -> Double {
        let sourceLowerBound = sourceDomain.lowerBound
        let sourceUpperBound = sourceDomain.upperBound
        let targetLowerBound = targetDomain.lowerBound
        let targetUpperBound = targetDomain.upperBound

        guard value.isFinite,
              sourceLowerBound.isFinite,
              sourceUpperBound.isFinite,
              targetLowerBound.isFinite,
              targetUpperBound.isFinite
        else {
            return targetLowerBound.isFinite ? targetLowerBound : 0
        }

        guard sourceUpperBound > sourceLowerBound else {
            return targetLowerBound
        }

        let normalized = (value - sourceLowerBound) / (sourceUpperBound - sourceLowerBound)
        guard normalized.isFinite else {
            return targetLowerBound
        }

        let remapped = targetLowerBound + (normalized * (targetUpperBound - targetLowerBound))
        return remapped.isFinite ? remapped : targetLowerBound
    }

    private func axisLabel(for value: Double) -> String? {
        guard value.isFinite, value > 0 else { return nil }
        if value >= 1_000_000 {
            return "\(trimmedNumber(value / 1_000_000))M"
        }
        if value >= 1_000 {
            return "\(trimmedNumber(value / 1_000))K"
        }
        return trimmedNumber(value)
    }

    private func trimmedNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = value < 10 ? 1 : 0
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

#Preview {
    let calendar = Calendar.current
    let base = calendar.date(from: DateComponents(year: 2025, month: 3, day: 1))!

    ZenTrendChartCard(
        title: "Trend",
        points: [
            ZenTrendPoint(
                date: base,
                clicks: 10,
                impressions: 110,
                ctr: 9.1,
                position: 3,
                compareClicks: 8,
                compareImpressions: 100,
                compareCTR: 8,
                comparePosition: 1
            ),
            ZenTrendPoint(
                date: calendar.date(byAdding: .day, value: 1, to: base)!,
                clicks: 22,
                impressions: 140,
                ctr: 15.7,
                position: 5,
                compareClicks: 19,
                compareImpressions: 132,
                compareCTR: 14.4,
                comparePosition: 3
            ),
            ZenTrendPoint(
                date: calendar.date(byAdding: .day, value: 2, to: base)!,
                clicks: 14,
                impressions: 120,
                ctr: 11.7,
                position: 4,
                compareClicks: 11,
                compareImpressions: 112,
                compareCTR: 9.8,
                comparePosition: 2
            ),
            ZenTrendPoint(
                date: calendar.date(byAdding: .day, value: 3, to: base)!,
                clicks: 30,
                impressions: 180,
                ctr: 16.7,
                position: 7,
                compareClicks: 24,
                compareImpressions: 165,
                compareCTR: 14.5,
                comparePosition: 5
            ),
        ]
    )
    .padding()
    .background(Color.zenBackground)
}
