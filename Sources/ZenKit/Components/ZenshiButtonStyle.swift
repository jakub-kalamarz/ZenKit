import SwiftUI

enum ZenButtonBackgroundStyle: Equatable {
    case filled
    case muted
    case transparent
}

enum ZenButtonForegroundStyle: Equatable {
    case primaryText
    case accent
    case inverse
    case destructive
}

struct ZenButtonResolvedStyle {
    let backgroundColor: Color
    let pressedBackgroundColor: Color
    let pressedBackgroundToken: ZenDynamicColor?
    let foregroundLight: ZenColorComponents
    let foregroundDark: ZenColorComponents
    let foregroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let backgroundStyle: ZenButtonBackgroundStyle
    let foregroundStyle: ZenButtonForegroundStyle
    let isTextOnly: Bool

    init(variant: ZenButtonVariant) {
        let colors = ZenTheme.current.resolvedColors

        switch variant {
        case .default:
            backgroundColor = .zenPrimary
            pressedBackgroundColor = colors.primaryPressed.color
            pressedBackgroundToken = colors.primaryPressed
            foregroundLight = colors.primary.light.accessibleForeground
            foregroundDark = colors.primary.dark.accessibleForeground
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .filled
            foregroundStyle = .inverse
            isTextOnly = false
        case .outline:
            backgroundColor = .zenSurface
            pressedBackgroundColor = .zenSurfaceMuted
            pressedBackgroundToken = nil
            foregroundLight = colors.surface.light.accessibleForeground
            foregroundDark = colors.surface.dark.accessibleForeground
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .zenBorder
            borderWidth = 1
            backgroundStyle = .filled
            foregroundStyle = .primaryText
            isTextOnly = false
        case .secondary:
            backgroundColor = .zenSurfaceMuted
            pressedBackgroundColor = .zenBorder.opacity(0.45)
            pressedBackgroundToken = nil
            foregroundLight = colors.surfaceMuted.light.accessibleForeground
            foregroundDark = colors.surfaceMuted.dark.accessibleForeground
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .zenBorder.opacity(0.8)
            borderWidth = 1
            backgroundStyle = .muted
            foregroundStyle = .primaryText
            isTextOnly = false
        case .ghost:
            backgroundColor = .clear
            pressedBackgroundColor = .zenSurfaceMuted.opacity(0.9)
            pressedBackgroundToken = nil
            foregroundLight = colors.textPrimary.light
            foregroundDark = colors.textPrimary.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .transparent
            foregroundStyle = .primaryText
            isTextOnly = false
        case .destructive:
            backgroundColor = .zenCritical
            pressedBackgroundColor = colors.criticalPressed.color
            pressedBackgroundToken = colors.criticalPressed
            foregroundLight = colors.critical.light.accessibleForeground
            foregroundDark = colors.critical.dark.accessibleForeground
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .filled
            foregroundStyle = .destructive
            isTextOnly = false
        case .link:
            backgroundColor = .clear
            pressedBackgroundColor = .clear
            pressedBackgroundToken = nil
            foregroundLight = colors.accent.light
            foregroundDark = colors.accent.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .transparent
            foregroundStyle = .accent
            isTextOnly = true
        }
    }
}

struct ZenSemanticButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    let variant: ZenButtonVariant
    let size: ZenButtonSize
    let isLoading: Bool
    let fullWidth: Bool

    func makeBody(configuration: Configuration) -> some View {
        let theme = ZenTheme.current
        let metrics = theme.resolvedMetrics
        let palette = ZenButtonResolvedStyle(variant: variant)
        let cornerRadius = size.cornerRadius(theme: theme, parentRadius: parentCornerRadius)

        buttonContent(configuration: configuration, palette: palette)
            .font(size.font)
            .foregroundStyle(palette.foregroundColor)
            .frame(
                minWidth: size.isIconOnly ? size.minHeight(metrics: metrics) : nil,
                maxWidth: fullWidth ? .infinity : nil,
                minHeight: size.minHeight(metrics: metrics)
            )
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(background(for: palette, isPressed: configuration.isPressed, cornerRadius: cornerRadius))
            .overlay(border(for: palette, cornerRadius: cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .opacity(opacity(for: configuration))
            .scaleEffect(configuration.isPressed && !isLoading ? 0.985 : 1)
            .animation(loadingAnimation, value: isLoading)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }

    @ViewBuilder
    private func buttonContent(configuration: Configuration, palette: ZenButtonResolvedStyle) -> some View {
        if size.isIconOnly {
            ZStack {
                if isLoading {
                    spinner(palette: palette)
                        .transition(loadingTransition)
                } else {
                    configuration.label
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(contentTransition)
                }
            }
        } else {
            HStack(spacing: size.iconSpacing) {
                if isLoading {
                    spinner(palette: palette)
                        .transition(loadingTransition)
                }

                configuration.label
                    .opacity(isLoading ? 0.92 : 1)
                    .scaleEffect(isLoading ? 0.985 : 1)
            }
        }
    }

    private func spinner(palette: ZenButtonResolvedStyle) -> some View {
        ZenSpinner(
            size: size.spinnerSize,
            tint: palette.foregroundColor,
            showsTrack: false
        )
    }

    private var loadingAnimation: Animation {
        if reduceMotion {
            return .easeInOut(duration: 0.12)
        }

        return .spring(response: 0.28, dampingFraction: 0.84)
    }

    private var loadingTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }

        return .scale(scale: 0.82).combined(with: .opacity)
    }

    private var contentTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }

        return .scale(scale: 0.94).combined(with: .opacity)
    }

    private func background(
        for palette: ZenButtonResolvedStyle,
        isPressed: Bool,
        cornerRadius: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(isPressed && !isLoading ? palette.pressedBackgroundColor : palette.backgroundColor)
    }

    private func border(for palette: ZenButtonResolvedStyle, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(palette.borderColor, lineWidth: palette.borderWidth)
    }

    private func opacity(for configuration: Configuration) -> Double {
        if isLoading {
            return 0.78
        }
        return 1
    }
}

extension ZenButtonSize {
    var spinnerSize: ZenSpinnerSize {
        switch self {
        case .xs, .iconXs:
            return .small
        case .sm, .iconSm, .default, .icon:
            return .medium
        case .lg, .iconLg:
            return .large
        }
    }
}
