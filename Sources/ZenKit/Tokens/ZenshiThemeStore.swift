import Foundation

#if canImport(UIKit)
import SwiftUI
import UIKit
#endif

enum ZenThemeStore {
    private static let lock = NSLock()
    private static var theme = initializeTheme()

    static func currentTheme() -> ZenTheme {
        lock.withLock { theme }
    }

    static func apply(_ theme: ZenTheme) {
        lock.withLock {
            self.theme = theme
            applyUIKitAppearance(theme)
        }
    }

    private static func initializeTheme() -> ZenTheme {
        let theme = ZenTheme.default
        applyUIKitAppearance(theme)
        return theme
    }

    private static func applyUIKitAppearance(_ theme: ZenTheme) {
#if canImport(UIKit)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.font: theme.resolvedTypography.fontSpec(for: .displayXS).uiFont]
        appearance.largeTitleTextAttributes = [.font: theme.resolvedTypography.fontSpec(for: .displayLG).uiFont]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.titleTextAttributes = appearance.titleTextAttributes
        navigationBar.largeTitleTextAttributes = appearance.largeTitleTextAttributes
#endif
    }
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}

#if canImport(UIKit)
private struct ZenThemeStorePreview: View {
    @State private var useCustomTheme = false

    private var previewTheme: ZenTheme {
        if useCustomTheme {
            return ZenTheme(
                colors: ZenThemeColors(
                    background: ZenNativeThemeTokens.defaultResolvedColors.background,
                    surface: ZenNativeThemeTokens.defaultResolvedColors.surface,
                    surfaceMuted: ZenNativeThemeTokens.defaultResolvedColors.surfaceMuted,
                    border: ZenNativeThemeTokens.defaultResolvedColors.border,
                    textPrimary: ZenNativeThemeTokens.defaultResolvedColors.textPrimary,
                    textMuted: ZenNativeThemeTokens.defaultResolvedColors.textMuted,
                    accent: .init(light: .rgb(0.0, 0.6235, 0.702), dark: .rgb(0.2784, 0.7765, 0.8314)),
                    primary: .init(light: .rgb(0.3216, 0.149, 0.9137), dark: .rgb(0.5529, 0.4118, 0.9882)),
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

        return .default
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            Toggle("Use custom theme", isOn: $useCustomTheme)
                .tint(Color.zenPrimary)

            ZenThemePreviewScope(theme: previewTheme) {
                ZenCard(title: "Theme Store", subtitle: "Applies through ZenTheme.current") {
                    HStack(spacing: ZenSpacing.small) {
                        ZenButton("Primary") {}
                        ZenButton("Link", variant: .link) {}
                    }
                }
            }
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview("Theme Store") {
    ZenThemeStorePreview()
}
#endif
