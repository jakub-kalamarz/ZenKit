import SwiftUI

public enum ZenNavigationAccessory {
    case none
    case chevron
}

public struct ZenNavigationRow: View {
    @Environment(\.isEnabled) private var isEnabled
    public static let leadingIconBadgeSize: CGFloat = ZenIconBadge.defaultSize
    public static let leadingIconBadgeCornerRadius: CGFloat = 10

    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    private let leadingIconSource: ZenIconSource?
    private let iconColor: Color?
    private let accessory: ZenNavigationAccessory

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        leadingIconSystemName: String? = nil,
        iconTint: Color? = nil,
        iconColor: Color? = nil,
        accessory: ZenNavigationAccessory = .chevron
    ) {
        self.title = title
        self.subtitle = subtitle
        if let leadingIcon {
            self.leadingIconSource = leadingIcon
        } else if let leadingIconSystemName {
            self.leadingIconSource = .system(leadingIconSystemName)
        } else if let leadingIconAsset {
            self.leadingIconSource = .asset(leadingIconAsset, renderingMode: .template)
        } else {
            self.leadingIconSource = nil
        }
        self.iconColor = iconColor ?? iconTint
        self.accessory = accessory
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(spacing: ZenSpacing.small) {
            if let leadingIconSource {
                if let iconColor {
                    ZenIconBadge(source: leadingIconSource, color: iconColor)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: Self.leadingIconBadgeCornerRadius, style: .continuous)
                            .fill(Color.zenSurfaceMuted)
                            .frame(width: Self.leadingIconBadgeSize, height: Self.leadingIconBadgeSize)
                        ZenIcon(source: leadingIconSource, size: 14)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zen(.body2, weight: .semibold))
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenGroup)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            Spacer(minLength: ZenSpacing.small)

            if accessory == .chevron {
                ZenIcon(systemName: "chevron.right", size: 12)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .opacity(contentOpacity)
        .padding(.vertical, 12)
        .padding(.horizontal, ZenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var contentOpacity: Double {
        isEnabled ? 1 : 0.55
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenNavigationRow(
            title: "Account",
            subtitle: "Profile, email, and devices",
            leadingIcon: .system("person.circle.fill"),
            iconColor: .blue
        )
        ZenNavigationRow(
            title: "Notifications",
            leadingIcon: .system("bell.fill"),
            iconColor: .red,
            accessory: .none
        )
        ZenNavigationRow(
            title: "Security",
            subtitle: "Password and two-factor",
            leadingIcon: .system("shield.fill"),
            iconColor: .green
        )
        ZenNavigationRow(
            title: "Billing",
            subtitle: "Managed by workspace owner",
            leadingIcon: .system("creditcard.fill"),
            iconColor: .orange
        )
        .disabled(true)
    }
    .padding()
    .background(Color.zenBackground)
}
