import SwiftUI

public struct ZenButtonLabel<Label: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    
    private let variant: ZenButtonVariant
    private let size: ZenButtonSize
    private let fullWidth: Bool
    private let label: () -> Label

    public init(
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        fullWidth: Bool = false,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.fullWidth = fullWidth
        self.label = label
    }

    public var body: some View {
        if variant == .plain {
            label()
                .lineLimit(1)
                .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
        } else {
            let theme = ZenTheme.current
            let metrics = theme.resolvedMetrics
            let palette = ZenButtonResolvedStyle(variant: variant)
            let cornerRadius = size.cornerRadius(theme: theme, parentRadius: parentCornerRadius)

            label()
                .lineLimit(1)
                .font(size.font)
                .foregroundStyle(palette.foregroundColor)
                .frame(
                    minWidth: size.isIconOnly ? size.minHeight(metrics: metrics) : nil,
                    maxWidth: fullWidth ? .infinity : nil,
                    minHeight: size.minHeight(metrics: metrics)
                )
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .background(ZenButtonBackground(palette: palette, isPressed: false, cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(palette.borderColor, lineWidth: palette.borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

public extension ZenButtonLabel where Label == Text {
    init(
        _ title: LocalizedStringKey,
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        fullWidth: Bool = false
    ) {
        self.init(
            variant: variant,
            size: size,
            fullWidth: fullWidth
        ) {
            Text(title)
        }
    }
}

public extension ZenButtonLabel where Label == ZenButtonTextLabel {
    init(
        _ title: LocalizedStringKey,
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        leadingIcon: ZenButtonDecorativeIcon? = nil,
        trailingIcon: ZenButtonDecorativeIcon? = nil,
        fullWidth: Bool = false
    ) {
        self.init(
            variant: variant,
            size: size,
            fullWidth: fullWidth
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
            ZenButtonLabel("Plain", variant: .plain)
            ZenButtonLabel("Default")
            ZenButtonLabel("Glass", variant: .glass)
            ZenButtonLabel("Outline", variant: .outline)
            ZenButtonLabel("Secondary", variant: .secondary)
        }

        HStack(spacing: ZenSpacing.small) {
            ZenButtonLabel("Ghost", variant: .ghost)
            ZenButtonLabel("Destructive", variant: .destructive)
            ZenButtonLabel("Link", variant: .link)
        }

        HStack(spacing: ZenSpacing.small) {
            ZenButtonLabel(variant: .default, size: .icon) {
                ZenIcon(assetName: "Plus", size: 17)
            }
            ZenButtonLabel("Large", size: .lg)
        }

        ZenButtonLabel("Full Width", fullWidth: true)
    }
    .padding()
    .background(Color.zenBackground)
}
