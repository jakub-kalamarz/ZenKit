import SwiftUI

public struct ZenFieldLabel: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.zenLabel)
            .foregroundStyle(Color.zenTextPrimary)
    }
}

public struct ZenFieldMessage: View {
    private let text: String
    private let state: ZenControlState

    public init(_ text: String, state: ZenControlState = .normal) {
        self.text = text
        self.state = state
    }

    public var body: some View {
        Text(text)
            .font(.zenCaption)
            .foregroundStyle(messageColor)
    }

    private var messageColor: Color {
        switch state {
        case .invalid:
            return .zenCritical
        case .disabled:
            return .zenTextMuted.opacity(0.8)
        case .normal, .focused:
            return .zenTextMuted
        }
    }
}

public struct ZenField<Content: View>: View {
    private let label: String?
    private let message: String?
    private let state: ZenControlState
    private let content: () -> Content

    public init(
        label: String? = nil,
        message: String? = nil,
        state: ZenControlState = .normal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.message = message
        self.state = state
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if let label {
                ZenFieldLabel(label)
            }

            content()

            if let message {
                ZenFieldMessage(message, state: state)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(state == .disabled ? 0.7 : 1)
    }
}

public struct ZenFieldGroup<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            content()
        }
    }
}

public struct ZenFieldSection<Content: View>: View {
    private let title: String?
    private let subtitle: String?
    private let content: () -> Content

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.zenTitle)
                            .foregroundStyle(Color.zenTextPrimary)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            content()
        }
    }
}

#Preview {
    ZenFieldSection(
        title: "Profile",
        subtitle: "Update the details shown across your workspace"
    ) {
        ZenFieldGroup {
            ZenField(
                label: "Email",
                message: "Used for account access"
            ) {
                ZenTextInput(
                    text: .constant("alex@example.com"),
                    prompt: "Email",
                    leadingIconAsset: "Envelope"
                )
            }

            ZenField(
                label: "Display name",
                message: "Visible to teammates",
                state: .focused
            ) {
                ZenTextInput(
                    text: .constant("Alex"),
                    prompt: "Display name",
                    state: .focused
                )
            }

            ZenField(
                label: "Handle",
                message: "Choose a unique username",
                state: .invalid
            ) {
                ZenTextInput(
                    text: .constant("zen"),
                    prompt: "Handle",
                    state: .invalid,
                    message: "This handle is already taken."
                )
            }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
