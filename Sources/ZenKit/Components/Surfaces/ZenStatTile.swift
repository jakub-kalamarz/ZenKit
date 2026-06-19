import SwiftUI
import Charts

/// A compact stat tile: a title (with optional menu), a headline value and a
/// signed delta, and a sparkline. Sized for a dashboard grid.
public struct ZenStatTile: View {
    private let title: String
    private let value: String
    private let deltaPercent: Double?
    private let points: [Double]
    private let onMenu: (() -> Void)?

    /// - Parameters:
    ///   - title: Metric name.
    ///   - value: Formatted headline value (e.g. "998", "2.43 MB").
    ///   - deltaPercent: Signed percent change vs the previous period (nil hides it).
    ///   - points: Sparkline values in time order.
    ///   - onMenu: Optional handler for the "…" menu button.
    public init(
        title: String,
        value: String,
        deltaPercent: Double? = nil,
        points: [Double],
        onMenu: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.deltaPercent = deltaPercent
        self.points = points
        self.onMenu = onMenu
    }

    public var body: some View {
        ZenCard {
            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                HStack {
                    Text(title)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(Color.zenTextMuted)
                        .lineLimit(1)
                    Spacer(minLength: ZenSpacing.xSmall)
                    if let onMenu {
                        Button(action: onMenu) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.zenTextMuted)
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: ZenSpacing.xSmall) {
                    Text(value)
                        .font(.zen(.stat, weight: .bold))
                        .foregroundStyle(Color.zenTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let deltaPercent { ZenDelta(percent: deltaPercent) }
                }

                sparkline
            }
        }
    }

    @ViewBuilder
    private var sparkline: some View {
        if points.count < 2 {
            Color.clear.frame(height: 36)
        } else {
            Chart(Array(points.enumerated()), id: \.offset) { index, value in
                LineMark(x: .value("i", index), y: .value("v", value))
                    .foregroundStyle(Color.zenPrimary)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .interpolationMethod(.monotone)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 36)
        }
    }
}

#Preview("ZenStatTile") {
    let points = [3.0, 5, 4, 8, 6, 20, 7, 5, 9, 30, 8, 6]
    return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        ZenStatTile(title: "Total Requests", value: "998", deltaPercent: 43.0, points: points)
        ZenStatTile(title: "Cache Hit Rate", value: "3.11%", deltaPercent: -74.5, points: points)
    }
    .padding()
    .background(Color.zenBackground)
}
