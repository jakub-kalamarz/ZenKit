import SwiftUI

public enum ZenButtonVariant {
    case `default`
    case plain
    case glass
    case glassProminent
    case outline
    case secondary
    case ghost
    case destructive
    case link
}

public enum ZenButtonShape: Equatable, Sendable {
    /// Theme-derived rounded rectangle (default).
    case automatic
    /// Fully rounded pill, regardless of size.
    case capsule
}

private struct ZenButtonShapeKey: EnvironmentKey {
    static let defaultValue: ZenButtonShape = .automatic
}

public extension EnvironmentValues {
    var zenButtonShape: ZenButtonShape {
        get { self[ZenButtonShapeKey.self] }
        set { self[ZenButtonShapeKey.self] = newValue }
    }
}

public extension View {
    /// Overrides the corner shape of every `ZenButton` in this subtree.
    func zenButtonShape(_ shape: ZenButtonShape) -> some View {
        environment(\.zenButtonShape, shape)
    }
}

public enum ZenButtonDecorativeIconPlacement: Equatable, Sendable {
    case leading
    case trailing
}

public struct ZenButtonDecorativeIcon: Equatable, Sendable {
    public let source: ZenIconSource
    public let placement: ZenButtonDecorativeIconPlacement

    public init(
        assetName: String,
        renderingMode: ZenIconRenderingMode,
        placement: ZenButtonDecorativeIconPlacement = .leading
    ) {
        self.source = .asset(assetName, renderingMode: renderingMode)
        self.placement = placement
    }

    public init(
        systemName: String,
        placement: ZenButtonDecorativeIconPlacement = .leading
    ) {
        self.source = .system(systemName)
        self.placement = placement
    }

    public init(
        source: ZenIconSource,
        placement: ZenButtonDecorativeIconPlacement = .leading
    ) {
        self.source = source
        self.placement = placement
    }

    public var assetName: String? {
        guard case .asset(let assetName, _) = source else {
            return nil
        }

        return assetName
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
            return metrics.controlHeight
        case .xs:
            return metrics.controlHeightSmall
        case .sm:
            return metrics.controlHeightMedium - 8
        case .lg:
            return metrics.controlHeightLarge
        case .icon:
            return metrics.controlHeight
        case .iconXs:
            return metrics.controlHeightSmall
        case .iconSm:
            return metrics.controlHeightMedium - 8
        case .iconLg:
            return metrics.controlHeightLarge
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .default:
            return 16
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
        let buttonSpec = theme.resolvedTypography.fontSpec(for: .body2)

        switch self {
        case .xs, .sm, .iconXs, .iconSm:
            let size: CGFloat = switch self {
            case .xs, .iconXs: 12
            case .sm, .iconSm: 13
            default: 12
            }
            return buttonSpec.with(size: size, weight: .medium)
        case .default, .icon:
            return buttonSpec.with(size: 14, weight: .semibold)
        case .lg, .iconLg:
            return buttonSpec.with(size: 15, weight: .semibold)
        }
    }

    var font: Font {
        textFontSpec(theme: .current).font
    }

    var iconSpacing: CGFloat {
        switch self {
        case .xs, .sm, .iconXs, .iconSm:
            return 6
        case .default, .icon:
            return 8
        case .lg, .iconLg:
            return 8
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .xs, .iconXs:
            return 14
        case .sm, .iconSm:
            return 14
        case .default, .icon:
            return 16
        case .lg, .iconLg:
            return 18
        }
    }

    func cornerRadius(theme: ZenTheme, parentRadius: CGFloat? = nil) -> CGFloat {
        guard theme.cornerStyle != .none else {
            return 0
        }

        let controlCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentRadius)

        switch self {
        case .xs, .iconXs:
            return 2
        case .sm, .iconSm:
            return 6
        case .default, .icon, .lg, .iconLg:
            return controlCornerRadius
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

    func resolvedFrame(metrics: ZenResolvedMetrics, fullWidth: Bool) -> ZenControlFrame {
        let height = minHeight(metrics: metrics)

        if isIconOnly {
            return ZenControlFrame(width: height, height: height, maxWidth: nil, minHeight: nil)
        }

        return ZenControlFrame(width: nil, height: nil, maxWidth: fullWidth ? .infinity : nil, minHeight: height)
    }
}

struct ZenControlFrame: Equatable {
    let width: CGFloat?
    let height: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
}

public struct ZenButtonTextLabel: View {
    let title: LocalizedStringKey
    let size: ZenButtonSize
    let leadingIcon: ZenIconSource?
    let trailingIcon: ZenIconSource?

    public init(
        title: LocalizedStringKey,
        size: ZenButtonSize,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil
    ) {
        self.title = title
        self.size = size
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
    }

    public var body: some View {
        #if DEBUG
        #endif
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
    private func decorativeIcon(_ icon: ZenIconSource) -> some View {
        ZenIcon(source: icon, size: size.iconSize)
    }
}

public struct ZenButton<Label: View>: View {
    @Environment(\.zenHapticsOverride) private var hapticsOverride

    private let variant: ZenButtonVariant
    private let size: ZenButtonSize
    private let isLoading: Bool
    private let fullWidth: Bool
    private let glassTint: Color?
    private let action: () -> Void
    private let label: () -> Label

    public init(
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        isLoading: Bool = false,
        fullWidth: Bool = false,
        glassTint: Color? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.fullWidth = fullWidth
        self.glassTint = glassTint
        self.action = action
        self.label = label
    }

    public var body: some View {
        #if DEBUG
        #endif
        Group {
            if variant == .plain {
                Button(action: performAction) {
                    label()
                        .lineLimit(1)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: performAction) {
                    label()
                        .lineLimit(1)
                }
                .buttonStyle(
                    ZenSemanticButtonStyle(
                        variant: variant,
                        size: size,
                        isLoading: isLoading,
                        fullWidth: fullWidth,
                        glassTint: glassTint
                    )
                )
            }
        }
        .disabled(isLoading)
    }

    private func performAction() {
        guard !isLoading else { return }

        ZenHapticEngine.perform(.buttonPress, haptics: hapticsOverride)
        action()
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
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
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
            title,
            variant: variant,
            size: size,
            leadingIcon: leadingIcon?.source,
            trailingIcon: trailingIcon?.source,
            isLoading: isLoading,
            fullWidth: fullWidth,
            action: action
        )
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
                ZenIcon(systemName: "plus")
            }
            ZenButton(variant: .secondary, size: .iconSm, isLoading: true) {} label: {
                ZenIcon(systemName: "arrow.clockwise")
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
