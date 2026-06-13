import SwiftUI

public struct ZenSubscriptionCardDetail: Identifiable, Sendable {
    public let id: String
    public let icon: ZenIconSource?
    public let title: String
    public let value: String

    public init(
        id: String,
        icon: ZenIconSource? = nil,
        title: String,
        value: String
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.value = value
    }
}

public struct ZenSubscriptionCard: View {
    private let title: String
    private let subtitle: String
    private let statusText: LocalizedStringKey
    private let statusTone: ZenSemanticTone
    private let leadingIcon: ZenIconSource?
    private let iconTint: Color
    private let details: [ZenSubscriptionCardDetail]
    private let primaryActionTitle: LocalizedStringKey
    private let primaryActionIcon: ZenIconSource?
    private let primaryActionAccessibilityIdentifier: String?
    private let isPrimaryActionLoading: Bool
    private let primaryAction: () -> Void
    private let secondaryActionTitle: LocalizedStringKey?
    private let secondaryActionIcon: ZenIconSource?
    private let secondaryActionAccessibilityIdentifier: String?
    private let isSecondaryActionLoading: Bool
    private let secondaryAction: (() -> Void)?

    public init(
        title: String,
        subtitle: String,
        statusText: LocalizedStringKey,
        statusTone: ZenSemanticTone = .neutral,
        leadingIcon: ZenIconSource? = .system("sparkles"),
        iconTint: Color = .zenAccent,
        details: [ZenSubscriptionCardDetail] = [],
        primaryActionTitle: LocalizedStringKey,
        primaryActionIcon: ZenIconSource? = nil,
        primaryActionAccessibilityIdentifier: String? = nil,
        isPrimaryActionLoading: Bool = false,
        primaryAction: @escaping () -> Void,
        secondaryActionTitle: LocalizedStringKey? = nil,
        secondaryActionIcon: ZenIconSource? = nil,
        secondaryActionAccessibilityIdentifier: String? = nil,
        isSecondaryActionLoading: Bool = false,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.statusText = statusText
        self.statusTone = statusTone
        self.leadingIcon = leadingIcon
        self.iconTint = iconTint
        self.details = details
        self.primaryActionTitle = primaryActionTitle
        self.primaryActionIcon = primaryActionIcon
        self.primaryActionAccessibilityIdentifier = primaryActionAccessibilityIdentifier
        self.isPrimaryActionLoading = isPrimaryActionLoading
        self.primaryAction = primaryAction
        self.secondaryActionTitle = secondaryActionTitle
        self.secondaryActionIcon = secondaryActionIcon
        self.secondaryActionAccessibilityIdentifier = secondaryActionAccessibilityIdentifier
        self.isSecondaryActionLoading = isSecondaryActionLoading
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        #if DEBUG
        #endif
        ZenCard {
            VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                header

                if !details.isEmpty {
                    Divider()
                    detailList
                }

                actions
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: ZenSpacing.medium) {
            if let leadingIcon {
                ZenIconBadge(source: leadingIcon, color: iconTint, size: 40)
            }

            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                ZenBadge(statusText, tone: statusTone, size: .small, variant: .filled)

                Text(title)
                    .font(.zenTitle.weight(.semibold))
                    .foregroundStyle(Color.zenTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private var detailList: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            ForEach(details) { detail in
                HStack(alignment: .firstTextBaseline, spacing: ZenSpacing.small) {
                    if let icon = detail.icon {
                        ZenIcon(source: icon, size: 16)
                            .foregroundStyle(Color.zenTextMuted)
                            .frame(width: 18)
                            .accessibilityHidden(true)
                    }

                    Text(detail.title)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: ZenSpacing.small)

                    Text(detail.value)
                        .font(.zenBody.weight(.medium))
                        .foregroundStyle(Color.zenTextPrimary)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var actions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: ZenSpacing.small) {
                primaryButton
                secondaryButton
            }

            VStack(spacing: ZenSpacing.small) {
                primaryButton
                secondaryButton
            }
        }
    }

    private var primaryButton: some View {
        ZenButton(
            primaryActionTitle,
            size: .sm,
            leadingIcon: primaryActionIcon,
            isLoading: isPrimaryActionLoading,
            fullWidth: true,
            action: primaryAction
        )
        .accessibilityIdentifier(primaryActionAccessibilityIdentifier ?? "")
    }

    @ViewBuilder
    private var secondaryButton: some View {
        if let secondaryActionTitle, let secondaryAction {
            ZenButton(
                secondaryActionTitle,
                variant: .outline,
                size: .sm,
                leadingIcon: secondaryActionIcon,
                isLoading: isSecondaryActionLoading,
                fullWidth: true,
                action: secondaryAction
            )
            .accessibilityIdentifier(secondaryActionAccessibilityIdentifier ?? "")
        }
    }
}

#Preview("Subscription Card") {
    VStack(spacing: ZenSpacing.medium) {
        ZenSubscriptionCard(
            title: "Zenshi Pro",
            subtitle: "Unlimited sites and widgets are active.",
            statusText: "Pro active",
            statusTone: .success,
            details: [
                ZenSubscriptionCardDetail(
                    id: "access",
                    icon: .system("checkmark.seal.fill"),
                    title: "Access",
                    value: "Unlimited sites and widgets"
                ),
            ],
            primaryActionTitle: "Manage subscription",
            primaryActionIcon: .system("arrow.up.forward.app"),
            primaryAction: {},
            secondaryActionTitle: "Refresh",
            secondaryActionIcon: .system("arrow.clockwise"),
            secondaryAction: {}
        )

        ZenSubscriptionCard(
            title: "Free plan",
            subtitle: "Upgrade when you need more Search Console tracking.",
            statusText: "Free",
            details: [
                ZenSubscriptionCardDetail(
                    id: "access",
                    icon: .system("chart.bar"),
                    title: "Included",
                    value: "1 site and 1 widget"
                ),
            ],
            primaryActionTitle: "Upgrade",
            primaryActionIcon: .system("sparkles"),
            primaryAction: {},
            secondaryActionTitle: "Refresh",
            secondaryActionIcon: .system("arrow.clockwise"),
            secondaryAction: {}
        )
    }
    .padding()
    .background(Color.zenBackground)
}
