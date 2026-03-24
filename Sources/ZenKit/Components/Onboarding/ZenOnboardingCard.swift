import SwiftUI

public struct ZenOnboardingAction {
    public let label: String
    public let handler: () -> Void

    public init(_ label: String, handler: @escaping () -> Void) {
        self.label = label
        self.handler = handler
    }
}

public struct ZenOnboardingCard: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let iconSystemName: String
    private let iconColor: Color
    private let title: String
    private let message: String
    private let primaryAction: ZenOnboardingAction?
    private let secondaryAction: ZenOnboardingAction?
    private let onDismiss: (() -> Void)?

    public init(
        iconSystemName: String,
        iconColor: Color = Color.zenPrimary,
        title: String,
        message: String,
        primaryAction: ZenOnboardingAction? = nil,
        secondaryAction: ZenOnboardingAction? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.onDismiss = onDismiss
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            HStack {
                ZenIconBadge(systemName: iconSystemName, color: iconColor)

                Spacer()

                if let onDismiss {
                    Button {
                        onDismiss()
                    } label: {
                        ZenIcon(systemName: "xmark", size: 12)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.zenTextMuted)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(title)
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            Text(message)
                .font(.zenBody)
                .foregroundStyle(Color.zenTextMuted)

            if primaryAction != nil || secondaryAction != nil {
                HStack(spacing: ZenSpacing.small) {
                    if let primaryAction {
                        ZenButton(LocalizedStringKey(primaryAction.label)) {
                            primaryAction.handler()
                        }
                    }

                    if let secondaryAction {
                        ZenButton(LocalizedStringKey(secondaryAction.label), variant: .secondary) {
                            secondaryAction.handler()
                        }
                    }
                }
            }
        }
        .padding(ZenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenOnboardingCard(
            iconSystemName: "sparkles",
            iconColor: .purple,
            title: "Welcome to ZenKit",
            message: "A design system built for clarity and calm. Start exploring components below.",
            primaryAction: ZenOnboardingAction("Get Started") {},
            secondaryAction: ZenOnboardingAction("Learn More") {},
            onDismiss: {}
        )

        ZenOnboardingCard(
            iconSystemName: "bell.badge.fill",
            iconColor: .orange,
            title: "Enable Notifications",
            message: "Stay informed about updates and mentions from your team.",
            primaryAction: ZenOnboardingAction("Enable") {}
        )

        ZenOnboardingCard(
            iconSystemName: "lock.shield.fill",
            iconColor: .green,
            title: "Two-Factor Authentication",
            message: "Your account is protected with two-factor authentication."
        )
    }
    .padding()
    .background(Color.zenBackground)
}
