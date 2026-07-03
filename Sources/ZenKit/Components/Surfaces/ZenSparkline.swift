import SwiftUI
import Charts

/// A compact inline line chart (sparkline) sized for stat tiles and cards.
///
/// Animates between value sets when the series updates (the line morphs rather
/// than snapping), draws itself in left-to-right the first time data appears,
/// and replays that draw-in when tapped — so a tap re-animates the data.
public struct ZenSparkline: View {
    private let points: [Double]
    private let color: Color
    private let lineWidth: CGFloat

    /// 0 → fully hidden, 1 → fully drawn. Animated to reveal the line left-to-right.
    @State private var revealProgress: CGFloat = 0

    /// - Parameters:
    ///   - points: Sparkline values in time order. Fewer than two renders blank.
    ///   - color: Line colour. Defaults to the theme's primary.
    ///   - lineWidth: Stroke width. Defaults to 1.5.
    public init(points: [Double], color: Color = .zenPrimary, lineWidth: CGFloat = 1.5) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }

    private var isDrawable: Bool { points.count >= 2 }

    public var body: some View {
        chart
            .mask(alignment: .leading) {
                GeometryReader { geo in
                    Rectangle().frame(width: geo.size.width * revealProgress)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { reveal() }
            .onAppear { if isDrawable { reveal() } }
            // Draw the line in once real data first arrives after a loading state.
            .onChange(of: isDrawable) { _, drawable in if drawable { reveal() } }
    }

    /// Replays the left-to-right draw-in from the start.
    private func reveal() {
        revealProgress = 0
        withAnimation(.easeOut(duration: 0.6)) { revealProgress = 1 }
    }

    @ViewBuilder
    private var chart: some View {
        if isDrawable {
            Chart(Array(points.enumerated()), id: \.offset) { index, value in
                LineMark(x: .value("i", index), y: .value("v", value))
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.monotone)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            // Mark identity is stable (keyed on index), so Charts morphs the y-values
            // between updates instead of snapping.
            .animation(.easeInOut(duration: 0.3), value: points)
        } else {
            Color.clear
        }
    }
}

#Preview("ZenSparkline") {
    struct SparkPreview: View {
        @State private var points: [Double] = [3, 5, 4, 8, 6, 20, 7, 5, 9, 30, 8, 6]

        var body: some View {
            VStack(spacing: ZenSpacing.large) {
                ZenSparkline(points: points)
                    .frame(height: 36)
                Button("Shuffle data") {
                    points = (0..<12).map { _ in Double(Int.random(in: 2...30)) }
                }
                .font(.zenBody2)
                Text("Tap the chart to replay the draw-in.")
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
            }
            .padding()
            .background(Color.zenBackground)
        }
    }
    return SparkPreview()
}
