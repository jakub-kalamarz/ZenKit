import SwiftUI

// MARK: - Numpad Key

private enum ZenNumpadKey {
    case digit(Int), decimal, delete
}

// MARK: - Shake Effect

private struct ZenShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: 10 * sin(animatableData * .pi * 5), y: 0
        ))
    }
}

// MARK: - Input Model

@MainActor
private final class ZenStepperInputModel: ObservableObject {
    @Published var inputArray: [String] = []
    @Published var shake = false
    @Published var validationError: String?

    private let range: ClosedRange<Double>
    private let step: Double
    private let format: (Double) -> String

    var allowsDecimal: Bool {
        step.truncatingRemainder(dividingBy: 1) != 0
    }

    var currentValue: Double {
        Double(inputArray.joined()) ?? 0
    }

    var displayText: String {
        inputArray.isEmpty ? "0" : inputArray.joined()
    }

    var isValid: Bool {
        validationError == nil
    }

    init(initialValue: Double, range: ClosedRange<Double>, step: Double, format: @escaping (Double) -> String) {
        self.range = range
        self.step = step
        self.format = format
        if initialValue > 0 {
            inputArray = Array(format(initialValue)).map { String($0) }
        }
        validateInput()
    }

    func handleKey(_ key: ZenNumpadKey) {
        switch key {
        case .digit(let n): handleDigit(n)
        case .decimal: handleDecimal()
        case .delete: handleDelete()
        }
    }

    func commit(to binding: Binding<Double>) {
        guard isValid else { triggerError(); return }
        binding.wrappedValue = currentValue
    }

    private func handleDigit(_ number: Int) {
        if number == 0 && inputArray.isEmpty {
            inputArray.append("0")
            validateInput()
            return
        }
        if inputArray == ["0"] && number != 0 {
            inputArray = [String(number)]
            validateInput()
            return
        }
        let hasDecimal = inputArray.contains(".")
        if hasDecimal {
            if let dotIndex = inputArray.firstIndex(of: ".") {
                let decimalPlaces = inputArray.count - dotIndex - 1
                if decimalPlaces >= 2 { triggerError(); return }
            }
            if inputArray.filter({ $0 != "." }).count >= 6 { triggerError(); return }
        } else {
            if inputArray.count >= 4 { triggerError(); return }
        }
        inputArray.append(String(number))
        validateInput()
    }

    private func handleDecimal() {
        guard allowsDecimal else { triggerError(); return }
        if inputArray.contains(".") { triggerError(); return }
        if inputArray.isEmpty {
            inputArray = ["0", "."]
            validateInput()
            return
        }
        inputArray.append(".")
        validateInput()
    }

    private func handleDelete() {
        guard !inputArray.isEmpty else { triggerError(); return }
        inputArray.removeLast()
        validateInput()
    }

    private func validateInput() {
        let v = currentValue
        if v < range.lowerBound {
            validationError = "Min: \(format(range.lowerBound))"
        } else if v > range.upperBound {
            validationError = "Max: \(format(range.upperBound))"
        } else {
            validationError = nil
        }
    }

    private func triggerError() {
        shake.toggle()
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}

// MARK: - Numpad Key View

private struct ZenNumpadKeyView: View {
    let key: ZenNumpadKey
    let action: () -> Void

    var body: some View {
        let theme = ZenTheme.current
        let radius = theme.resolvedCornerRadius(for: ZenRadius.medium)

        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.zenSurfaceMuted)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(Color.zenBorder, lineWidth: 1)
                    )
                keyLabel
            }
        }
        .buttonStyle(ZenNumpadButtonStyle())
        .frame(height: 60)
    }

    @ViewBuilder
    private var keyLabel: some View {
        switch key {
        case .digit(let n):
            Text("\(n)")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.zenTextPrimary)
        case .decimal:
            Text(".")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.zenTextPrimary)
        case .delete:
            Image(systemName: "delete.backward")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.zenTextPrimary)
        }
    }
}

private struct ZenNumpadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Numpad Sheet

private struct ZenStepperNumpadSheet: View {
    @StateObject private var model: ZenStepperInputModel
    @Binding var value: Double
    @Environment(\.dismiss) private var dismiss
    let title: String

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    init(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, format: @escaping (Double) -> String) {
        self.title = title
        _value = value
        _model = StateObject(wrappedValue: ZenStepperInputModel(
            initialValue: value.wrappedValue,
            range: range,
            step: step,
            format: format
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: ZenSpacing.xSmall) {
                    Text(model.displayText)
                        .font(.system(size: 56, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.zenTextPrimary)
                        .modifier(ZenShakeEffect(animatableData: model.shake ? 1 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: model.shake)

                    if let error = model.validationError {
                        Text(error)
                            .font(.zenGroup)
                            .foregroundStyle(.red)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .frame(height: 100, alignment: .center)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: model.validationError)

                Spacer()

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(1..<10) { n in
                        ZenNumpadKeyView(key: .digit(n)) { model.handleKey(.digit(n)) }
                    }
                    ZenNumpadKeyView(key: .decimal) { model.handleKey(.decimal) }
                        .opacity(model.allowsDecimal ? 1 : 0.3)
                        .allowsHitTesting(model.allowsDecimal)
                    ZenNumpadKeyView(key: .digit(0)) { model.handleKey(.digit(0)) }
                    ZenNumpadKeyView(key: .delete) { model.handleKey(.delete) }
                }
                .padding(.bottom, ZenSpacing.large)
            }
            .padding(.horizontal, ZenSpacing.medium)
            .background(Color.zenBackground)
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        model.commit(to: $value)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .disabled(!model.isValid)
                }
            }
        }
    }
}

// MARK: - ZenStepper

public struct ZenStepper: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @State private var isEditingValue = false

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
                    .font(.zen(.body, weight: .semibold))
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenGroup)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            Spacer(minLength: ZenSpacing.small)

            HStack(spacing: ZenSpacing.xSmall) {
                stepButton(systemName: "minus", action: decrement, disabled: value <= range.lowerBound, cornerRadius: buttonRadius)

                Button { isEditingValue = true } label: {
                    Text(format(value))
                        .font(.zen(.body, weight: .semibold))
                        .foregroundStyle(Color.zenTextPrimary)
                        .monospacedDigit()
                        .frame(minWidth: 52, alignment: .center)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: value)
                }
                .buttonStyle(.plain)

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
        .sheet(isPresented: $isEditingValue) {
            ZenStepperNumpadSheet(
                title: title,
                value: $value,
                range: range,
                step: step,
                format: format
            )
        }
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
