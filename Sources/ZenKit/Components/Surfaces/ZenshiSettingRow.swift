import SwiftUI

public struct ZenSettingRow<Trailing: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    private let leadingIcon: ZenIconSource?
    private let iconColor: Color?
    private let accessory: ZenNavigationAccessory
    private let trailing: () -> Trailing

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconSystemName: String? = nil,
        iconColor: Color? = nil,
        accessory: ZenNavigationAccessory = .none,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon ?? leadingIconSystemName.map(ZenIconSource.system)
        self.iconColor = iconColor
        self.accessory = accessory
        self.trailing = trailing
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(spacing: ZenSpacing.small) {
            if let leadingIcon {
                if let iconColor {
                    ZenIconBadge(source: leadingIcon, color: iconColor)
                } else {
                    ZenIcon(source: leadingIcon, size: 16)
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(width: 20, height: 20)
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

            trailing()
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextMuted)

            if accessory == .chevron {
                ZenIcon(systemName: "chevron.right", size: 12)
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

public extension ZenSettingRow where Trailing == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconSystemName: String? = nil,
        iconColor: Color? = nil,
        accessory: ZenNavigationAccessory = .none
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            leadingIconSystemName: leadingIconSystemName,
            iconColor: iconColor,
            accessory: accessory
        ) {
            EmptyView()
        }
    }
}

#Preview {
    ZenCard {
        ZenSettingGroup {
            ZenSettingRow(
                title: "Account",
                subtitle: "Manage your plan",
                leadingIcon: .system("person.crop.circle"),
                accessory: .chevron
            )

            ZenSettingRow(
                title: "Language",
                subtitle: "Used for notifications",
                leadingIcon: .system("globe")
            ) {
                Text("English")
            }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
