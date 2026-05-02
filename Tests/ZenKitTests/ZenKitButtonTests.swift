import CoreGraphics
import Testing
@testable import ZenKit

@Suite(.serialized)
struct ZenKitButtonTests {
    private let contrastThemeColors = ZenThemeColors(
        background: .init(light: .rgb(0.97, 0.97, 0.99), dark: .rgb(0.08, 0.09, 0.11)),
        surface: .init(light: .rgb(0.96, 0.96, 0.98), dark: .rgb(0.12, 0.13, 0.16)),
        surfaceMuted: .init(light: .rgb(0.88, 0.89, 0.92), dark: .rgb(0.17, 0.18, 0.21)),
        border: .init(light: .rgb(0.78, 0.8, 0.85), dark: .rgb(0.28, 0.29, 0.33)),
        textPrimary: .init(light: .rgb(0.1, 0.45, 0.9), dark: .rgb(0.95, 0.8, 0.2)),
        textMuted: .init(light: .rgb(0.4, 0.45, 0.52), dark: .rgb(0.58, 0.63, 0.7)),
        accent: .init(light: .rgb(0.32, 0.18, 0.82), dark: .rgb(0.6, 0.5, 0.95)),
        primary: .init(light: .rgb(0.95, 0.82, 0.22), dark: .rgb(0.22, 0.72, 0.95)),
        primaryPressed: .init(light: .rgb(0.85, 0.72, 0.16), dark: .rgb(0.17, 0.58, 0.79)),
        primarySubtle: .init(light: .rgb(0.99, 0.95, 0.75), dark: .rgb(0.11, 0.18, 0.25)),
        primaryForeground: .init(light: .rgb(0, 0, 0), dark: .rgb(0, 0, 0)),
        focusRing: .init(light: .rgb(0.92, 0.88, 0.4), dark: .rgb(0.35, 0.75, 0.95)),
        success: .init(light: .rgb(0.1, 0.7, 0.3), dark: .rgb(0.2, 0.82, 0.4)),
        successSubtle: .init(light: .rgb(0.88, 0.96, 0.9), dark: .rgb(0.1, 0.2, 0.12)),
        successBorder: .init(light: .rgb(0.68, 0.86, 0.72), dark: .rgb(0.2, 0.38, 0.24)),
        warning: .init(light: .rgb(0.96, 0.55, 0.08), dark: .rgb(0.98, 0.72, 0.24)),
        warningSubtle: .init(light: .rgb(1, 0.94, 0.86), dark: .rgb(0.24, 0.18, 0.09)),
        warningBorder: .init(light: .rgb(0.94, 0.76, 0.58), dark: .rgb(0.42, 0.3, 0.14)),
        critical: .init(light: .rgb(0.98, 0.78, 0.8), dark: .rgb(0.92, 0.34, 0.4)),
        criticalPressed: .init(light: .rgb(0.9, 0.68, 0.71), dark: .rgb(0.78, 0.24, 0.3)),
        criticalSubtle: .init(light: .rgb(1, 0.91, 0.92), dark: .rgb(0.22, 0.08, 0.1)),
        criticalBorder: .init(light: .rgb(0.94, 0.68, 0.72), dark: .rgb(0.4, 0.17, 0.2))
    )

    @Test
    func controlGroupLayoutResolvesAdaptiveThresholds() {
        #expect(ZenControlGroupLayout.horizontal.resolvedLayout(forWidth: 200) == .horizontal)
        #expect(ZenControlGroupLayout.vertical.resolvedLayout(forWidth: 200) == .vertical)
        #expect(ZenControlGroupLayout.adaptive.resolvedLayout(forWidth: 420) == .horizontal)
        #expect(ZenControlGroupLayout.adaptive.resolvedLayout(forWidth: 260) == .vertical)
    }

    @Test
    func controlGroupLayoutUsesExpectedDefaultSpacingAndBreakpoint() {
        #expect(ZenControlGroupLayoutMetrics.defaultSpacing == ZenSpacing.small)
        #expect(ZenControlGroupLayoutMetrics.adaptiveBreakpoint == 320)
    }

    @Test
    func badgeVisualMetricsMatchCompactStyle() {
        #expect(ZenBadgeStyleMetrics.cornerRadius == 8)
        #expect(ZenBadgeStyleMetrics.horizontalPadding == 10)
        #expect(ZenBadgeStyleMetrics.verticalPadding == 6)
        #expect(ZenBadgeStyleMetrics.labelSpacing == 4)
        #expect(ZenBadgeStyleMetrics.removeButtonWidth == 24)
    }

    @Test
    func badgeVisualMetricsSupportCompactRemoveAffordance() {
        #expect(ZenBadgeStyleMetrics.removeDividerVerticalInset == 5)
        #expect(ZenBadgeStyleMetrics.removeIconSize == 10)
    }

    @Test
    func defaultButtonSizeMatchesAccessibleMobileMetrics() {
        let spec = ZenButtonSize.default.textFontSpec(theme: .default)

        #expect(ZenButtonSize.default.minHeight(metrics: .init(
            controlHeight: 44,
            controlHeightSmall: 36,
            controlHeightLarge: 52,
            cardPadding: 16,
            fieldVerticalPadding: 12
        )) == 44)
        #expect(ZenButtonSize.default.horizontalPadding == 16)
        #expect(ZenButtonSize.default.iconSpacing == 8)
        #expect(spec.size == 14)
        #expect(spec.weight == .semibold)
    }

    @Test
    func compactButtonVariantsMatchAccessibleMobileMetrics() {
        let theme = ZenTheme(density: .compact)
        let metrics = theme.resolvedMetrics

        let xsSpec = ZenButtonSize.xs.textFontSpec(theme: theme)
        #expect(ZenButtonSize.xs.minHeight(metrics: metrics) == 32)
        #expect(ZenButtonSize.xs.horizontalPadding == 12)
        #expect(ZenButtonSize.xs.iconSpacing == 6)
        #expect(xsSpec.size == 12)
        #expect(xsSpec.weight == .medium)

        let smSpec = ZenButtonSize.sm.textFontSpec(theme: theme)
        #expect(ZenButtonSize.sm.minHeight(metrics: metrics) == 36)
        #expect(ZenButtonSize.sm.horizontalPadding == 14)
        #expect(ZenButtonSize.sm.iconSpacing == 6)
        #expect(smSpec.size == 13)
        #expect(smSpec.weight == .medium)

        let lgSpec = ZenButtonSize.lg.textFontSpec(theme: theme)
        #expect(ZenButtonSize.lg.minHeight(metrics: metrics) == 52)
        #expect(ZenButtonSize.lg.horizontalPadding == 20)
        #expect(ZenButtonSize.lg.iconSpacing == 8)
        #expect(lgSpec.size == 15)
        #expect(lgSpec.weight == .semibold)
    }

    @Test
    func textButtonSizesResolveDecorativeIconMetrics() {
        #expect(ZenButtonSize.default.iconSize == 16)
        #expect(ZenButtonSize.xs.iconSize == 14)
        #expect(ZenButtonSize.sm.iconSize == 14)
        #expect(ZenButtonSize.lg.iconSize == 18)
        #expect(ZenButtonSize.default.supportsDecorativeIcons)
        #expect(ZenButtonSize.sm.supportsDecorativeIcons)
        #expect(ZenButtonSize.icon.supportsDecorativeIcons == false)
        #expect(ZenButtonSize.iconSm.supportsDecorativeIcons == false)
    }

    @Test
    func decorativeIconPlacementTracksLeadingAndTrailingSlots() {
        let leading = ZenButtonDecorativeIcon(assetName: "GoogleLogo")
        let trailing = ZenButtonDecorativeIcon(systemName: "arrow.right", placement: .trailing)

        #expect(leading.source == .asset("GoogleLogo"))
        #expect(leading.assetName == "GoogleLogo")
        #expect(leading.placement == .leading)
        #expect(trailing.source == .system("arrow.right"))
        #expect(trailing.assetName == nil)
        #expect(trailing.placement == .trailing)
    }

    @Test
    func filledButtonVariantsUseForegroundDerivedFromBackgroundTokens() {
        let originalTheme = ZenTheme.current
        defer { ZenTheme.apply(originalTheme) }

        ZenTheme.apply(ZenTheme(colors: contrastThemeColors))

        let colors = ZenTheme.current.resolvedColors
        let buttonVariants: [(ZenButtonVariant, ZenDynamicColor)] = [
            (.default, colors.primary),
            (.outline, colors.surface),
            (.secondary, colors.surfaceMuted),
            (.destructive, colors.critical),
        ]

        for (variant, background) in buttonVariants {
            let style = ZenButtonResolvedStyle(variant: variant)

            #expect(style.foregroundLight == background.light.accessibleForeground)
            #expect(style.foregroundDark == background.dark.accessibleForeground)
        }
    }

    @Test
    func glassButtonVariantUsesPrimaryTextForegroundAndGlassBackgroundStyle() {
        let originalTheme = ZenTheme.current
        defer { ZenTheme.apply(originalTheme) }

        ZenTheme.apply(ZenTheme(colors: contrastThemeColors))

        let colors = ZenTheme.current.resolvedColors
        let style = ZenButtonResolvedStyle(variant: .glass)

        #expect(style.foregroundLight == colors.textPrimary.light)
        #expect(style.foregroundDark == colors.textPrimary.dark)
        #expect(style.backgroundStyle == .glass)
        #expect(!style.isTextOnly)
    }

    @Test
    func outlinedButtonsShareChromeWithBorderedInputControls() {
        let outlineButton = ZenButtonResolvedStyle(variant: .outline)
        let controlStyle = ZenControlSurfaceStyle.outline()

        #expect(outlineButton.backgroundToken == controlStyle.backgroundToken)
        #expect(outlineButton.borderToken == controlStyle.borderToken)
        #expect(outlineButton.borderWidth == controlStyle.borderWidth)
    }

    @Test
    func fieldInputsShareOutlineControlChrome() {
        let fieldStyle = ZenControlSurfaceStyle.field()
        let colors = ZenTheme.current.resolvedColors

        #expect(fieldStyle.backgroundToken == colors.surface)
        #expect(fieldStyle.borderToken == colors.border)
        #expect(fieldStyle.borderWidth == 1)
    }

    @Test
    func searchInputsUseMutedControlChrome() {
        let searchStyle = ZenControlSurfaceStyle.searchField()
        let colors = ZenTheme.current.resolvedColors

        #expect(searchStyle.backgroundToken == colors.surfaceMuted)
        #expect(searchStyle.borderToken == colors.border)
        #expect(searchStyle.borderWidth == 1)
    }

    @Test
    func transparentButtonVariantsKeepSemanticForegrounds() {
        let originalTheme = ZenTheme.current
        defer { ZenTheme.apply(originalTheme) }

        ZenTheme.apply(ZenTheme(colors: contrastThemeColors))

        let colors = ZenTheme.current.resolvedColors
        let ghostStyle = ZenButtonResolvedStyle(variant: .ghost)
        let linkStyle = ZenButtonResolvedStyle(variant: .link)
        let plainStyle = ZenButtonResolvedStyle(variant: .plain)
        let glassStyle = ZenButtonResolvedStyle(variant: .glass)

        #expect(ghostStyle.foregroundLight == colors.textPrimary.light)
        #expect(ghostStyle.foregroundDark == colors.textPrimary.dark)
        #expect(glassStyle.foregroundLight == colors.textPrimary.light)
        #expect(glassStyle.foregroundDark == colors.textPrimary.dark)
        #expect(linkStyle.foregroundLight == colors.accent.light)
        #expect(linkStyle.foregroundDark == colors.accent.dark)
        #expect(plainStyle.foregroundLight == colors.textPrimary.light)
        #expect(plainStyle.foregroundDark == colors.textPrimary.dark)
    }

    @Test
    func buttonLabelExposesExpectedInitializers() {
        // Just verify it compiles and initializes
        _ = ZenButtonLabel("Test")
        _ = ZenButtonLabel("Test", variant: .plain)
        _ = ZenButtonLabel("Test", variant: .glass)
        _ = ZenButtonLabel("Test", variant: .outline)
        _ = ZenButtonLabel("Test", size: .sm)
        _ = ZenButtonLabel("Test", fullWidth: true)
        _ = ZenButtonLabel("Test", leadingIcon: .asset("Plus"), trailingIcon: .system("arrow.right"))
        _ = ZenButtonLabel("Test", leadingIcon: .init(assetName: "Plus"), trailingIcon: .init(assetName: "ArrowRight"))
    }
}
