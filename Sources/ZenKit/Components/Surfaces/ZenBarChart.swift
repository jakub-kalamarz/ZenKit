import SwiftUI
import Charts

/// One stacked segment of a `ZenBarPoint` (e.g. "success", "errors").
public struct ZenBarSegment: Identifiable, Equatable, Sendable {
    public let id: String
    public let value: Double
    public let color: Color

    public init(id: String, value: Double, color: Color) {
        self.id = id
        self.value = value
        self.color = color
    }
}

/// A single bar in a `ZenBarChart`: a date bucket with one or more stacked segments.
public struct ZenBarPoint: Identifiable, Equatable, Sendable {
    public let date: Date
    public let segments: [ZenBarSegment]
    public var id: Date { date }
    public var total: Double { segments.reduce(0) { $0 + $1.value } }

    public init(date: Date, segments: [ZenBarSegment]) {
        self.date = date
        self.segments = segments
    }

    /// A single-segment bar — the common case for a plain volume series.
    public static func single(date: Date, value: Double, id: String = "Requests", color: Color = .zenPrimary) -> ZenBarPoint {
        ZenBarPoint(date: date, segments: [ZenBarSegment(id: id, value: value, color: color)])
    }
}

/// A bar chart of stacked, time-bucketed values with tappable bars.
///
/// Tapping a bar drives `selection` (toggles off when the same bar is tapped
/// again); unselected bars dim so the active bucket stands out. Use the binding
/// to filter an adjacent list/table by the chosen bucket.
public struct ZenBarChart: View {
    private let points: [ZenBarPoint]
    private let unit: Calendar.Component
    private let yLabel: (Double) -> String
    private let xFormat: Date.FormatStyle
    private let minHeight: CGFloat
    @Binding private var selection: Date?

    /// - Parameters:
    ///   - points: Time-bucketed bars, each with stacked segments.
    ///   - unit: Calendar unit each bar spans (controls bar width). Defaults to `.hour`.
    ///   - yLabel: Formats a y-axis value into a short label.
    ///   - xFormat: Date format for x-axis labels. Defaults to hour-of-day.
    ///   - minHeight: Plot height. Defaults to 150.
    ///   - selection: The date of the tapped bar, or `nil` when nothing is selected.
    public init(
        points: [ZenBarPoint],
        unit: Calendar.Component = .hour,
        yLabel: @escaping (Double) -> String = { $0.formatted(.number.notation(.compactName)) },
        xFormat: Date.FormatStyle = .dateTime.hour(),
        minHeight: CGFloat = 150,
        selection: Binding<Date?> = .constant(nil)
    ) {
        self.points = points
        self.unit = unit
        self.yLabel = yLabel
        self.xFormat = xFormat
        self.minHeight = minHeight
        self._selection = selection
    }

    public var body: some View {
        if points.isEmpty {
            Text("No data")
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
                .frame(maxWidth: .infinity, minHeight: minHeight)
        } else {
            chart
        }
    }

    private func isDimmed(_ point: ZenBarPoint) -> Bool {
        guard let selection else { return false }
        return point.date != selection
    }

    @ChartContentBuilder
    private func bars(for point: ZenBarPoint) -> some ChartContent {
        let opacity: Double = isDimmed(point) ? 0.25 : 1
        ForEach(point.segments) { segment in
            BarMark(
                x: .value("Time", point.date, unit: unit),
                y: .value(segment.id, segment.value)
            )
            .foregroundStyle(segment.color.opacity(opacity))
            .cornerRadius(2)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(points) { point in
                bars(for: point)
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
                AxisValueLabel(format: xFormat)
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
                            .onEnded { value in
                                let originX = geo[proxy.plotAreaFrame].origin.x
                                guard let tapped: Date = proxy.value(atX: value.location.x - originX) else { return }
                                guard let nearest = points.min(by: {
                                    abs($0.date.timeIntervalSince(tapped)) < abs($1.date.timeIntervalSince(tapped))
                                }) else { return }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selection = (selection == nearest.date) ? nil : nearest.date
                                }
                            }
                    )
            }
        }
        .frame(minHeight: minHeight)
        .animation(.easeInOut(duration: 0.3), value: points)
    }
}

#Preview("ZenBarChart") {
    struct BarPreview: View {
        @State private var selection: Date?
        let points: [ZenBarPoint] = {
            let now = Date(timeIntervalSince1970: 1_750_000_000)
            return (0..<12).map { (i: Int) -> ZenBarPoint in
                let date = now.addingTimeInterval(Double(i) * 3600)
                let success = Double(20 + (i * 13) % 60)
                let errors = Double((i * 7) % 9)
                let segments = [
                    ZenBarSegment(id: "Success", value: success, color: .zenPrimary),
                    ZenBarSegment(id: "Errors", value: errors, color: .zenCritical),
                ]
                return ZenBarPoint(date: date, segments: segments)
            }
        }()

        var body: some View {
            ZenCard {
                ZenBarChart(points: points, selection: $selection)
            }
            .padding()
            .background(Color.zenBackground)
        }
    }
    return BarPreview()
}
