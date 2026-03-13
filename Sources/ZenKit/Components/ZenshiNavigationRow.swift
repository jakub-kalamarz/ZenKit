import SwiftUI

public enum ZenNavigationAccessory {
    case none
    case chevron
}

public struct ZenNavigationRow: View {
    private let title: String
    private let subtitle: String?
    private let leadingIconAsset: String?
    private let accessory: ZenNavigationAccessory

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIconAsset: String? = nil,
        accessory: ZenNavigationAccessory = .chevron
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIconAsset = leadingIconAsset
        self.accessory = accessory
    }

    public var body: some View {
        let theme = ZenTheme.current

        HStack(spacing: ZenSpacing.small) {
            if let leadingIconAsset {
                ZenIcon(assetName: leadingIconAsset, size: 14)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
                    .frame(width: 20)
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
            RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small))
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small)))
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenNavigationRow(
            title: "Account",
            subtitle: "Profile, email, and devices",
            leadingIconAsset: "UserCircle"
        )

        ZenNavigationRow(
            title: "Notifications",
            leadingIconAsset: "Bell",
            accessory: .none
        )
    }
    .padding()
    .background(Color.zenBackground)
}
