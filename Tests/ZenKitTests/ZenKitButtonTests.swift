import Testing
@testable import ZenKit

struct ZenKitButtonTests {
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
        let trailing = ZenButtonDecorativeIcon(assetName: "ArrowRight", placement: .trailing)

        #expect(leading.assetName == "GoogleLogo")
        #expect(leading.placement == .leading)
        #expect(trailing.assetName == "ArrowRight")
        #expect(trailing.placement == .trailing)
    }
}
