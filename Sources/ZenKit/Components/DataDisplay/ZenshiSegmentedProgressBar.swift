import SwiftUI

/// A step-based progress bar that looks like discrete segments but animates
/// via a smooth underlying fill bar shaped by a segment mask.
public struct ZenSegmentedProgressBar: View {
    public let current: Int
    public let total: Int

    public init(current: Int, total: Int) {
        self.current = max(0, min(current, total))
        self.total = max(1, total)
    }

    private var progress: Double { Double(current) / Double(total) }

    @ViewBuilder
    private func segments() -> some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedFullyRoundedCornerRadius(for: 4)
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { _ in
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            }
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Color.zenBorder  // fills full GeometryReader width, anchors ZStack size
                Color.zenPrimary
                    .frame(width: proxy.size.width * progress)
                    .animation(.spring(duration: 0.45, bounce: 0.1), value: current)
            }
            .mask(segments())  // mask now spans the full track width
        }
        .frame(height: 4)
        .accessibilityValue(Text("Step \(current) of \(total)"))
    }
}

private struct SegmentedProgressBarPreview: View {
    @State private var current = 1
    let total = 5

    var body: some View {
        VStack(spacing: ZenSpacing.large) {
            ZenSegmentedProgressBar(current: current, total: total)
                .padding(.horizontal, ZenSpacing.large)

            HStack(spacing: ZenSpacing.small) {
                Button("−") { if current > 0 { current -= 1 } }
                Text("\(current) / \(total)")
                    .font(.zenTextSM.weight(.medium))
                    .foregroundStyle(Color.zenTextPrimary)
                    .frame(width: 60)
                Button("+") { if current < total { current += 1 } }
            }
            .font(.zenTextSM)
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    SegmentedProgressBarPreview()
}
