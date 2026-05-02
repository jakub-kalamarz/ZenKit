import SwiftUI

public enum ZenTextInputKind {
    case plain
    case secure
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

    private let prompt: String
    private let leadingIcon: ZenIconSource?
    private let trailingIcon: ZenIconSource?
    private let kind: ZenTextInputKind
    private let state: ZenControlState
    private let message: String?
    private let submitLabel: SubmitLabel
    private let accessibilityIdentifier: String?

    public init(
        text: Binding<String>,
        prompt: String,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        trailingIconAsset: String? = nil,
        kind: ZenTextInputKind = .plain,
        state: ZenControlState = .normal,
        message: String? = nil,
        submitLabel: SubmitLabel = .done,
        accessibilityIdentifier: String? = nil
    ) {
        _text = text
        self.prompt = prompt
        self.leadingIcon = leadingIcon ?? leadingIconAsset.map(ZenIconSource.asset)
        self.trailingIcon = trailingIcon ?? trailingIconAsset.map(ZenIconSource.asset)
        self.kind = kind
        self.state = state
        self.message = message
        self.submitLabel = submitLabel
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
                        .font(.system(size: 15, weight: .medium))
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
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
            .padding(.vertical, theme.resolvedMetrics.fieldVerticalPadding)
            .padding(.horizontal, 12)
            .frame(
                maxWidth: .infinity,
                minHeight: theme.resolvedMetrics.controlHeight,
                maxHeight: theme.resolvedMetrics.controlHeight,
                alignment: .leading
            )
            .background(controlStyle.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor(controlStyle: controlStyle), lineWidth: controlStyle.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
            TextField(prompt, text: $text)
                .submitLabel(submitLabel)
                .accessibilityIdentifier(accessibilityIdentifier ?? prompt)
        case .secure:
            SecureField(prompt, text: $text)
                .submitLabel(submitLabel)
                .accessibilityIdentifier(accessibilityIdentifier ?? prompt)
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

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenTextInput(text: .constant("alex@example.com"), prompt: "Email", leadingIcon: .asset("Envelope"))
        ZenTextInput(text: .constant(""), prompt: "Password", leadingIcon: .asset("Lock"), kind: .secure, state: .focused)
        ZenTextInput(text: .constant(""), prompt: "Email", leadingIcon: .asset("Envelope"), state: .invalid, message: "Enter a valid email.")
    }
    .padding()
    .background(Color.zenBackground)
}
