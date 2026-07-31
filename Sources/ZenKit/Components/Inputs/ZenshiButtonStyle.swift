import SwiftUI

enum ZenButtonBackgroundStyle: Equatable {
    case filled
    case glass
    case glassProminent
    case muted
    case transparent

    var usesNativeGlassEffect: Bool {
        switch self {
        case .glass, .glassProminent:
            return true
        case .filled, .muted, .transparent:
            return false
        }
    }
}

enum ZenButtonForegroundStyle: Equatable {
    case primaryText
    case accent
    case inverse
    case destructive
}

struct ZenButtonResolvedStyle {
    let backgroundToken: ZenDynamicColor?
    let backgroundColor: Color
    let pressedBackgroundColor: Color
    let pressedBackgroundToken: ZenDynamicColor?
    let borderToken: ZenDynamicColor?
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
        let outlineStyle = ZenControlSurfaceStyle.outline()

        switch variant {
        case .default:
            backgroundToken = colors.primary
            backgroundColor = .zenPrimary
            pressedBackgroundColor = colors.primaryPressed.color
            pressedBackgroundToken = colors.primaryPressed
            borderToken = nil
            foregroundLight = colors.primary.light.accessibleForeground
            foregroundDark = colors.primary.dark.accessibleForeground
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .filled
            foregroundStyle = .inverse
            isTextOnly = false
        case .plain:
            backgroundToken = nil
            backgroundColor = .clear
            pressedBackgroundColor = .clear
            pressedBackgroundToken = nil
            borderToken = nil
            foregroundLight = colors.textPrimary.light
            foregroundDark = colors.textPrimary.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .transparent
            foregroundStyle = .primaryText
            isTextOnly = true
        case .glass:
            backgroundToken = colors.surface
            backgroundColor = .zenSurface
            pressedBackgroundColor = .zenSurfaceMuted
            pressedBackgroundToken = nil
            borderToken = colors.border
            foregroundLight = colors.textPrimary.light
            foregroundDark = colors.textPrimary.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .zenBorder.opacity(0.7)
            borderWidth = 1
            backgroundStyle = .glass
            foregroundStyle = .primaryText
            isTextOnly = false
        case .glassProminent:
            backgroundToken = colors.primary
            backgroundColor = .zenPrimary.opacity(0.55)
            pressedBackgroundColor = .zenPrimary.opacity(0.75)
            pressedBackgroundToken = nil
            borderToken = colors.border
            foregroundLight = colors.textPrimary.light
            foregroundDark = colors.textPrimary.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .zenBorder.opacity(0.5)
            borderWidth = 1
            backgroundStyle = .glassProminent
            foregroundStyle = .primaryText
            isTextOnly = false
        case .outline:
            backgroundToken = outlineStyle.backgroundToken
            backgroundColor = outlineStyle.backgroundColor
            pressedBackgroundColor = .zenSurfaceMuted
            pressedBackgroundToken = nil
            borderToken = outlineStyle.borderToken
            foregroundLight = colors.surface.light.accessibleForeground
            foregroundDark = colors.surface.dark.accessibleForeground
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = outlineStyle.borderColor
            borderWidth = outlineStyle.borderWidth
            backgroundStyle = .filled
            foregroundStyle = .primaryText
            isTextOnly = false
        case .secondary:
            backgroundToken = colors.surface
            backgroundColor = .zenSurface
            pressedBackgroundColor = .zenSurfaceTint
            pressedBackgroundToken = colors.surfaceTint
            borderToken = colors.borderSubtle
            foregroundLight = colors.textPrimary.light
            foregroundDark = colors.textPrimary.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .zenBorderSubtle
            borderWidth = 1
            backgroundStyle = .filled
            foregroundStyle = .primaryText
            isTextOnly = false
        case .ghost:
            backgroundToken = nil
            backgroundColor = .clear
            pressedBackgroundColor = .zenSurfaceTint
            pressedBackgroundToken = nil
            borderToken = nil
            foregroundLight = colors.textPrimary.light
            foregroundDark = colors.textPrimary.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .transparent
            foregroundStyle = .primaryText
            isTextOnly = false
        case .destructive:
            backgroundToken = colors.criticalTint
            backgroundColor = .zenCriticalTint
            pressedBackgroundColor = colors.criticalSubtle.color
            pressedBackgroundToken = colors.criticalSubtle
            borderToken = nil
            foregroundLight = colors.critical.light
            foregroundDark = colors.critical.dark
            foregroundColor = ZenDynamicColor(light: foregroundLight, dark: foregroundDark).color
            borderColor = .clear
            borderWidth = 0
            backgroundStyle = .filled
            foregroundStyle = .destructive
            isTextOnly = false
        case .link:
            backgroundToken = nil
            backgroundColor = .clear
            pressedBackgroundColor = .clear
            pressedBackgroundToken = nil
            borderToken = nil
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
    @Environment(\.zenButtonShape) private var buttonShape
    @Environment(\.isEnabled) private var isEnabled

    let variant: ZenButtonVariant
    let size: ZenButtonSize
    let isLoading: Bool
    let fullWidth: Bool
    let glassTint: Color?

    func makeBody(configuration: Configuration) -> some View {
        if size.isIconOnly {
            iconOnlyBody(configuration: configuration)
        } else {
            labelledBody(configuration: configuration)
        }
    }

    /// Icon-only buttons are rendered as a bare icon: no background, border,
    /// shape or shadow, just the glyph in a 44pt-friendly hit area. Any shape
    /// would fight the surrounding container (a sheet toolbar, a card header),
    /// so the variant only contributes the icon's tint.
    private func iconOnlyBody(configuration: Configuration) -> some View {
        let theme = ZenTheme.current
        let metrics = theme.resolvedMetrics
        let palette = ZenButtonResolvedStyle(variant: variant)
        let side = size.minHeight(metrics: metrics)

        return buttonContent(configuration: configuration, palette: palette)
            .font(size.font)
            .foregroundStyle(iconTint(palette: palette))
            .frame(width: side, height: side)
            .contentShape(.rect)
            .opacity(opacity(for: configuration))
            .scaleEffect(configuration.isPressed && !isLoading ? 0.92 : 1)
            .animation(loadingAnimation, value: isLoading)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.16), value: isDisabled)
    }

    /// The variant's own foreground, except where it assumes a filled surface
    /// behind the glyph — without a background an inverse tint would vanish.
    private func iconTint(palette: ZenButtonResolvedStyle) -> Color {
        palette.foregroundStyle == .inverse ? .zenTextPrimary : palette.foregroundColor
    }

    private func labelledBody(configuration: Configuration) -> some View {
        let theme = ZenTheme.current
        let metrics = theme.resolvedMetrics
        let palette = ZenButtonResolvedStyle(variant: variant)
        // A capsule is a rounded rect with radius = half the control height
        // (SwiftUI clamps to the shorter side, giving fully rounded ends).
        let cornerRadius = buttonShape == .capsule
            ? size.minHeight(metrics: metrics) / 2
            : size.cornerRadius(theme: theme, parentRadius: parentCornerRadius)
        let frame = size.resolvedFrame(metrics: metrics, fullWidth: fullWidth)

        return buttonContent(configuration: configuration, palette: palette)
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
            .modifier(
                ZenButtonSurfaceModifier(
                    palette: palette,
                    isPressed: configuration.isPressed && !isLoading,
                    cornerRadius: cornerRadius,
                    glassTint: glassTint
                )
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .saturation(isDisabled ? 0.4 : 1)
            .opacity(opacity(for: configuration))
            .scaleEffect(configuration.isPressed && !isLoading ? 0.98 : 1)
            .animation(loadingAnimation, value: isLoading)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.16), value: isDisabled)
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

    /// Disabled by the consumer via `.disabled(_:)`, as opposed to the internal
    /// `.disabled(isLoading)` that `ZenButton` applies while a spinner is shown.
    private var isDisabled: Bool {
        !isEnabled && !isLoading
    }

    private func opacity(for configuration: Configuration) -> Double {
        if isDisabled {
            return 0.5
        }
        if isLoading {
            return 0.78
        }
        return 1
    }
}

struct ZenButtonSurfaceModifier: ViewModifier {
    let palette: ZenButtonResolvedStyle
    let isPressed: Bool
    let cornerRadius: CGFloat
    let glassTint: Color?

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        #if os(iOS)
        if #available(iOS 26, *), palette.backgroundStyle.usesNativeGlassEffect {
            nativeGlassSurface(content: content, shape: shape)
        } else {
            fallbackSurface(content: content, shape: shape)
        }
        #else
        fallbackSurface(content: content, shape: shape)
        #endif
    }

    @available(iOS 26, macOS 26, *)
    @ViewBuilder
    private func nativeGlassSurface(
        content: Content,
        shape: RoundedRectangle
    ) -> some View {
        switch palette.backgroundStyle {
        case .glass:
            if let glassTint {
                content
                    .glassEffect(.regular.tint(glassTint).interactive(), in: shape)
                    .overlay(border(shape: shape))
                    .clipShape(shape)
            } else {
                content
                    .glassEffect(.regular.interactive(), in: shape)
                    .overlay(border(shape: shape))
                    .clipShape(shape)
            }
        case .glassProminent:
            content
                .glassEffect(.regular.tint((glassTint ?? .zenPrimary).opacity(0.5)).interactive(), in: shape)
                .overlay(border(shape: shape))
                .clipShape(shape)
        case .filled, .muted, .transparent:
            fallbackSurface(content: content, shape: shape)
        }
    }

    private func fallbackSurface(
        content: Content,
        shape: RoundedRectangle
    ) -> some View {
        content
            .background(
                ZenButtonBackground(
                    palette: palette,
                    isPressed: isPressed,
                    cornerRadius: cornerRadius,
                    glassTint: glassTint
                )
            )
            .overlay(border(shape: shape))
            .clipShape(shape)
            .modifier(ZenConditionalControlShadow(isEnabled: palette.backgroundStyle == .filled))
    }

    private func border(shape: RoundedRectangle) -> some View {
        shape.strokeBorder(palette.borderColor, lineWidth: palette.borderWidth)
    }
}

struct ZenButtonBackground: View {
    let palette: ZenButtonResolvedStyle
    let isPressed: Bool
    let cornerRadius: CGFloat
    var glassTint: Color? = nil

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        switch palette.backgroundStyle {
        case .filled, .muted, .transparent:
            shape.fill(isPressed ? palette.pressedBackgroundColor : palette.backgroundColor)
        case .glass:
            #if os(iOS)
            if #available(iOS 26, *) {
                if let glassTint {
                    Color.clear.glassEffect(.regular.tint(glassTint), in: shape)
                } else {
                    Color.clear.glassEffect(in: shape)
                }
            } else {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill((isPressed ? palette.pressedBackgroundColor : palette.backgroundColor).opacity(isPressed ? 0.42 : 0.22))
                }
            }
            #else
            ZStack {
                shape.fill(.ultraThinMaterial)
                shape.fill((isPressed ? palette.pressedBackgroundColor : palette.backgroundColor).opacity(isPressed ? 0.42 : 0.22))
            }
            #endif
        case .glassProminent:
            #if os(iOS)
            if #available(iOS 26, *) {
                Color.clear.glassEffect(.regular.tint((glassTint ?? .zenPrimary).opacity(0.5)), in: shape)
            } else {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill((isPressed ? palette.pressedBackgroundColor : palette.backgroundColor).opacity(isPressed ? 0.65 : 0.45))
                }
            }
            #else
            ZStack {
                shape.fill(.ultraThinMaterial)
                shape.fill((isPressed ? palette.pressedBackgroundColor : palette.backgroundColor).opacity(isPressed ? 0.65 : 0.45))
            }
            #endif
        }
    }
}

extension ZenButtonSize {
    /// Matches the loader to the button's own icon metrics so a loading button
    /// keeps the same footprint as its idle state.
    var spinnerSize: ZenSpinnerSize {
        .custom(diameter: iconSize)
    }
}
