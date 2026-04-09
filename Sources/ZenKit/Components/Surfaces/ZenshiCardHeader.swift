import SwiftUI

public struct ZenCardHeader: View {
    private let title: String
    private let subtitle: String?
    private let leadingIcon: ZenIconSource?
    private let iconColor: Color?

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconSystemName: String? = nil,
        iconTint: Color? = nil,
        iconColor: Color? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon ?? leadingIconSystemName.map(ZenIconSource.system)
        self.iconColor = iconColor ?? iconTint
    }

    public var body: some View {
        HStack(alignment: .top, spacing: ZenSpacing.small) {
            if let leadingIcon, let iconColor {
                ZenIconBadge(source: leadingIcon, color: iconColor, size: 36)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zenTitle)
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenCard {
            ZenCardHeader(
                title: "Notifications",
                subtitle: "Manage delivery settings",
                leadingIcon: .system("bell.badge.fill"),
                iconColor: .red
            )
        }

        ZenCard {
            ZenCardHeader(
                title: "Security",
                subtitle: "Password and two-factor auth",
                leadingIcon: .system("shield.fill"),
                iconColor: .green
            )
        }

        ZenCard {
            ZenCardHeader(title: "Simple Card")
        }
    }
    .padding()
    .background(Color.zenBackground)
}
