import SwiftUI
import Charts

/// A point in a `ZenAreaChartCard` series.
public struct ZenChartPoint: Identifiable, Equatable, Sendable {
    public let date: Date
    public let value: Double
    public var id: Date { date }

    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

/// Visual weight of a `ZenAreaChartCard`. `.hero` enlarges the headline and the
/// chart so a single card can anchor a screen; `.standard` is the dashboard-grid size.
public enum ZenAreaChartProminence: Sendable {
    case standard
    case hero

    var titleFont: Font { self == .hero ? .zenEyebrow : .zen(.body2) }
    var totalFont: Font { .zen(self == .hero ? .displayL : .displayS, weight: .bold) }
    var chartMinHeight: CGFloat { self == .hero ? 200 : 132 }
    /// Header column width — clamped narrow for the grid size, unconstrained when hero.
    var headerWidth: CGFloat? { self == .hero ? nil : 96 }
}

/// A Cloudflare-dashboard–style metric card: a title and big total on the left,
/// and a filled area + line chart with dashed gridlines on the right.
public struct ZenAreaChartCard: View {
    private let title: String
    private let total: String
    private let points: [ZenChartPoint]
    private let prominence: ZenAreaChartProminence
    private let yLabel: (Double) -> String

    @State private var selectedDate: Date?

    /// - Parameters:
    ///   - title: Metric name (e.g. "Total Requests").
    ///   - total: Formatted headline value (e.g. "10.84k").
    ///   - points: Time series.
    ///   - prominence: Visual weight; `.hero` makes the card a screen anchor.
    ///   - yLabel: Formats a y-axis value into a short label (e.g. "1k", "60%", "10 MB").
    public init(
        title: String,
        total: String,
        points: [ZenChartPoint],
        prominence: ZenAreaChartProminence = .standard,
        yLabel: @escaping (Double) -> String = { $0.formatted(.number.notation(.compactName)) }
    ) {
        self.title = title
        self.total = total
        self.points = points
        self.prominence = prominence
        self.yLabel = yLabel
    }

    private var selectedPoint: ZenChartPoint? {
        guard let selectedDate else { return nil }
        return points.min {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        }
    }

    public var body: some View {
        ZenCard {
            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                    Text(prominence == .hero ? title.uppercased() : title)
                        .font(prominence.titleFont)
                        .foregroundStyle(Color.zenTextMuted)
                    Text(selectedPoint.map { yLabel($0.value) } ?? total)
                        .font(prominence.totalFont)
                        .foregroundStyle(Color.zenTextPrimary)
                        .contentTransition(.numericText())
                    // Reserve the line so scrubbing doesn't shift layout.
                    Text(selectedPoint.map { Self.captionDate($0.date) } ?? " ")
                        .font(.zenEyebrow)
                        .foregroundStyle(Color.zenTextMuted)
                }
                .frame(width: prominence.headerWidth, alignment: .leading)

                chart
            }
        }
    }

    @ViewBuilder
    private var chart: some View {
        if points.isEmpty {
            Text("No data")
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
                .frame(maxWidth: .infinity, minHeight: prominence.chartMinHeight)
        } else {
            Chart {
                ForEach(points) { point in
                    AreaMark(x: .value("Date", point.date), y: .value("Value", point.value))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.zenPrimary.opacity(0.22), Color.zenPrimary.opacity(0.02)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.monotone)
                    LineMark(x: .value("Date", point.date), y: .value("Value", point.value))
                        .foregroundStyle(Color.zenPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.monotone)
                }

                if let selectedPoint {
                    RuleMark(x: .value("Date", selectedPoint.date))
                        .foregroundStyle(Color.zenTextMuted.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    PointMark(x: .value("Date", selectedPoint.date), y: .value("Value", selectedPoint.value))
                        .foregroundStyle(Color.zenPrimary)
                        .symbolSize(80)
                }
            }
            .chartYScale(domain: .automatic(includesZero: true))
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .foregroundStyle(Color.zenBorderSubtle)
                    AxisValueLabel {
                        if let raw = value.as(Double.self) {
                            Text(yLabel(raw))
                                .font(.zenEyebrow)
                                .foregroundStyle(Color.zenTextMuted)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                        .font(.zenEyebrow)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let originX = geo[proxy.plotAreaFrame].origin.x
                                    if let date: Date = proxy.value(atX: value.location.x - originX) {
                                        selectedDate = date
                                    }
                                }
                                .onEnded { _ in selectedDate = nil }
                        )
                }
            }
            .frame(minHeight: prominence.chartMinHeight)
            // Smoothly interpolate the line/area between old and new values when the
            // series updates. Mark identity is stable (ForEach keyed on date), so Charts
            // morphs the y-values rather than snapping.
            .animation(.easeInOut(duration: 0.3), value: points)
        }
    }

    private static func captionDate(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day().hour())
    }
}

#Preview("ZenAreaChartCard") {
    let now = Date(timeIntervalSince1970: 1_750_000_000)
    let points = (0..<8).map { i in
        ZenChartPoint(date: now.addingTimeInterval(Double(i) * 86_400),
                      value: Double(120 + (i * 37) % 90))
    }
    return ZenAreaChartCard(title: "Total Requests", total: "10.84k", points: points)
        .padding()
        .background(Color.zenBackground)
}
