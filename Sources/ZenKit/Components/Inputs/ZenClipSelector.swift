import SwiftUI

/// A video-trimmer–style range selector: tick labels on top, and below them a
/// track with a draggable, resizable "clip" window (accent frame + grip handles).
///
/// Drag a handle to trim either edge, or drag the middle to move the whole clip.
/// Selection is a pair of mark indices (`lower`, `upper`) with `lower < upper`.
public struct ZenClipSelector: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenHapticsOverride) private var hapticsOverride

    @Binding private var lower: Int
    @Binding private var upper: Int
    private let labels: [String]
    private let accent: Color?

    @State private var width: CGFloat = 0
    @State private var drag: DragState?

    private let edgeInset: CGFloat = 26
    private let trackHeight: CGFloat = 44
    private let gripWidth: CGFloat = 16
    private let grabThreshold: CGFloat = 32

    private enum DragState { case lower, upper, move(startX: CGFloat, startLower: Int, startUpper: Int) }

    public init(lower: Binding<Int>, upper: Binding<Int>, labels: [String], accent: Color? = nil) {
        self._lower = lower
        self._upper = upper
        self.labels = labels
        self.accent = accent
    }

    private var marks: Int { labels.count }
    private var span: CGFloat { max(width - edgeInset * 2, 1) }
    private var step: CGFloat { marks > 1 ? span / CGFloat(marks - 1) : span }
    private func x(_ index: Int) -> CGFloat { edgeInset + step * CGFloat(index) }
    private func nearestIndex(_ position: CGFloat) -> Int {
        min(max(Int(((position - edgeInset) / step).rounded()), 0), marks - 1)
    }
    private var accentColor: Color { accent ?? .zenAccent }

    public var body: some View {
        VStack(spacing: ZenSpacing.xSmall) {
            labelRow
            track
        }
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { width = proxy.size.width }
                    .onChange(of: proxy.size.width) { width = $0 }
            }
        )
    }

    private var labelRow: some View {
        ZStack(alignment: .leading) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                let inside = index >= lower && index <= upper
                Text(label)
                    .font(.zen(.group, weight: inside ? .semibold : .regular))
                    .foregroundStyle(inside ? Color.zenTextPrimary : Color.zenTextMuted)
                    .fixedSize()
                    .position(x: x(index), y: 8)
            }
        }
        .frame(height: 16)
        .frame(maxWidth: .infinity)
    }

    private var track: some View {
        let radius = ZenTheme.current.resolvedCornerRadius(for: .container, parentRadius: nil)
        let leftX = x(lower)
        let rightX = x(upper)
        let windowRadius = max(radius - 6, 6)

        return ZStack {
            // Tick marks.
            ForEach(0..<marks, id: \.self) { index in
                Capsule()
                    .fill(Color.zenBorder)
                    .frame(width: 1.5, height: 12)
                    .position(x: x(index), y: trackHeight / 2)
            }

            if width > 0 {
                // Clip window.
                RoundedRectangle(cornerRadius: windowRadius, style: .continuous)
                    .fill(accentColor.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: windowRadius, style: .continuous)
                            .strokeBorder(accentColor, lineWidth: 2.5)
                    )
                    .frame(width: max(rightX - leftX, gripWidth), height: trackHeight - 8)
                    .position(x: (leftX + rightX) / 2, y: trackHeight / 2)

                grip.position(x: leftX, y: trackHeight / 2)
                grip.position(x: rightX, y: trackHeight / 2)
            }
        }
        .frame(height: trackHeight)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.zenSurfaceMuted)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color.zenBorder, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .animation(animation, value: lower)
        .animation(animation, value: upper)
    }

    private var grip: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(accentColor)
            .frame(width: gripWidth, height: trackHeight - 4)
            .overlay(
                HStack(spacing: 2.5) {
                    Capsule().fill(Color.white.opacity(0.95)).frame(width: 1.5, height: 14)
                    Capsule().fill(Color.white.opacity(0.95)).frame(width: 1.5, height: 14)
                }
            )
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard step > 0 else { return }
                let mode = drag ?? resolveMode(start: value.startLocation.x)
                if drag == nil { drag = mode }
                apply(mode: mode, x: value.location.x)
            }
            .onEnded { _ in drag = nil }
    }

    private func resolveMode(start: CGFloat) -> DragState {
        if abs(start - x(lower)) <= grabThreshold { return .lower }
        if abs(start - x(upper)) <= grabThreshold { return .upper }
        if start > x(lower) && start < x(upper) {
            return .move(startX: start, startLower: lower, startUpper: upper)
        }
        return abs(start - x(lower)) < abs(start - x(upper)) ? .lower : .upper
    }

    private func apply(mode: DragState, x position: CGFloat) {
        switch mode {
        case .lower:
            set(lower: min(nearestIndex(position), upper - 1))
        case .upper:
            set(upper: max(nearestIndex(position), lower + 1))
        case let .move(startX, startLower, startUpper):
            let delta = Int(((position - startX) / step).rounded())
            let widthIdx = startUpper - startLower
            let newLower = min(max(startLower + delta, 0), marks - 1 - widthIdx)
            set(lower: newLower, upper: newLower + widthIdx)
        }
    }

    private func set(lower newLower: Int? = nil, upper newUpper: Int? = nil) {
        var changed = false
        if let newLower, newLower != lower, newLower >= 0 { lower = newLower; changed = true }
        if let newUpper, newUpper != upper, newUpper <= marks - 1 { upper = newUpper; changed = true }
        if changed { ZenHapticEngine.perform(.selectionChange, haptics: hapticsOverride) }
    }

    private var animation: Animation {
        (reduceMotion || ZenTheme.current.motion == .reduced)
            ? .easeInOut(duration: 0.16)
            : .spring(response: 0.26, dampingFraction: 0.86)
    }
}

#Preview("ZenClipSelector") {
    struct ClipPreview: View {
        @State private var lower = 2
        @State private var upper = 5

        var body: some View {
            VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                ZenClipSelector(
                    lower: $lower,
                    upper: $upper,
                    labels: ["30d", "7d", "24h", "6h", "1h", "now"]
                )

                Text("Selected: \(lower) – \(upper)")
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return ClipPreview()
}
