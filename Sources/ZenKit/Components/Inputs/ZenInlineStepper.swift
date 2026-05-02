import SwiftUI

public struct ZenInlineStepper: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
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
                value = max(range.lowerBound, value - 1)
            }

            Text(label(value))
                .font(.zen(.group, weight: .bold))
                .foregroundStyle(Color.zenTextPrimary)
                .frame(minWidth: 56, alignment: .center)
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.25), value: value)

            stepButton(systemName: "plus", disabled: value >= range.upperBound, cornerRadius: buttonRadius) {
                value = min(range.upperBound, value + 1)
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
                
                .overlay(
                    Group {
                        if cornerRadius >= 14 {
                            Circle()
                                .strokeBorder(Color.zenBorder, lineWidth: 1)
                        } else {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(Color.zenBorder, lineWidth: 1)
                        }
                    }
                )
                .clipShape(
                    cornerRadius >= 14
                        ? AnyShape(Circle())
                        : AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                )
                .background(Color.zenSurfaceMuted)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
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
