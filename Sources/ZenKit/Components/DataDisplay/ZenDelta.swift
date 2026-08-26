import SwiftUI

/// A signed percent-change indicator: an up/down arrow and the magnitude,
/// tinted success/critical. Shared across stat tiles and resource cards so the
/// "+/- vs previous period" styling stays consistent.
///
/// Colour follows *meaning*, not direction: by default an increase is good
/// (green up, red down). For metrics where rising is bad — errors, latency,
/// cost — pass `increaseIsGood: false` to flip the colour while keeping the
/// arrow pointing the real direction.
public struct ZenDelta: View {
    /// Visual scale. `.regular` matches `ZenStatTile`; `.small` fits the compact
    /// metric row inside a `ZenLayerCard`.
    public enum Size {
        case small
        case regular

        var arrowSize: CGFloat { self == .small ? 7 : 9 }
        var spacing: CGFloat { self == .small ? 0 : 1 }
        var fractionDigits: Int { self == .small ? 0 : 1 }
    }

    private let percent: Double
    private let increaseIsGood: Bool
    private let size: Size

    /// - Parameters:
    ///   - percent: Signed percent change (e.g. `43.0` or `-74.5`).
    ///   - increaseIsGood: When true (default) an increase is tinted success; set
    ///     false for metrics where rising is bad (errors, latency, cost).
    ///   - size: Visual scale.
    public init(percent: Double, increaseIsGood: Bool = true, size: Size = .regular) {
        self.percent = percent
        self.increaseIsGood = increaseIsGood
        self.size = size
    }

    public var body: some View {
        let up = percent >= 0
        let good = up == increaseIsGood
        HStack(spacing: size.spacing) {
            ZenIcon(icon: up ? .arrowUp : .arrowDown, size: 12)
                .font(.system(size: size.arrowSize, weight: .bold))
            Text(magnitude)
                .font(textFont)
                .monospacedDigit()
        }
        .foregroundStyle(good ? Color.zenSuccess : Color.zenCritical)
        .lineLimit(1)
    }

    private var magnitude: String {
        String(format: "%.\(size.fractionDigits)f%%", abs(percent))
    }

    private var textFont: Font {
        switch size {
        case .small: .system(size: 9, weight: .semibold)
        case .regular: .zenGroup
        }
    }
}

#if canImport(UIKit)
#Preview("ZenDelta") {
    VStack(alignment: .leading, spacing: ZenSpacing.large) {
        HStack(spacing: ZenSpacing.large) {
            ZenDelta(percent: 43.0)
            ZenDelta(percent: -74.5)
            ZenDelta(percent: 12.3, increaseIsGood: false)
            ZenDelta(percent: -8.0, increaseIsGood: false)
        }
        HStack(spacing: ZenSpacing.large) {
            ZenDelta(percent: 43.0, size: .small)
            ZenDelta(percent: -74.5, size: .small)
            ZenDelta(percent: 12.3, increaseIsGood: false, size: .small)
            ZenDelta(percent: -8.0, increaseIsGood: false, size: .small)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
#endif
