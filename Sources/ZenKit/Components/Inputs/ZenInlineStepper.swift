import SwiftUI

private struct ButtonShape: InsettableShape {
    let cornerRadius: CGFloat
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        return cornerRadius >= 14
            ? Circle().path(in: r)
            : RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).path(in: r)
    }

    func inset(by amount: CGFloat) -> ButtonShape {
        var s = self; s.insetAmount += amount; return s
    }
}

public struct ZenInlineStepper: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Environment(\.zenHapticsOverride) private var hapticsOverride
    @Binding private var value: Int
    private let range: ClosedRange<Int>
    private let label: (Int) -> String

    public init(
        value: Binding<Int>,
        in range: ClosedRange<Int> = 1...99,
        label: @escaping (Int) -> String = { "\($0)" }
    ) {
        _value = value
        self.range = range
        self.label = label
    }

    public var body: some View {
        let theme = ZenTheme.current
        let containerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let buttonRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: containerRadius)

        return HStack(spacing: ZenSpacing.xSmall) {
            stepButton(systemName: "minus", disabled: value <= range.lowerBound, cornerRadius: buttonRadius) {
                decrement()
            }

            Text(label(value))
                .font(.zen(.group, weight: .bold))
                .foregroundStyle(Color.zenTextPrimary)
                .frame(minWidth: 56, alignment: .center)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.25), value: value)

            stepButton(systemName: "plus", disabled: value >= range.upperBound, cornerRadius: buttonRadius) {
                increment()
            }
        }
        .padding(ZenSpacing.xSmall)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: containerRadius, style: .continuous)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: containerRadius, style: .continuous))
    }

    private func stepButton(systemName: String, disabled: Bool, cornerRadius: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(disabled ? Color.zenBorder : Color.zenTextPrimary)
                .frame(width: 28, height: 28)
                
                .background(Color.zenSurfaceMuted)
                .clipShape(ButtonShape(cornerRadius: cornerRadius))
                .overlay(ButtonShape(cornerRadius: cornerRadius).strokeBorder(Color.zenBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func increment() {
        guard value < range.upperBound else {
            ZenHapticEngine.perform(.limitReached, haptics: hapticsOverride)
            return
        }

        ZenHapticEngine.perform(.valueChange, haptics: hapticsOverride)
        value = min(range.upperBound, value + 1)
    }

    private func decrement() {
        guard value > range.lowerBound else {
            ZenHapticEngine.perform(.limitReached, haptics: hapticsOverride)
            return
        }

        ZenHapticEngine.perform(.valueChange, haptics: hapticsOverride)
        value = max(range.lowerBound, value - 1)
    }
}

#Preview {
    struct Preview: View {
        @State private var servings = 4

        var body: some View {
            ZenInlineStepper(value: $servings, in: 1...20) { "\($0) serves" }
                .padding()
                .background(Color.zenBackground)
        }
    }
    return Preview()
}
