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
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    private let prompt: String
    private let leadingIconAsset: String?
    private let trailingIconAsset: String?
    private let kind: ZenTextInputKind
    private let state: ZenControlState
    private let message: String?
    private let submitLabel: SubmitLabel
    private let accessibilityIdentifier: String?

    public init(
        text: Binding<String>,
        prompt: String,
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
        self.leadingIconAsset = leadingIconAsset
        self.trailingIconAsset = trailingIconAsset
        self.kind = kind
        self.state = state
        self.message = message
        self.submitLabel = submitLabel
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        let theme = ZenTheme.current

        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            HStack(spacing: ZenSpacing.small) {
                if let leadingIconAsset {
                    ZenIcon(assetName: leadingIconAsset, size: 15)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(width: 16, height: 16)
                }

                field
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextPrimary)
                    .textFieldStyle(.plain)
                    .disabled(state == .disabled)
                    .focused($isFocused)

                if let trailingIconAsset {
                    ZenIcon(assetName: trailingIconAsset, size: 15)
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
            .background(Color.zenSurfaceMuted)
            .overlay(
                RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small))
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small)))
            .opacity(state == .disabled ? 0.6 : 1)

            if let message {
                Text(message)
                    .font(.zenCaption)
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

    private var borderColor: Color {
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
            return .zenBorder
        case .focused:
            return colors.focusRing.color
        case .invalid:
            return colors.criticalBorder.color
        case .disabled:
            return .zenBorder
        }
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenTextInput(text: .constant("alex@example.com"), prompt: "Email", leadingIconAsset: "Envelope")
        ZenTextInput(text: .constant(""), prompt: "Password", leadingIconAsset: "Lock", kind: .secure, state: .focused)
        ZenTextInput(text: .constant(""), prompt: "Email", leadingIconAsset: "Envelope", state: .invalid, message: "Enter a valid email.")
    }
    .padding()
    .background(Color.zenBackground)
}
