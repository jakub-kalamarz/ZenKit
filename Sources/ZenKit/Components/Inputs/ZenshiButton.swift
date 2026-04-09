import SwiftUI

public enum ZenButtonVariant {
    case `default`
    case plain
    case glass
    case outline
    case secondary
    case ghost
    case destructive
    case link
}

public enum ZenButtonDecorativeIconPlacement: Equatable, Sendable {
    case leading
    case trailing
}

public struct ZenButtonDecorativeIcon: Equatable, Sendable {
    public let assetName: String
    public let placement: ZenButtonDecorativeIconPlacement

    public init(
        assetName: String,
        placement: ZenButtonDecorativeIconPlacement = .leading
    ) {
        self.assetName = assetName
        self.placement = placement
    }
}

public enum ZenButtonSize {
    case `default`
    case xs
    case sm
    case lg
    case icon
    case iconXs
    case iconSm
    case iconLg

    func minHeight(metrics: ZenResolvedMetrics) -> CGFloat {
        switch self {
        case .default:
            return 44
        case .xs:
            return 32
        case .sm:
            return 36
        case .lg:
            return 52
        case .icon:
            return 44
        case .iconXs:
            return 32
        case .iconSm:
            return 36
        case .iconLg:
            return 52
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .default:
            return ZenSpacing.medium
        case .xs:
            return 12
        case .sm:
            return 14
        case .lg:
            return 20
        case .icon, .iconXs, .iconSm, .iconLg:
            return 0
        }
    }

    var verticalPadding: CGFloat {
        0
    }

    func textFontSpec(theme: ZenTheme) -> ZenResolvedFontSpec {
        let buttonSpec = theme.resolvedTypography.fontSpec(for: .button)

        switch self {
        case .default, .icon:
            return buttonSpec.with(size: 14, weight: .semibold)
        case .xs:
            return buttonSpec.with(size: 12)
        case .sm, .iconXs, .iconSm:
            return buttonSpec.with(size: 13)
        case .lg:
            return buttonSpec.with(size: 15, weight: .semibold)
        case .iconLg:
            return buttonSpec.with(size: 14, weight: .semibold)
        }
    }

    var font: Font {
        textFontSpec(theme: .current).font
    }

    var iconSpacing: CGFloat {
        switch self {
        case .xs, .sm, .iconXs, .iconSm:
            return 6
        case .default, .icon, .lg, .iconLg:
            return 8
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .xs, .sm:
            return 14
        case .default:
            return 16
        case .lg:
            return 18
        case .iconXs:
            return 14
        case .icon, .iconSm:
            return 16
        case .iconLg:
            return 18
        }
    }

    func cornerRadius(theme: ZenTheme, parentRadius: CGFloat? = nil) -> CGFloat {
        guard theme.cornerStyle != .none else {
            return 0
        }

        let controlCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentRadius)
        let expandedCornerRadius = parentRadius.map { min($0, controlCornerRadius + 2) } ?? (controlCornerRadius + 2)

        switch self {
        case .xs, .iconXs:
            return 8
        case .default, .sm, .icon, .iconSm:
            return controlCornerRadius
        case .lg, .iconLg:
            return expandedCornerRadius
        }
    }

    var isIconOnly: Bool {
        switch self {
        case .icon, .iconXs, .iconSm, .iconLg:
            return true
        default:
            return false
        }
    }

    var supportsDecorativeIcons: Bool {
        isIconOnly == false
    }
}

public struct ZenButtonTextLabel: View {
    let title: LocalizedStringKey
    let size: ZenButtonSize
    let leadingIcon: ZenButtonDecorativeIcon?
    let trailingIcon: ZenButtonDecorativeIcon?

    public init(
        title: LocalizedStringKey,
        size: ZenButtonSize,
        leadingIcon: ZenButtonDecorativeIcon? = nil,
        trailingIcon: ZenButtonDecorativeIcon? = nil
    ) {
        self.title = title
        self.size = size
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
    }

    public var body: some View {
        HStack(spacing: size.iconSpacing) {
            if let leadingIcon {
                decorativeIcon(leadingIcon)
            }

            Text(title)

            if let trailingIcon {
                decorativeIcon(trailingIcon)
            }
        }
    }

    @ViewBuilder
    private func decorativeIcon(_ icon: ZenButtonDecorativeIcon) -> some View {
        ZenIcon(assetName: icon.assetName, size: size.iconSize)
    }
}

public struct ZenButton<Label: View>: View {
    private let variant: ZenButtonVariant
    private let size: ZenButtonSize
    private let isLoading: Bool
    private let fullWidth: Bool
    private let action: () -> Void
    private let label: () -> Label

    public init(
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.fullWidth = fullWidth
        self.action = action
        self.label = label
    }

    public var body: some View {
        Group {
            if variant == .plain {
                Button(action: action) {
                    label()
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    label()
                        .lineLimit(1)
                }
                .buttonStyle(
                    ZenSemanticButtonStyle(
                        variant: variant,
                        size: size,
                        isLoading: isLoading,
                        fullWidth: fullWidth
                    )
                )
            }
        }
        .disabled(isLoading)
    }
}

public extension ZenButton where Label == Text {
    init(
        _ title: LocalizedStringKey,
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            size: size,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        ) {
            Text(title)
        }
    }
}

public extension ZenButton where Label == ZenButtonTextLabel {
    init(
        _ title: LocalizedStringKey,
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        leadingIcon: ZenButtonDecorativeIcon? = nil,
        trailingIcon: ZenButtonDecorativeIcon? = nil,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            variant: variant,
            size: size,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        ) {
            ZenButtonTextLabel(
                title: title,
                size: size,
                leadingIcon: size.supportsDecorativeIcons ? leadingIcon : nil,
                trailingIcon: size.supportsDecorativeIcons ? trailingIcon : nil
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: ZenSpacing.medium) {
        HStack(spacing: ZenSpacing.small) {
            ZenButton("Plain", variant: .plain) {}
            ZenButton("Default") {}
            ZenButton("Glass", variant: .glass) {}
            ZenButton("Outline", variant: .outline) {}
            ZenButton("Secondary", variant: .secondary) {}
        }

        HStack(spacing: ZenSpacing.small) {
            ZenButton("Ghost", variant: .ghost) {}
            ZenButton("Destructive", variant: .destructive) {}
            ZenButton("Link", variant: .link) {}
        }

        HStack(spacing: ZenSpacing.small) {
            ZenButton(variant: .default, size: .icon) {} label: {
                ZenIcon(assetName: "Plus", size: 17)
            }
            ZenButton(variant: .secondary, size: .iconSm, isLoading: true) {} label: {
                ZenIcon(assetName: "ArrowsClockwise", size: 14)
            }
            ZenButton("Large", size: .lg) {}
        }

        HStack(spacing: ZenSpacing.small) {
            ZenButton("Saving", isLoading: true) {}
            ZenButton("Outline", variant: .outline, isLoading: true) {}
        }

        ZenButton("Full Width", fullWidth: true) {}
    }
    .padding()
    .background(Color.zenBackground)
}
