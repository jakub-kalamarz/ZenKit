import SwiftUI

public struct ZenStepper: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    private let leadingIconSource: ZenIconSource?
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let format: (Double) -> String

    public init(
        _ title: String,
        subtitle: String? = nil,
        leadingIconSource: ZenIconSource? = nil,
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        format: @escaping (Double) -> String = { v in
            v.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(v)) : String(format: "%.1f", v)
        }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIconSource = leadingIconSource
        _value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let buttonRadius = theme.resolvedCornerRadius(for: ZenRadius.small)
        let controlStyle = ZenControlSurfaceStyle.outline(theme: theme)

        HStack(spacing: ZenSpacing.small) {
            if let iconSource = leadingIconSource {
                ZenIcon(source: iconSource, size: 22)
                    .frame(width: 40, height: 40)
                    .background(Color.zenSurfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zenTextSM.weight(.semibold))
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenTextXS)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            Spacer(minLength: ZenSpacing.small)

            HStack(spacing: ZenSpacing.xSmall) {
                stepButton(systemName: "minus", action: decrement, disabled: value <= range.lowerBound, cornerRadius: buttonRadius)

                Text(format(value))
                    .font(.zenTextLG.weight(.semibold))
                    .foregroundStyle(Color.zenTextPrimary)
                    .monospacedDigit()
                    .frame(minWidth: 52, alignment: .center)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.3), value: value)

                stepButton(systemName: "plus", action: increment, disabled: value >= range.upperBound, cornerRadius: buttonRadius)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, ZenSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: theme.resolvedMetrics.controlHeight, alignment: .leading)
        .background(controlStyle.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(controlStyle.borderColor, lineWidth: controlStyle.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    private func stepButton(systemName: String, action: @escaping () -> Void, disabled: Bool, cornerRadius: CGFloat) -> some View {
        Button(action: action) {
            ZenIcon(systemName: systemName, size: 12)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(disabled ? Color.zenBorder : Color.zenTextPrimary)
                .frame(width: 28, height: 28)
                .background(Color.zenSurfaceMuted)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.zenBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func increment() {
        value = min(range.upperBound, value + step)
    }

    private func decrement() {
        value = max(range.lowerBound, value - step)
    }
}

public extension ZenStepper {
    init(
        _ title: String,
        subtitle: String? = nil,
        value: Binding<Int>,
        in range: ClosedRange<Int> = 0...100,
        step: Int = 1
    ) {
        self.init(
            title,
            subtitle: subtitle,
            value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ),
            in: Double(range.lowerBound)...Double(range.upperBound),
            step: Double(step),
            format: { String(Int($0)) }
        )
    }
}

private struct ZenStepperPreview: View {
    @State private var quantity = 1
    @State private var amount = 2.5

    var body: some View {
        VStack(spacing: ZenSpacing.small) {
            ZenStepper("Quantity", value: $quantity, in: 1...10)
            ZenStepper(
                "Amount",
                subtitle: "Step by 0.5",
                value: $amount,
                in: 0...10,
                step: 0.5
            )
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenStepperPreview()
}
