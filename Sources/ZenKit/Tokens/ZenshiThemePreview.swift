import SwiftUI

#if canImport(UIKit)
import UIKit

private struct ZenPreviewSeedColor {
    var light: Color
    var dark: Color

    var dynamicColor: ZenDynamicColor {
        ZenDynamicColor(
            light: ZenColorComponents(platformColor: UIColor(light)),
            dark: ZenColorComponents(platformColor: UIColor(dark))
        )
    }
}

private struct ZenPreviewBaseColor {
    var light: Color
    var dark: Color

    var dynamicColor: ZenDynamicColor {
        ZenDynamicColor(
            light: ZenColorComponents(platformColor: UIColor(light)),
            dark: ZenColorComponents(platformColor: UIColor(dark))
        )
    }
}

struct ZenThemePreviewScope<Content: View>: View {
    let theme: ZenTheme
    let content: () -> Content

    @State private var originalTheme: ZenTheme?

    init(theme: ZenTheme, @ViewBuilder content: @escaping () -> Content) {
        self.theme = theme
        self.content = content
    }

    var body: some View {
        content()
            .task(id: theme) {
                if originalTheme == nil {
                    originalTheme = ZenTheme.current
                }
                ZenTheme.apply(theme)
            }
            .onDisappear {
                if let originalTheme {
                    ZenTheme.apply(originalTheme)
                }
            }
    }
}

private struct ZenThemeColorWorkbenchPreview: View {
    @State private var primary = ZenPreviewSeedColor(
        light: .init(red: 0.1294, green: 0.3882, blue: 0.9725),
        dark: .init(red: 0.3765, green: 0.6471, blue: 0.9804)
    )
    @State private var accent = ZenPreviewSeedColor(
        light: .init(red: 0.0, green: 0.6275, blue: 0.702),
        dark: .init(red: 0.2784, green: 0.7765, blue: 0.8314)
    )
    @State private var background = ZenPreviewBaseColor(
        light: ZenNativeThemeTokens.defaultResolvedColors.background.light.color,
        dark: ZenNativeThemeTokens.defaultResolvedColors.background.dark.color
    )
    @State private var surface = ZenPreviewBaseColor(
        light: ZenNativeThemeTokens.defaultResolvedColors.surface.light.color,
        dark: ZenNativeThemeTokens.defaultResolvedColors.surface.dark.color
    )
    @State private var surfaceMuted = ZenPreviewBaseColor(
        light: ZenNativeThemeTokens.defaultResolvedColors.surfaceMuted.light.color,
        dark: ZenNativeThemeTokens.defaultResolvedColors.surfaceMuted.dark.color
    )
    @State private var border = ZenPreviewBaseColor(
        light: ZenNativeThemeTokens.defaultResolvedColors.border.light.color,
        dark: ZenNativeThemeTokens.defaultResolvedColors.border.dark.color
    )
    @State private var textPrimary = ZenPreviewBaseColor(
        light: ZenNativeThemeTokens.defaultResolvedColors.textPrimary.light.color,
        dark: ZenNativeThemeTokens.defaultResolvedColors.textPrimary.dark.color
    )
    @State private var textMuted = ZenPreviewBaseColor(
        light: ZenNativeThemeTokens.defaultResolvedColors.textMuted.light.color,
        dark: ZenNativeThemeTokens.defaultResolvedColors.textMuted.dark.color
    )
    @State private var sampleText: String = "#00A0B3"

    private var theme: ZenTheme {
        ZenTheme(
            colors: ZenThemeColors(
                background: background.dynamicColor,
                surface: surface.dynamicColor,
                surfaceMuted: surfaceMuted.dynamicColor,
                border: border.dynamicColor,
                textPrimary: textPrimary.dynamicColor,
                textMuted: textMuted.dynamicColor,
                accent: accent.dynamicColor,
                primary: primary.dynamicColor,
                primaryPressed: ZenNativeThemeTokens.defaultResolvedColors.primaryPressed,
                primarySubtle: ZenNativeThemeTokens.defaultResolvedColors.primarySubtle,
                primaryForeground: ZenNativeThemeTokens.defaultResolvedColors.primaryForeground,
                focusRing: ZenNativeThemeTokens.defaultResolvedColors.focusRing,
                success: ZenNativeThemeTokens.defaultResolvedColors.success,
                successSubtle: ZenNativeThemeTokens.defaultResolvedColors.successSubtle,
                successBorder: ZenNativeThemeTokens.defaultResolvedColors.successBorder,
                warning: ZenNativeThemeTokens.defaultResolvedColors.warning,
                warningSubtle: ZenNativeThemeTokens.defaultResolvedColors.warningSubtle,
                warningBorder: ZenNativeThemeTokens.defaultResolvedColors.warningBorder,
                critical: ZenNativeThemeTokens.defaultResolvedColors.critical,
                criticalPressed: ZenNativeThemeTokens.defaultResolvedColors.criticalPressed,
                criticalSubtle: ZenNativeThemeTokens.defaultResolvedColors.criticalSubtle,
                criticalBorder: ZenNativeThemeTokens.defaultResolvedColors.criticalBorder
            )
        )
    }

    var body: some View {
        ZenThemePreviewScope(theme: theme) {
            ScrollView {
                VStack(alignment: .leading, spacing: ZenSpacing.large) {
                    controls

                    VStack(spacing: ZenSpacing.large) {
                        previewPanel(title: "Light", scheme: .light)
                        previewPanel(title: "Dark", scheme: .dark)
                    }
                }
                .padding(ZenSpacing.large)
            }
            .background(Color.zenBackground)
        }
    }

    private var controls: some View {
        ZenCard(
            title: "Theme Color Workbench",
            subtitle: "Edytuj neutralne tokeny i semantic colors bezpośrednio obok definicji theme."
        ) {
            VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                colorControlSection(title: "Background", color: $background)
                colorControlSection(title: "Surface", color: $surface)
                colorControlSection(title: "Surface Muted", color: $surfaceMuted)
                colorControlSection(title: "Border", color: $border)
                colorControlSection(title: "Text Primary", color: $textPrimary)
                colorControlSection(title: "Text Muted", color: $textMuted)
                seedControlSection(title: "Primary", seedColor: $primary)
                seedControlSection(title: "Accent", seedColor: $accent)
            }
        }
    }

    @ViewBuilder
    private func colorControlSection(
        title: String,
        color: Binding<ZenPreviewBaseColor>
    ) -> some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text(title)
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextPrimary)

            HStack(spacing: ZenSpacing.medium) {
                ColorPicker("Light", selection: color.light)
                Text(color.wrappedValue.dynamicColor.light.hexString)
                    .font(.zenMono)
                    .foregroundStyle(Color.zenTextMuted)
            }

            HStack(spacing: ZenSpacing.medium) {
                ColorPicker("Dark", selection: color.dark)
                Text(color.wrappedValue.dynamicColor.dark.hexString)
                    .font(.zenMono)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }

    @ViewBuilder
    private func seedControlSection(
        title: String,
        seedColor: Binding<ZenPreviewSeedColor>
    ) -> some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text(title)
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextPrimary)

            HStack(spacing: ZenSpacing.medium) {
                ColorPicker("Light", selection: seedColor.light)
                Text(seedColor.wrappedValue.dynamicColor.light.hexString)
                    .font(.zenMono)
                    .foregroundStyle(Color.zenTextMuted)
            }

            HStack(spacing: ZenSpacing.medium) {
                ColorPicker("Dark", selection: seedColor.dark)
                Text(seedColor.wrappedValue.dynamicColor.dark.hexString)
                    .font(.zenMono)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }

    @ViewBuilder
    private func previewPanel(title: String, scheme: ColorScheme) -> some View {
        let primaryHex = scheme == .light ? primary.dynamicColor.light.hexString : primary.dynamicColor.dark.hexString
        let accentHex = scheme == .light ? accent.dynamicColor.light.hexString : accent.dynamicColor.dark.hexString

        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            HStack {
                Text(title)
                    .font(.zenTitle)
                    .foregroundStyle(Color.zenTextPrimary)

                Spacer()

                Text("Primary \(primaryHex) / Accent \(accentHex)")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }

            ZenCard(
                title: "Workspace",
                subtitle: "Review border, surfaces and semantic colors together"
            ) {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenInfoCard(title: "Surface", value: scheme == .light ? surface.dynamicColor.light.hexString : surface.dynamicColor.dark.hexString)
                    ZenInfoCard(title: "Border", value: scheme == .light ? border.dynamicColor.light.hexString : border.dynamicColor.dark.hexString)

                    HStack(spacing: ZenSpacing.small) {
                        ZenButton("Default") {}
                        ZenButton("Secondary", variant: .secondary) {}
                        ZenButton("Ghost", variant: .ghost) {}
                    }

                    ZenTextInput(
                        text: $sampleText,
                        prompt: "Accent hex",
                        leadingIconAsset: "MagnifyingGlass"
                    )

                    ZenNavigationRow(
                        title: "Refine base colors",
                        subtitle: "Cards, inputs and separators should stay coherent",
                        leadingIconAsset: "Swatches"
                    )
                }
            }
        }
        .padding(ZenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.zenBackground)
        .environment(\.colorScheme, scheme)
        .clipShape(RoundedRectangle(cornerRadius: ZenRadius.large, style: .continuous))
    }
}

#Preview("Theme Color Workbench") {
    ZenThemeColorWorkbenchPreview()
}
#endif
