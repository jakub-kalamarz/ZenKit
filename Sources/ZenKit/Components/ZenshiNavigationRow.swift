import SwiftUI

public enum ZenNavigationAccessory {
    case none
    case chevron
}

public struct ZenNavigationRow: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    private let leadingIconSource: ZenIconSource?
    private let iconColor: Color?
    private let accessory: ZenNavigationAccessory

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIconAsset: String? = nil,
        leadingIconSystemName: String? = nil,
        iconColor: Color? = nil,
        accessory: ZenNavigationAccessory = .chevron
    ) {
        self.title = title
        self.subtitle = subtitle
        if let leadingIconSystemName {
            self.leadingIconSource = .system(leadingIconSystemName)
        } else if let leadingIconAsset {
            self.leadingIconSource = .asset(leadingIconAsset)
        } else {
            self.leadingIconSource = nil
        }
        self.iconColor = iconColor
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
                        RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small), style: .continuous)
                            .fill(Color.zenSurfaceMuted)
                            .frame(width: ZenIconBadge.defaultSize, height: ZenIconBadge.defaultSize)
                        ZenIcon(source: leadingIconSource, size: 14)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zenLabel)
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenCaption)
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
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenNavigationRow(
            title: "Account",
            subtitle: "Profile, email, and devices",
            leadingIconSystemName: "person.circle.fill",
            iconColor: .blue
        )
        ZenNavigationRow(
            title: "Notifications",
            leadingIconSystemName: "bell.fill",
            iconColor: .red,
            accessory: .none
        )
        ZenNavigationRow(
            title: "Security",
            subtitle: "Password and two-factor",
            leadingIconSystemName: "shield.fill",
            iconColor: .green
        )
    }
    .padding()
    .background(Color.zenBackground)
}
