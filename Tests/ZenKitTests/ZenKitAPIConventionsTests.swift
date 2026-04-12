import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitAPIConventionsTests {
    @Test
    func publicReusableSourceStopsExportingLegacyZenshiPrefixedTypes() throws {
        let sourceRoot = try zenKitSourceRoot()
        let publicDeclarations = try sourceFiles(in: sourceRoot)
            .flatMap { fileURL -> [String] in
                let source = try String(contentsOf: fileURL)
                    .split(separator: "\n")
                    .map(String.init)
                return source.filter { line in
                    line.hasPrefix("public struct Zenshi")
                        || line.hasPrefix("public enum Zenshi")
                        || line.hasPrefix("public protocol Zenshi")
                        || line.hasPrefix("public final class Zenshi")
                        || line.hasPrefix("public typealias Zenshi")
                        || line.hasPrefix("public let Zenshi")
                }
            }

        #expect(publicDeclarations.isEmpty, "Found legacy public declarations: \(publicDeclarations.joined(separator: ", "))")
    }

    @Test
    func packageSourceStopsOwningAppSpecificConcepts() throws {
        let sourceRoot = try zenKitSourceRoot()
        let forbiddenTokens = [
            "showsBrandMark",
            "ZenBrandMark",
            "ZenNavigationContextRoute",
            "zenNavigationDestination",
            "public enum Auth {",
            "public enum Account {",
            "public enum MainScreen {",
            "public enum ToastShowcase {",
            "public enum ZenKitCatalog {",
            "showsBrandMark",
        ]

        let matches = try sourceFiles(in: sourceRoot).flatMap { fileURL -> [String] in
            let source = try String(contentsOf: fileURL)
            return forbiddenTokens.compactMap { token in
                source.contains(token) ? "\(fileURL.lastPathComponent):\(token)" : nil
            }
        }

        #expect(matches.isEmpty, "Found app-specific source tokens: \(matches.joined(separator: ", "))")
    }

    @Test
    func statusComponentsExposeSemanticToneCases() {
        let tones: [ZenSemanticTone] = [.neutral, .success, .warning, .critical]

        #expect(tones.count == 4)
    }

    @Test
    func cornerStylesExposeNoRadiusMode() {
        let styles: [ZenCornerStyle] = [.none, .rounded, .pronounced]

        #expect(styles.count == 3)
    }

    @Test
    func themeExposesConfigurableStylingAxes() {
        ZenFontRegistry.clear()
        let theme = ZenTheme()

        #expect(theme.density == .comfortable)
        #expect(theme.cornerStyle == .rounded)
        #expect(theme.motion == .standard)
        #expect(theme.colors == nil)
        #expect(theme.typography.display.source == .system(.default))
        #expect(theme.typography.text.source == .system(.default))
    }

    @Test
    func themeExposesDirectConcreteColorOverrides() {
        let colors = ZenThemeColors(
            background: .init(light: .rgb(1, 1, 1), dark: .rgb(0.05, 0.05, 0.07)),
            surface: .init(light: .rgb(0.97, 0.97, 0.99), dark: .rgb(0.09, 0.09, 0.11)),
            surfaceMuted: .init(light: .rgb(0.94, 0.95, 0.98), dark: .rgb(0.12, 0.12, 0.14)),
            border: .init(light: .rgb(0.8, 0.82, 0.88), dark: .rgb(0.25, 0.28, 0.34)),
            textPrimary: .init(light: .rgb(0.06, 0.07, 0.09), dark: .rgb(0.96, 0.97, 0.99)),
            textMuted: .init(light: .rgb(0.38, 0.41, 0.47), dark: .rgb(0.66, 0.69, 0.76)),
            accent: .init(light: .rgb(0.0549, 0.6471, 0.9137), dark: .rgb(0.2196, 0.7412, 0.9961)),
            primary: .init(light: .rgb(0.1451, 0.3882, 0.9216), dark: .rgb(0.3765, 0.6471, 0.9804)),
            primaryPressed: .init(light: .rgb(0.1, 0.31, 0.78), dark: .rgb(0.28, 0.51, 0.83)),
            primarySubtle: .init(light: .rgb(0.9, 0.94, 1), dark: .rgb(0.12, 0.18, 0.28)),
            primaryForeground: .init(light: .rgb(1, 1, 1), dark: .rgb(0, 0, 0)),
            focusRing: .init(light: .rgb(0.4, 0.6, 1), dark: .rgb(0.5, 0.7, 1)),
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
        let theme = ZenTheme(colors: colors)

        #expect(theme.colors == colors)
    }

    @Test
    func nativeThemeTokensUseExpectedFallbackValuesAndAccentMixing() {
        let colors = ZenNativeThemeTokens.defaultResolvedColors
        let accent = ZenDynamicColor(
            light: .rgb(0.10, 0.60, 0.90),
            dark: .rgb(0.20, 0.70, 0.95)
        )
        let applied = colors.applying(accent: accent)

        #if canImport(UIKit)
        #expect(colors.surface.light == ZenColorComponents(platformColor: UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))))
        #expect(colors.surface.dark == ZenColorComponents(platformColor: UIColor.secondarySystemGroupedBackground.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))))
        #expect(colors.accent.light == ZenColorComponents(platformColor: UIColor.systemBlue.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))))
        #expect(colors.accent.dark == ZenColorComponents(platformColor: UIColor.systemBlue.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))))
        #expect(colors.surfaceMuted.light != colors.background.light)
        #expect(colors.surfaceMuted.dark != colors.background.dark)
        #else
        #expect(colors.surfaceMuted.light == .rgb(0.93, 0.93, 0.94))
        #expect(colors.surfaceMuted.dark == .rgb(0.180, 0.180, 0.192))
        #expect(colors.border.light == .rgb(0.898, 0.898, 0.918))
        #expect(colors.border.dark == .rgb(0.227, 0.227, 0.243))
        #expect(colors.textMuted.light == .rgb(0.541, 0.541, 0.557))
        #expect(colors.textMuted.dark == .rgb(0.597, 0.597, 0.624))
        #endif

        #expect(applied.primaryPressed.light == accent.light.mixed(with: .rgb(0, 0, 0), amount: 0.16))
        #expect(applied.primaryPressed.dark == accent.dark.mixed(with: .rgb(0, 0, 0), amount: 0.22))
        #expect(applied.primarySubtle.light == accent.light.mixed(with: .rgb(1, 1, 1), amount: 0.88))
        #expect(applied.primarySubtle.dark == accent.dark.mixed(with: .rgb(0, 0, 0), amount: 0.70))
        #expect(applied.focusRing.light == accent.light.mixed(with: .rgb(1, 1, 1), amount: 0.22))
        #expect(applied.focusRing.dark == accent.dark.mixed(with: .rgb(1, 1, 1), amount: 0.12))
    }

    @Test
    func themeSourceDefinesSingleBuiltInStyle() throws {
        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ZenKit/Tokens/ZenshiTheme.swift")
        let source = try String(contentsOf: sourceURL)

        #expect(!source.contains("public enum ZenNeutralFamily"))
        #expect(!source.contains("public enum ZenSemanticPalettePreset"))
        #expect(!source.contains("public enum ZenThemePreset"))
        #expect(!source.contains("struct ZenNeutralTokens"))
    }

    @Test
    func typographyFamilyRolesExposeDisplayAndTextCases() {
        let roles: [ZenTypographyFamilyRole] = [.display, .text]

        #expect(roles.count == 2)
    }

    @Test
    func typographySupportsSystemAndCustomFontSources() {
        let system = ZenFontSource.system(.rounded)
        let family = ZenFontFamily(regular: "InstrumentSerif-Regular")
        let custom = ZenFontSource.custom(family)

        #expect(system == .system(.rounded))
        #expect(custom == .custom(family))
    }

    @Test
    func emptyMediaVariantsStayFocusedOnMediaPresentation() {
        let variants: [ZenEmptyMediaVariant] = [.default, .icon]

        #expect(variants.count == 2)
    }

    @Test
    func badgeSupportsLegacyAndInteractiveInitializers() {
        let staticBadge = ZenBadge("Stable", tone: .success)
        let selectableBadge = ZenBadge("Filter", isSelected: true) {}
        let removableBadge = ZenBadge("Token", onRemove: {})
        let fullBadge = ZenBadge("Pinned", tone: .warning, isSelected: true, action: {}, onRemove: {})

        let view = VStack {
            staticBadge
            selectableBadge
            removableBadge
            fullBadge
        }

        _ = view
    }

    @Test
    func multiSelectPrimitiveExposesComposableBuilderAPI() {
        enum Filter: String, CaseIterable, Hashable, Sendable {
            case today = "Today"
            case overdue = "Overdue"
        }

        let view = ZenMultiSelect(
            title: "Filters",
            selection: .constant([.today]),
            options: Filter.allCases,
            mode: .immediate
        ) { option in
            Text(option.rawValue)
        } summaryLabel: { selected in
            Text("\(selected.count) selected")
        }

        _ = view
    }

    @Test
    func multiSelectSummaryUsesOptionOrderAndOverflowCount() {
        enum Column: String, CaseIterable, Hashable, Sendable {
            case name = "Name"
            case owner = "Owner"
            case status = "Status"
            case updated = "Updated"
        }

        let summary = ZenMultiSelectSummary.make(
            options: Column.allCases,
            selection: [.updated, .name, .status],
            optionTitle: \.rawValue
        )

        #expect(summary.labels == ["Name", "Status"])
        #expect(summary.overflowCount == 1)
        #expect(summary.displayText == "Name, Status +1")
    }

    @Test
    func selectCardPrimitiveExposesPresetInitializerAPI() {
        let simple = ZenSelectCard(title: "Plus", isSelected: false) {}
        let detailed = ZenSelectCard(
            title: "Visa ending in 4242",
            subtitle: "Expires 12/26",
            leadingIconSource: .asset("CreditCard"),
            iconColor: .blue,
            isSelected: true
        ) {}
        let inline = ZenSelectCard(
            title: "Add new payment method",
            leadingIconSource: .asset("Plus"),
            variant: .inline,
            isSelected: false
        ) {}

        let view = VStack {
            simple
            detailed
            inline
        }

        _ = view
    }

    @Test
    func sectionPrimitivesExposeComposableBuilderAPI() {
        let view = ZenSection {
            Text("Row")
        } header: {
            ZenSectionHeader {
                Text("Title")
            } subtitle: {
                Text("Subtitle")
            }
        } footer: {
            ZenSectionFooter {
                Text("Footnote")
            }
        }

        _ = view
    }
}

private func zenKitSourceRoot(filePath: StaticString = #filePath) throws -> URL {
    URL(fileURLWithPath: "\(filePath)")
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/ZenKit")
}

private func sourceFiles(in root: URL) throws -> [URL] {
    try FileManager.default
        .contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
        .flatMap { url -> [URL] in
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
            if isDirectory.boolValue {
                return try sourceFiles(in: url)
            }

            return url.pathExtension == "swift" ? [url] : []
        }
        .sorted { $0.path < $1.path }
}
