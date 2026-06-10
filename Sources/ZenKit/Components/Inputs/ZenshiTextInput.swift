import SwiftUI

public enum ZenTextInputKind {
    case plain
    case secure
}

public enum ZenTextInputAxis {
    case horizontal
    case vertical(ClosedRange<Int>)
}

public enum ZenTextInputKeyboardType: Sendable {
    case `default`
    case decimalPad
    case url
    case emailAddress
}

public enum ZenControlState {
    case normal
    case focused
    case invalid
    case disabled
}

public struct ZenTextInput: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    private let prompt: LocalizedStringKey
    private let leadingIcon: ZenIconSource?
    private let trailingIcon: ZenIconSource?
    private let kind: ZenTextInputKind
    private let axis: ZenTextInputAxis
    private let state: ZenControlState
    private let message: LocalizedStringKey?
    private let submitLabel: SubmitLabel
    private let keyboardType: ZenTextInputKeyboardType
    private let accessibilityIdentifier: String?

    public init(
        text: Binding<String>,
        prompt: LocalizedStringKey,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        trailingIconAsset: String? = nil,
        kind: ZenTextInputKind = .plain,
        axis: ZenTextInputAxis = .horizontal,
        state: ZenControlState = .normal,
        message: LocalizedStringKey? = nil,
        submitLabel: SubmitLabel = .done,
        keyboardType: ZenTextInputKeyboardType = .default,
        accessibilityIdentifier: String? = nil
    ) {
        _text = text
        self.prompt = prompt
        self.leadingIcon = leadingIcon ?? leadingIconAsset.map { .asset($0, renderingMode: .template) }
        self.trailingIcon = trailingIcon ?? trailingIconAsset.map { .asset($0, renderingMode: .template) }
        self.kind = kind
        self.axis = axis
        self.state = state
        self.message = message
        self.submitLabel = submitLabel
        self.keyboardType = keyboardType
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let controlStyle = ZenControlSurfaceStyle.field(theme: theme)

        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            HStack(spacing: ZenSpacing.small) {
                if let leadingIcon {
                    ZenIcon(source: leadingIcon, size: 15)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(width: 16, height: 16)
                }

                field
                    .font(.zenIntro)
                    .foregroundStyle(Color.zenTextPrimary)
                    .textFieldStyle(.plain)
                    .disabled(state == .disabled)
                    .focused($isFocused)

                if let trailingIcon {
                    ZenIcon(source: trailingIcon, size: 15)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
            .padding(.vertical, theme.resolvedMetrics.fieldVerticalPadding)
            .padding(.horizontal, 12)
            .frame(
                maxWidth: .infinity,
                minHeight: minControlHeight(theme: theme),
                maxHeight: maxControlHeight(theme: theme),
                alignment: .leading
            )
            .background(controlStyle.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor(controlStyle: controlStyle), lineWidth: controlStyle.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .animation(.easeOut(duration: 0.2), value: text)
            .opacity(state == .disabled ? 0.6 : 1)

            if let message {
                Text(message)
                    .font(.zenGroup)
                    .foregroundStyle(state == .invalid ? Color.zenCritical : Color.zenTextMuted)
            }
        }
    }

    @ViewBuilder
    private var field: some View {
        switch kind {
        case .plain:
            plainField
        case .secure:
            SecureField(prompt, text: $text)
                .submitLabel(submitLabel)
                .zenAccessibilityIdentifierIfPresent(accessibilityIdentifier)
        }
    }

    @ViewBuilder
    private var plainField: some View {
        switch axis {
        case .horizontal:
            configured(TextField(prompt, text: $text))
        case .vertical(let lineLimit):
            configured(
                TextField(prompt, text: $text, axis: .vertical)
                    .lineLimit(lineLimit)
            )
        }
    }

    private func configured<Field: View>(_ field: Field) -> some View {
        field
            .submitLabel(submitLabel)
            .zenKeyboardType(keyboardType)
            .zenAccessibilityIdentifierIfPresent(accessibilityIdentifier)
    }

    private func minControlHeight(theme: ZenTheme) -> CGFloat {
        theme.resolvedMetrics.controlHeight
    }

    private func maxControlHeight(theme: ZenTheme) -> CGFloat? {
        switch axis {
        case .horizontal:
            return theme.resolvedMetrics.controlHeight
        case .vertical:
            return nil
        }
    }

    private func borderColor(controlStyle: ZenControlSurfaceStyle) -> Color {
        let colors = ZenTheme.current.resolvedColors

        if state == .invalid {
            return colors.criticalBorder.color
        }

        if state == .disabled {
            return .zenBorder
        }

        if isFocused || state == .focused {
            return colors.focusRing.color
        }

        switch state {
        case .normal:
            return controlStyle.borderColor
        case .focused:
            return colors.focusRing.color
        case .invalid:
            return colors.criticalBorder.color
        case .disabled:
            return controlStyle.borderColor
        }
    }
}

private extension View {
    @ViewBuilder
    func zenKeyboardType(_ keyboardType: ZenTextInputKeyboardType) -> some View {
        #if os(iOS)
            switch keyboardType {
            case .default:
                self.keyboardType(.default)
            case .decimalPad:
                self.keyboardType(.decimalPad)
            case .url:
                self.keyboardType(.URL)
            case .emailAddress:
                self.keyboardType(.emailAddress)
            }
        #else
            self
        #endif
    }

    @ViewBuilder
    func zenAccessibilityIdentifierIfPresent(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}

#Preview {
    struct TextInputPreview: View {
        @State private var multilineText = ""

        var body: some View {
            VStack(spacing: ZenSpacing.medium) {
                ZenTextInput(text: .constant("alex@example.com"), prompt: "Email", leadingIcon: .asset("Envelope", renderingMode: .template))
                ZenTextInput(text: .constant(""), prompt: "Password", leadingIcon: .asset("Lock", renderingMode: .template), kind: .secure, state: .focused)
                ZenTextInput(text: .constant(""), prompt: "Email", leadingIcon: .asset("Envelope", renderingMode: .template), state: .invalid, message: "Enter a valid email.")
                ZenTextInput(text: $multilineText, prompt: "Type a message...", axis: .vertical(1...6))
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return TextInputPreview()
}
