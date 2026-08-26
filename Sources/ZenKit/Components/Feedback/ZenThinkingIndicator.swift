import SwiftUI

/// A compact progress signal for work whose duration is unknown, such as agent reasoning.
public struct ZenThinkingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let label: String
    @State private var startedAt = Date.now
    @State private var isAnimating = false

    private static let driveDelays: [Double] = [90, 180, 270, 0, 90, 180, 90, 180, 270]

    public init(label: String = "Thinking…") {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: ZenSpacing.small) {
            grid

            Text(label)
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
                .zenShimmering(active: !reduceMotion)

            TimelineView(.periodic(from: startedAt, by: 0.1)) { context in
                Text(elapsed(since: context.date))
                    .font(.zenGroup)
                    .monospacedDigit()
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("In progress")
        .onAppear {
            guard !reduceMotion else { return }
            isAnimating = true
        }
        .onChange(of: reduceMotion) { _, reduced in
            isAnimating = !reduced
        }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(4), spacing: 1.5), count: 3),
            spacing: 1.5
        ) {
            ForEach(Array(Self.driveDelays.enumerated()), id: \.offset) { index, delay in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Color.zenTextPrimary)
                    .frame(width: 4, height: 4)
                    .opacity(reduceMotion ? 0.15 : (isAnimating ? 0.9 : 0.15))
                    .animation(
                        reduceMotion
                            ? nil
                            : .easeInOut(duration: 0.65)
                                .repeatForever(autoreverses: true)
                                .delay(delay / 1_000),
                        value: isAnimating
                    )
                    .accessibilityHidden(true)
            }
        }
        .frame(width: 15, height: 15)
        .accessibilityHidden(true)
    }

    private func elapsed(since date: Date) -> String {
        let interval = max(0, date.timeIntervalSince(startedAt))
        if interval < 60 { return "\(interval.formatted(.number.precision(.fractionLength(1))))s" }
        return "\(Int(interval / 60))m \((interval.truncatingRemainder(dividingBy: 60)).formatted(.number.precision(.fractionLength(1))))s"
    }
}

#Preview {
    ZenThinkingIndicator(label: "Reviewing your plan")
        .padding()
        .background(Color.zenBackground)
}
