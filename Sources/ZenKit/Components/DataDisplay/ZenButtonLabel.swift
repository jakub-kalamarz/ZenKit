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
        Group {
        if variant == .plain {
            label()
                .lineLimit(1)
                .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
        } else {
            let theme = ZenTheme.current
            let metrics = theme.resolvedMetrics
            let palette = ZenButtonResolvedStyle(variant: variant)
            let cornerRadius = size.cornerRadius(theme: theme, parentRadius: parentCornerRadius)
            let frame = size.resolvedFrame(metrics: metrics, fullWidth: fullWidth)

            label()
                .lineLimit(1)
                .font(size.font)
                .foregroundStyle(palette.foregroundColor)
                .frame(
                    width: frame.width,
                    height: frame.height
                )
                .frame(
                    maxWidth: frame.maxWidth,
                    minHeight: frame.minHeight
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
        .fixedSize(horizontal: !fullWidth, vertical: true)
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
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
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

    init(
        _ title: LocalizedStringKey,
        variant: ZenButtonVariant = .default,
        size: ZenButtonSize = .default,
        leadingIcon: ZenButtonDecorativeIcon? = nil,
        trailingIcon: ZenButtonDecorativeIcon? = nil,
        fullWidth: Bool = false
    ) {
        self.init(
            title,
            variant: variant,
            size: size,
            leadingIcon: leadingIcon?.source,
            trailingIcon: trailingIcon?.source,
            fullWidth: fullWidth
        )
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
