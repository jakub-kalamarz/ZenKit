import SwiftUI

public struct ZenSettingRow<Trailing: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    private let leadingIconSystemName: String?
    private let accessory: ZenNavigationAccessory
    private let trailing: () -> Trailing

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIconSystemName: String? = nil,
        accessory: ZenNavigationAccessory = .none,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIconSystemName = leadingIconSystemName
        self.accessory = accessory
        self.trailing = trailing
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(spacing: ZenSpacing.small) {
            if let leadingIconSystemName {
                ZenIcon(systemName: leadingIconSystemName, size: 16)
                    .foregroundStyle(Color.zenTextMuted)
                    .frame(width: 20, height: 20)
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
        leadingIconSystemName: String? = nil,
        accessory: ZenNavigationAccessory = .none
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            leadingIconSystemName: leadingIconSystemName,
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
                leadingIconSystemName: "person.crop.circle",
                accessory: .chevron
            )

            ZenSettingRow(
                title: "Language",
                subtitle: "Used for notifications",
                leadingIconSystemName: "globe"
            ) {
                Text("English")
            }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
