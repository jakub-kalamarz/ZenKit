import Foundation
import Testing
@testable import ZenKit

@Suite(.serialized)
struct ZenKitThemeTests {
    private let customColors = ZenThemeColors(
        background: .init(light: .rgb(0.96, 0.98, 1.0), dark: .rgb(0.05, 0.08, 0.12)),
        surface: .init(light: .rgb(1.0, 1.0, 1.0), dark: .rgb(0.09, 0.12, 0.16)),
        surfaceMuted: .init(light: .rgb(0.93, 0.95, 0.98), dark: .rgb(0.12, 0.15, 0.19)),
        border: .init(light: .rgb(0.74, 0.82, 0.9), dark: .rgb(0.28, 0.36, 0.45)),
        textPrimary: .init(light: .rgb(0.08, 0.11, 0.16), dark: .rgb(0.93, 0.96, 1.0)),
        textMuted: .init(light: .rgb(0.36, 0.42, 0.49), dark: .rgb(0.65, 0.71, 0.8)),
        accent: .init(light: .rgb(0.051, 0.6471, 0.9137), dark: .rgb(0.2196, 0.7412, 0.9961)),
        primary: .init(light: .rgb(0.2039, 0.3882, 0.9294), dark: .rgb(0.502, 0.7098, 0.9882)),
        primaryPressed: .init(light: .rgb(0.16, 0.31, 0.77), dark: .rgb(0.39, 0.55, 0.79)),
        primarySubtle: .init(light: .rgb(0.9, 0.94, 1.0), dark: .rgb(0.13, 0.18, 0.28)),
        primaryForeground: .init(light: .rgb(1, 1, 1), dark: .rgb(0, 0, 0)),
        focusRing: .init(light: .rgb(0.41, 0.58, 0.95), dark: .rgb(0.6, 0.76, 1)),
        success: .init(light: .rgb(0.0863, 0.6275, 0.2784), dark: .rgb(0.2902, 0.8667, 0.451)),
        successSubtle: .init(light: .rgb(0.9, 0.97, 0.92), dark: .rgb(0.11, 0.2, 0.13)),
        successBorder: .init(light: .rgb(0.71, 0.88, 0.76), dark: .rgb(0.19, 0.39, 0.24)),
        warning: .init(light: .rgb(0.851, 0.3725, 0.0078), dark: .rgb(0.9843, 0.6784, 0.1922)),
        warningSubtle: .init(light: .rgb(1, 0.95, 0.9), dark: .rgb(0.24, 0.17, 0.08)),
        warningBorder: .init(light: .rgb(0.95, 0.79, 0.6), dark: .rgb(0.43, 0.28, 0.12)),
        critical: .init(light: .rgb(0.8627, 0.149, 0.149), dark: .rgb(0.9882, 0.451, 0.451)),
        criticalPressed: .init(light: .rgb(0.73, 0.12, 0.12), dark: .rgb(0.79, 0.27, 0.27)),
        criticalSubtle: .init(light: .rgb(1, 0.92, 0.92), dark: .rgb(0.24, 0.09, 0.09)),
        criticalBorder: .init(light: .rgb(0.95, 0.72, 0.72), dark: .rgb(0.42, 0.18, 0.18))
    )

    @Test
    func defaultThemeUsesNativeIOSDefaultTokens() {
        let colors = ZenTheme.default.resolvedColors
        let native = ZenNativeThemeTokens.defaultResolvedColors

        #expect(colors.background == native.background)
        #expect(colors.surface == native.surface)
        #expect(colors.surfaceMuted == native.surfaceMuted)
        #expect(colors.border == native.border)
        #expect(colors.textPrimary == native.textPrimary)
        #expect(colors.textMuted == native.textMuted)
        #expect(colors.primary == native.primary)
        #expect(colors.accent == native.accent)
    }

    @Test
    func applyingThemeUpdatesGlobalCurrentTheme() {
        let originalTheme = ZenTheme.current
        defer {
            ZenTheme.apply(originalTheme)
        }

        let theme = ZenTheme(cornerStyle: .none)
        ZenTheme.apply(theme)

        #expect(ZenTheme.current == theme)
    }

    @Test
    func customThemeColorsOverrideDefaultTokensDirectly() {
        let theme = ZenTheme(colors: customColors)
        let colors = theme.resolvedColors

        #expect(colors.background == customColors.background)
        #expect(colors.primary == customColors.primary)
        #expect(colors.accent == customColors.accent)
        #expect(colors.success == customColors.success)
        #expect(colors.warning == customColors.warning)
        #expect(colors.critical == customColors.critical)
    }

    @Test
    func customThemeColorsMaintainStrongForegroundContrast() {
        let colors = ZenTheme(colors: customColors).resolvedColors
        let primaryLightContrast = contrastRatio(colors.primary.light, colors.primaryForeground.light)
        let primaryDarkContrast = contrastRatio(colors.primary.dark, colors.primaryForeground.dark)

        #expect(primaryLightContrast >= 4.5)
        #expect(primaryDarkContrast >= 4.5)
    }

    @Test
    func directConcreteColorOverridesReplaceDefaultsAsIs() {
        let colors = ZenTheme(colors: customColors).resolvedColors

        #expect(colors.primaryPressed == customColors.primaryPressed)
        #expect(colors.primarySubtle == customColors.primarySubtle)
        #expect(colors.focusRing == customColors.focusRing)
        #expect(colors.successSubtle == customColors.successSubtle)
        #expect(colors.warningBorder == customColors.warningBorder)
        #expect(colors.criticalPressed == customColors.criticalPressed)
    }

    @Test
    func compactThemeChangesResolvedMetrics() {
        let theme = ZenTheme(
            density: .compact,
            cornerStyle: .rounded,
            motion: .standard
        )

        #expect(theme.resolvedMetrics.controlHeight < ZenTheme.default.resolvedMetrics.controlHeight)
    }

    @Test
    func defaultTypographyMapsDisplayBodyAndCodeFamiliesToRoles() {
        let typography = ZenTheme.default.resolvedTypography

        #expect(typography.fontSpec(for: .heading).familyRole == .display)
        #expect(typography.fontSpec(for: .title).familyRole == .display)
        #expect(typography.fontSpec(for: .body).familyRole == .body)
        #expect(typography.fontSpec(for: .label).familyRole == .body)
        #expect(typography.fontSpec(for: .caption).familyRole == .body)
        #expect(typography.fontSpec(for: .button).familyRole == .body)
        #expect(typography.fontSpec(for: .mono).familyRole == .code)
    }

    @Test
    func compactDensityPreservesConfiguredFamilies() {
        let comfortable = ZenTheme.default.resolvedTypography
        let compact = ZenTheme(density: .compact).resolvedTypography

        #expect(compact.fontSpec(for: .title).familyRole == comfortable.fontSpec(for: .title).familyRole)
        #expect(compact.fontSpec(for: .button).familyRole == comfortable.fontSpec(for: .button).familyRole)
        #expect(compact.fontSpec(for: .mono).familyRole == .code)
    }

    @Test
    func customTypographyFamiliesFlowIntoResolvedRoleSpecs() {
        let displayFamily = ZenFontFamily(
            regular: "InstrumentSerif-Regular",
            semibold: "InstrumentSerif-SemiBold"
        )
        let codeFamily = ZenFontFamily(regular: "JetBrainsMono-Regular")
        let theme = ZenTheme(
            typography: ZenTypography(
                display: .init(source: .custom(displayFamily)),
                body: .init(source: .system(.serif)),
                code: .init(source: .custom(codeFamily), fallback: .monospaced)
            )
        )
        let typography = theme.resolvedTypography

        #expect(typography.fontSpec(for: .heading).source == .custom(displayFamily))
        #expect(typography.fontSpec(for: .body).source == .system(.serif))
        #expect(typography.fontSpec(for: .mono).source == .custom(codeFamily))
    }

    @Test
    func missingCustomFontsFallBackToSystemDesignPerFamily() {
        let missingDisplay = ZenFontFamily(regular: "MissingDisplay")
        let missingBody = ZenFontFamily(regular: "MissingBody")
        let missingCode = ZenFontFamily(regular: "MissingCode")
        let typography = ZenTheme(
            typography: ZenTypography(
                display: .init(source: .custom(missingDisplay)),
                body: .init(source: .custom(missingBody)),
                code: .init(source: .custom(missingCode), fallback: .monospaced)
            )
        ).resolvedTypography

        #expect(typography.fontSpec(for: .heading).resolvedSource == .system(.default))
        #expect(typography.fontSpec(for: .body).resolvedSource == .system(.default))
        #expect(typography.fontSpec(for: .mono).resolvedSource == .system(.monospaced))
    }

    @Test
    func defaultTypographyUsesBricolageGrotesqueFamilyForDisplayAndBody() {
        let typography = ZenTheme.default.resolvedTypography

        #expect(typography.fontSpec(for: .heading).source == .custom(.bricolageGrotesque))
        #expect(typography.fontSpec(for: .body).source == .custom(.bricolageGrotesque))
        #expect(typography.fontSpec(for: .button).source == .custom(.bricolageGrotesque))
        #expect(typography.fontSpec(for: .button).weight == .medium)
    }

    @Test
    func noCornerRadiusThemeResolvesSquareShapeValues() {
        let theme = ZenTheme(cornerStyle: .none)

        #expect(theme.resolvedCornerRadius == 0)
        #expect(theme.resolvedCornerRadius(for: ZenRadius.small) == 0)
        #expect(theme.resolvedFullyRoundedCornerRadius(for: 44) == 0)
    }

    @Test
    func roundedThemesPreserveRequestedShapeValues() {
        let roundedTheme = ZenTheme(cornerStyle: .rounded)
        let pronouncedTheme = ZenTheme(cornerStyle: .pronounced)

        #expect(roundedTheme.resolvedCornerRadius(for: ZenRadius.small) == ZenRadius.small)
        #expect(pronouncedTheme.resolvedCornerRadius(for: ZenRadius.large) == ZenRadius.large)
        #expect(roundedTheme.resolvedFullyRoundedCornerRadius(for: 44) == 22)
    }

    @Test
    func nestedCornerRolesFallBackToStandaloneValuesWithoutParentContext() {
        let theme = ZenTheme(cornerStyle: .rounded)

        #expect(theme.resolvedCornerRadius(for: .container) == theme.resolvedCornerRadius)
        #expect(theme.resolvedCornerRadius(for: .nestedContainer) == theme.resolvedCornerRadius)
        #expect(theme.resolvedCornerRadius(for: .control) == ZenRadius.small)
        #expect(theme.resolvedCornerRadius(for: .nestedControl) == ZenRadius.small)
    }

    @Test
    func nestedCornerRolesShrinkFromParentRadiusWithClamping() {
        let theme = ZenTheme(cornerStyle: .rounded)

        #expect(theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: ZenRadius.large) == 20)
        #expect(theme.resolvedCornerRadius(for: .nestedControl, parentRadius: 12) == 8)
        #expect(theme.resolvedCornerRadius(for: .nestedControl, parentRadius: 3) == 0)
    }

    @Test
    func colorComponentsParseHexStrings() {
        let primary = ZenColorComponents.rgb(37.0 / 255.0, 99.0 / 255.0, 235.0 / 255.0)
        let accent = ZenColorComponents.rgb(96.0 / 255.0, 165.0 / 255.0, 250.0 / 255.0)

        #expect(ZenColorComponents(hex: "#2563EB") == primary)
        #expect(ZenColorComponents.hex("60A5FA") == accent)
    }

    @Test
    func colorComponentsRejectInvalidHexStrings() {
        #expect(ZenColorComponents(hex: "#FFF") == nil)
        #expect(ZenColorComponents.hex("#12ZZ99") == nil)
        #expect(ZenColorComponents(hex: "12345") == nil)
    }

    @Test
    func dynamicColorParsesHexStrings() {
        let light = "#2563EB"
        let dark = "#60A5FA"

        let single = ZenDynamicColor(hex: light)
        #expect(single?.light == ZenColorComponents(hex: light))
        #expect(single?.dark == ZenColorComponents(hex: light))

        let pair = ZenDynamicColor(lightHex: light, darkHex: dark)
        #expect(pair?.light == ZenColorComponents(hex: light))
        #expect(pair?.dark == ZenColorComponents(hex: dark))
    }

    @Test
    func applyingAccentToThemeColorsDerivesPrimaryPalette() {
        let accent = ZenDynamicColor(lightHex: "#2563EB", darkHex: "#60A5FA")!
        let base = ZenNativeThemeTokens.defaultResolvedColors
        let modified = base.applying(accent: accent)

        #expect(modified.accent == accent)
        #expect(modified.primary == accent)
        #expect(modified.background == base.background)
        #expect(modified.primaryPressed != base.primaryPressed)
        #expect(modified.primaryForeground.light == accent.light.accessibleForeground)
    }

    @Test
    func themeWithAccentOverridesResolvedColors() {
        let accent = ZenDynamicColor(hex: "#2563EB")!
        let theme = ZenTheme(accent: accent)
        let colors = theme.resolvedColors

        #expect(colors.accent == accent)
        #expect(colors.primary == accent)
        #expect(colors.background == ZenNativeThemeTokens.defaultResolvedColors.background)
    }
}

private func contrastRatio(_ lhs: ZenColorComponents, _ rhs: ZenColorComponents) -> Double {
    let lighter = max(relativeLuminance(lhs), relativeLuminance(rhs))
    let darker = min(relativeLuminance(lhs), relativeLuminance(rhs))

    return (lighter + 0.05) / (darker + 0.05)
}

private func relativeLuminance(_ color: ZenColorComponents) -> Double {
    let linearRed = linearize(color.red)
    let linearGreen = linearize(color.green)
    let linearBlue = linearize(color.blue)

    return (0.2126 * linearRed) + (0.7152 * linearGreen) + (0.0722 * linearBlue)
}

private func linearize(_ component: Double) -> Double {
    if component <= 0.04045 {
        return component / 12.92
    }

    return pow((component + 0.055) / 1.055, 2.4)
}
