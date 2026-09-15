import SwiftUI

public enum ZenNavigationAccessory {
    case none
    case chevron
}

public enum ZenNavigationRowIconStyle {
    case bare
    case badge
}

public struct ZenNavigationRow<Trailing: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    /// Held as `Text` rather than `LocalizedStringKey` so a row whose title is the
    /// host's own content — a record's name, a person, a file — can be passed verbatim.
    /// A `LocalizedStringKey` sends that content through the app's string catalog, where
    /// anything that happens to match a key comes back as that key's translation.
    private let title: Text
    private let subtitle: Text?
    private let leadingIconSource: ZenIconSource?
    private let iconColor: Color?
    private let iconStyle: ZenNavigationRowIconStyle
    private let accessory: ZenNavigationAccessory
    private let trailing: () -> Trailing

    init(
        storedTitle: Text,
        storedSubtitle: Text?,
        leadingIcon: ZenIconSource?,
        iconColor: Color?,
        iconStyle: ZenNavigationRowIconStyle,
        accessory: ZenNavigationAccessory,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = storedTitle
        self.subtitle = storedSubtitle
        self.leadingIconSource = leadingIcon
        self.iconColor = iconColor
        self.iconStyle = iconStyle
        self.accessory = accessory
        self.trailing = trailing
    }

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
        self.leadingIconSource = leadingIcon
        self.iconColor = iconColor
        self.iconStyle = iconStyle
        self.accessory = accessory
        self.trailing = trailing
    }

    public var body: some View {
        #if DEBUG
        #endif
        let cornerRadius = ZenTheme.current.resolvedCornerRadius

        HStack(spacing: ZenSpacing.small) {
            if let leadingIconSource {
                leadingIconView(leadingIconSource)
            }

            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.zen(.body2, weight: .medium))
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    subtitle
                        .font(.zenGroup)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            Spacer(minLength: ZenSpacing.small)

            trailing()
                .font(.zen(.body2, weight: .medium))
                .foregroundStyle(Color.zenTextMuted)

            if accessory == .chevron {
                ZenIcon(icon: .chevronRight, size: 12)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .opacity(isEnabled ? 1 : 0.55)
        .padding(.vertical, 10)
        .padding(.horizontal, ZenSpacing.medium)
        .background(Color.zenSurface)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func leadingIconView(_ source: ZenIconSource) -> some View {
        if iconStyle == .badge, let iconColor {
            ZenIconBadge(source: source, color: iconColor)
        } else {
            ZenIcon(source: source, size: 14)
                .foregroundStyle(iconColor ?? Color.zenTextMuted)
                .frame(width: 28, height: 28)
                .background(Color.zenSurfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

// MARK: - Verbatim titles

public extension ZenNavigationRow {
    /// A row whose title is content rather than copy — a record's own name.
    ///
    /// Never use this for one of the host's own strings; those are keys and belong in
    /// its catalog. `subtitle` stays a key, since a subtitle is usually the host's
    /// wording *about* the row; pass `subtitleVerbatim` when it isn't.
    init(
        verbatim title: String,
        subtitle: LocalizedStringKey? = nil,
        subtitleVerbatim: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.init(
            titleText: Text(verbatim: title),
            subtitleText: subtitleVerbatim.map { Text(verbatim: $0) } ?? subtitle.map { Text($0) },
            leadingIcon: leadingIcon,
            iconColor: iconColor,
            iconStyle: iconStyle,
            accessory: accessory,
            trailing: trailing
        )
    }

    /// The one initializer that takes the two `Text`s directly; every other one funnels here.
    init(
        titleText: Text,
        subtitleText: Text? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.init(
            storedTitle: titleText,
            storedSubtitle: subtitleText,
            leadingIcon: leadingIcon,
            iconColor: iconColor,
            iconStyle: iconStyle,
            accessory: accessory,
            trailing: trailing
        )
    }
}

public extension ZenNavigationRow where Trailing == EmptyView {
    init(
        verbatim title: String,
        subtitle: LocalizedStringKey? = nil,
        subtitleVerbatim: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron
    ) {
        self.init(
            verbatim: title,
            subtitle: subtitle,
            subtitleVerbatim: subtitleVerbatim,
            leadingIcon: leadingIcon,
            iconColor: iconColor,
            iconStyle: iconStyle,
            accessory: accessory
        ) {
            EmptyView()
        }
    }
}

// MARK: - Convenience (no trailing)

public extension ZenNavigationRow where Trailing == EmptyView {
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconStyle: ZenNavigationRowIconStyle = .bare,
        accessory: ZenNavigationAccessory = .chevron
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon,
            iconColor: iconColor,
            iconStyle: iconStyle,
            accessory: accessory
        ) {
            EmptyView()
        }
    }
}

// MARK: - Deprecated compatibility

public extension ZenNavigationRow where Trailing == EmptyView {
    static var leadingIconBadgeSize: CGFloat { ZenIconBadge.defaultSize }
    static var leadingIconBadgeCornerRadius: CGFloat { 10 }

    @available(*, deprecated, message: "Use leadingIcon: parameter instead of leadingIconAsset/leadingIconSystemName")
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        leadingIconSystemName: String? = nil,
        iconTint: Color? = nil,
        iconColor: Color? = nil,
        accessory: ZenNavigationAccessory = .chevron
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
            accessory: accessory
        )
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenNavigationRow(
            title: "Account",
            subtitle: "Profile, email, and devices",
            leadingIcon: .hugeIcon(.personCircleFill),
            iconColor: .blue
        )
        ZenNavigationRow(
            title: "Notifications",
            leadingIcon: .hugeIcon(.bellFill),
            iconColor: .red,
            accessory: .none
        )
        ZenNavigationRow(
            title: "Security",
            subtitle: "Password and two-factor",
            leadingIcon: .hugeIcon(.shieldFill),
            iconColor: .green
        )
        ZenNavigationRow(
            title: "Language",
            leadingIcon: .hugeIcon(.globe)
        ) {
            Text("English")
        }
        ZenNavigationRow(
            title: "Billing",
            subtitle: "Managed by workspace owner",
            leadingIcon: .hugeIcon(.creditcardFill),
            iconColor: .orange
        )
        .disabled(true)
    }
    .padding()
    .background(Color.zenBackground)
}
