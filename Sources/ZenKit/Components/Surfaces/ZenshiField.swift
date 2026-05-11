import SwiftUI

public struct ZenFieldLabel: View {
    private let text: LocalizedStringKey

    public init(_ text: LocalizedStringKey) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.zen(.body2, weight: .medium))
            .foregroundStyle(Color.zenTextPrimary)
    }
}

public struct ZenFieldMessage: View {
    private let text: LocalizedStringKey
    private let state: ZenControlState

    public init(_ text: LocalizedStringKey, state: ZenControlState = .normal) {
        self.text = text
        self.state = state
    }

    public var body: some View {
        Text(text)
            .font(.zenGroup)
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
    private let label: LocalizedStringKey?
    private let message: LocalizedStringKey?
    private let state: ZenControlState
    private let content: () -> Content

    public init(
        label: LocalizedStringKey? = nil,
        message: LocalizedStringKey? = nil,
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
    private let title: LocalizedStringKey?
    private let subtitle: LocalizedStringKey?
    private let content: () -> Content

    public init(
        title: LocalizedStringKey? = nil,
        subtitle: LocalizedStringKey? = nil,
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
                            .font(.zenStat)
                            .foregroundStyle(Color.zenTextPrimary)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.zenGroup)
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
                    leadingIcon: .asset("Envelope", renderingMode: .template)
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
