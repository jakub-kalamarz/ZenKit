import SwiftUI

public struct ZenNavigationButtonRow<Trailing: View>: View {
    private let action: () -> Void
    private let row: ZenNavigationRow<Trailing>

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron,
        action: @escaping () -> Void,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.action = action
        self.row = ZenNavigationRow(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            iconColor: iconColor,
            iconStyle: iconStyle,
            accessory: accessory,
            trailing: trailing
        )
    }

    public var body: some View {
            row
    }
}

public extension ZenNavigationButtonRow where Trailing == EmptyView {
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            iconColor: iconColor,
            iconStyle: iconStyle,
            accessory: accessory,
            action: action
        ) {
            EmptyView()
        }
    }
}

public extension ZenNavigationButtonRow where Trailing == EmptyView {
    @available(*, deprecated, message: "Use leadingIcon: parameter instead of leadingIconAsset/leadingIconSystemName")
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        leadingIconSystemName: String? = nil,
        iconTint: Color? = nil,
        iconColor: Color? = nil,
        accessory: ZenNavigationAccessory = .chevron,
        action: @escaping () -> Void
    ) {
        let resolvedIcon: ZenIconSource?
        if let leadingIcon {
            resolvedIcon = leadingIcon
        } else if let leadingIconSystemName {
            resolvedIcon = .system(leadingIconSystemName)
        } else if let leadingIconAsset {
            resolvedIcon = .asset(leadingIconAsset, renderingMode: .template)
        } else {
            resolvedIcon = nil
        }
        let resolvedColor = iconColor ?? iconTint

        self.init(
            title: title,
            subtitle: subtitle,
            leadingIcon: resolvedIcon,
            iconColor: resolvedColor,
            iconStyle: resolvedColor != nil ? .badge : .bare,
            accessory: accessory,
            action: action
        )
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenNavigationButtonRow(
            title: "Account",
            subtitle: "Profile, email, and devices",
            leadingIcon: .system("person.circle.fill"),
            iconColor: .blue,
            action: {}
        )

        ZenNavigationButtonRow(
            title: "Language",
            leadingIcon: .system("globe"),
            action: {}
        ) {
            Text("English")
        }
    }
    .padding()
    .background(Color.zenBackground)
}
