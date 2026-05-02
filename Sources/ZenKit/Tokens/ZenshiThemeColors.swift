import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

private extension Color {
    init(light: Color, dark: Color) {
#if canImport(UIKit)
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
#else
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        })
#endif
    }
}

public struct ZenDynamicColor: Equatable, Sendable {
    public let light: ZenColorComponents
    public let dark: ZenColorComponents

    public init(light: ZenColorComponents, dark: ZenColorComponents) {
        self.light = light
        self.dark = dark
    }

    public init?(hex: String) {
        guard let components = ZenColorComponents(hex: hex) else { return nil }
        self.init(light: components, dark: components)
    }

    public init?(lightHex: String, darkHex: String) {
        guard let light = ZenColorComponents(hex: lightHex),
              let dark = ZenColorComponents(hex: darkHex) else { return nil }
        self.init(light: light, dark: dark)
    }

    var color: Color {
        Color(light: light.color, dark: dark.color)
    }
}

public struct ZenThemeColors: Equatable, Sendable {
    public let background: ZenDynamicColor
    public let surface: ZenDynamicColor
    public let surfaceMuted: ZenDynamicColor
    public let border: ZenDynamicColor
    public let textPrimary: ZenDynamicColor
    public let textMuted: ZenDynamicColor
    public let accent: ZenDynamicColor
    public let primary: ZenDynamicColor
    public let primaryPressed: ZenDynamicColor
    public let primarySubtle: ZenDynamicColor
    public let primaryForeground: ZenDynamicColor
    public let focusRing: ZenDynamicColor
    public let success: ZenDynamicColor
    public let successSubtle: ZenDynamicColor
    public let successBorder: ZenDynamicColor
    public let warning: ZenDynamicColor
    public let warningSubtle: ZenDynamicColor
    public let warningBorder: ZenDynamicColor
    public let critical: ZenDynamicColor
    public let criticalPressed: ZenDynamicColor
    public let criticalSubtle: ZenDynamicColor
    public let criticalBorder: ZenDynamicColor

    public init(
        background: ZenDynamicColor,
        surface: ZenDynamicColor,
        surfaceMuted: ZenDynamicColor,
        border: ZenDynamicColor,
        textPrimary: ZenDynamicColor,
        textMuted: ZenDynamicColor,
        accent: ZenDynamicColor,
        primary: ZenDynamicColor,
        primaryPressed: ZenDynamicColor,
        primarySubtle: ZenDynamicColor,
        primaryForeground: ZenDynamicColor,
        focusRing: ZenDynamicColor,
        success: ZenDynamicColor,
        successSubtle: ZenDynamicColor,
        successBorder: ZenDynamicColor,
        warning: ZenDynamicColor,
        warningSubtle: ZenDynamicColor,
        warningBorder: ZenDynamicColor,
        critical: ZenDynamicColor,
        criticalPressed: ZenDynamicColor,
        criticalSubtle: ZenDynamicColor,
        criticalBorder: ZenDynamicColor
    ) {
        self.background = background
        self.surface = surface
        self.surfaceMuted = surfaceMuted
        self.border = border
        self.textPrimary = textPrimary
        self.textMuted = textMuted
        self.accent = accent
        self.primary = primary
        self.primaryPressed = primaryPressed
        self.primarySubtle = primarySubtle
        self.primaryForeground = primaryForeground
        self.focusRing = focusRing
        self.success = success
        self.successSubtle = successSubtle
        self.successBorder = successBorder
        self.warning = warning
        self.warningSubtle = warningSubtle
        self.warningBorder = warningBorder
        self.critical = critical
        self.criticalPressed = criticalPressed
        self.criticalSubtle = criticalSubtle
        self.criticalBorder = criticalBorder
    }

    public func applying(accent: ZenDynamicColor) -> ZenThemeColors {
        let white = ZenColorComponents.rgb(1, 1, 1)
        let black = ZenColorComponents.rgb(0, 0, 0)

        return ZenThemeColors(
            background: background,
            surface: surface,
            surfaceMuted: surfaceMuted,
            border: border,
            textPrimary: textPrimary,
            textMuted: textMuted,
            accent: accent,
            primary: accent,
            primaryPressed: .init(
                light: accent.light.mixed(with: black, amount: ZenColorMixing.pressedLight),
                dark: accent.dark.mixed(with: black, amount: ZenColorMixing.pressedDark)
            ),
            primarySubtle: .init(
                light: accent.light.mixed(with: white, amount: ZenColorMixing.subtleLight),
                dark: accent.dark.mixed(with: black, amount: ZenColorMixing.subtleDark)
            ),
            primaryForeground: .init(
                light: accent.light.accessibleForeground,
                dark: accent.dark.accessibleForeground
            ),
            focusRing: .init(
                light: accent.light.mixed(with: white, amount: ZenColorMixing.focusLight),
                dark: accent.dark.mixed(with: white, amount: ZenColorMixing.focusDark)
            ),
            success: success,
            successSubtle: successSubtle,
            successBorder: successBorder,
            warning: warning,
            warningSubtle: warningSubtle,
            warningBorder: warningBorder,
            critical: critical,
            criticalPressed: criticalPressed,
            criticalSubtle: criticalSubtle,
            criticalBorder: criticalBorder
        )
    }
}

typealias ZenResolvedColors = ZenThemeColors

enum ZenColorMixing {
    static let pressedLight: Double = 0.16
    static let pressedDark: Double = 0.22
    static let subtleLight: Double = 0.88
    static let subtleDark: Double = 0.70
    static let borderLight: Double = 0.58
    static let borderDark: Double = 0.50
    static let focusLight: Double = 0.22
    static let focusDark: Double = 0.12
}

public struct ZenColorComponents: Equatable, Hashable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public static func rgb(_ red: Double, _ green: Double, _ blue: Double) -> ZenColorComponents {
        ZenColorComponents(red: red, green: green, blue: blue)
    }

    public init?(hex: String) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard sanitized.count == 6, let value = Int(sanitized, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    public static func hex(_ hex: String) -> ZenColorComponents? {
        ZenColorComponents(hex: hex)
    }

#if canImport(UIKit)
    init(platformColor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.init(red: Double(red), green: Double(green), blue: Double(blue))
            return
        }

        guard let converted = platformColor.cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .defaultIntent,
            options: nil
        ),
        let components = converted.components else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }

        switch components.count {
        case 0:
            self.init(red: 0, green: 0, blue: 0)
        case 1:
            self.init(red: Double(components[0]), green: Double(components[0]), blue: Double(components[0]))
        default:
            self.init(
                red: Double(components[0]),
                green: Double(components[1]),
                blue: Double(components[min(2, components.count - 1)])
            )
        }
    }
#endif

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    var hexString: String {
        let red = Int((red * 255).rounded())
        let green = Int((green * 255).rounded())
        let blue = Int((blue * 255).rounded())

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

struct ZenNativeThemeTokens {
    static let defaultResolvedColors: ZenThemeColors = {
        let white = ZenColorComponents.rgb(1, 1, 1)
        let black = ZenColorComponents.rgb(0, 0, 0)

        return ZenThemeColors(
            background: .init(light: backgroundLight, dark: backgroundDark),
            surface: .init(light: surfaceLight, dark: surfaceDark),
            surfaceMuted: .init(light: surfaceMutedLight, dark: surfaceMutedDark),
            border: .init(light: borderLight, dark: borderDark),
            textPrimary: .init(light: labelLight, dark: labelDark),
            textMuted: .init(light: mutedLabelLight, dark: mutedLabelDark),
            accent: .init(light: accentLight, dark: accentDark),
            primary: .init(light: accentLight, dark: accentDark),
            primaryPressed: .init(
                light: accentLight.mixed(with: black, amount: ZenColorMixing.pressedLight),
                dark: accentDark.mixed(with: black, amount: ZenColorMixing.pressedDark)
            ),
            primarySubtle: .init(
                light: accentLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
                dark: accentDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
            ),
            primaryForeground: .init(
                light: accentLight.accessibleForeground,
                dark: accentDark.accessibleForeground
            ),
            focusRing: .init(
                light: accentLight.mixed(with: white, amount: ZenColorMixing.focusLight),
                dark: accentDark.mixed(with: white, amount: ZenColorMixing.focusDark)
            ),
            success: .init(light: greenLight, dark: greenDark),
            successSubtle: .init(
                light: greenLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
                dark: greenDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
            ),
            successBorder: .init(
                light: greenLight.mixed(with: white, amount: ZenColorMixing.borderLight),
                dark: greenDark.mixed(with: black, amount: ZenColorMixing.borderDark)
            ),
            warning: .init(light: orangeLight, dark: orangeDark),
            warningSubtle: .init(
                light: orangeLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
                dark: orangeDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
            ),
            warningBorder: .init(
                light: orangeLight.mixed(with: white, amount: ZenColorMixing.borderLight),
                dark: orangeDark.mixed(with: black, amount: ZenColorMixing.borderDark)
            ),
            critical: .init(light: redLight, dark: redDark),
            criticalPressed: .init(
                light: redLight.mixed(with: black, amount: ZenColorMixing.pressedLight),
                dark: redDark.mixed(with: black, amount: ZenColorMixing.pressedDark)
            ),
            criticalSubtle: .init(
                light: redLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
                dark: redDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
            ),
            criticalBorder: .init(
                light: redLight.mixed(with: white, amount: ZenColorMixing.borderLight),
                dark: redDark.mixed(with: black, amount: ZenColorMixing.borderDark)
            )
        )
    }()

#if canImport(UIKit)
    private static let backgroundLight = resolved(.systemGroupedBackground, style: .light)
    private static let backgroundDark = resolved(.systemGroupedBackground, style: .dark)
    private static let surfaceLight = resolved(.secondarySystemGroupedBackground, style: .light)
    private static let surfaceDark = resolved(.secondarySystemGroupedBackground, style: .dark)
    private static let surfaceMutedLight = ZenColorComponents.rgb(0.93, 0.93, 0.94)
    private static let surfaceMutedDark = ZenColorComponents.rgb(0.180, 0.180, 0.192)
    private static let borderLight = resolved(.systemGray5, style: .light)
    private static let borderDark = resolved(.systemGray5, style: .dark)
    private static let labelLight = resolved(.label, style: .light)
    private static let labelDark = resolved(.label, style: .dark)
    private static let mutedLabelLight = resolvedOpaque(.secondaryLabel, on: .secondarySystemGroupedBackground, style: .light)
    private static let mutedLabelDark = resolvedOpaque(.secondaryLabel, on: .secondarySystemGroupedBackground, style: .dark)
    private static let accentLight = resolved(.systemBlue, style: .light)
    private static let accentDark = resolved(.systemBlue, style: .dark)
    private static let greenLight = resolved(.systemGreen, style: .light)
    private static let greenDark = resolved(.systemGreen, style: .dark)
    private static let orangeLight = resolved(.systemOrange, style: .light)
    private static let orangeDark = resolved(.systemOrange, style: .dark)
    private static let redLight = resolved(.systemRed, style: .light)
    private static let redDark = resolved(.systemRed, style: .dark)

    private static func resolved(_ color: UIColor, style: UIUserInterfaceStyle) -> ZenColorComponents {
        let traits = UITraitCollection(userInterfaceStyle: style)
        return ZenColorComponents(platformColor: color.resolvedColor(with: traits))
    }

    private static func resolvedOpaque(
        _ color: UIColor,
        on background: UIColor,
        style: UIUserInterfaceStyle
    ) -> ZenColorComponents {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let foregroundColor = color.resolvedColor(with: traits)
        let backgroundColor = background.resolvedColor(with: traits)

        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0
        foregroundColor.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        guard fgA < 1 else {
            return ZenColorComponents(red: Double(fgR), green: Double(fgG), blue: Double(fgB))
        }

        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0
        backgroundColor.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)

        return ZenColorComponents(
            red: Double(fgR * fgA + bgR * (1 - fgA)),
            green: Double(fgG * fgA + bgG * (1 - fgA)),
            blue: Double(fgB * fgA + bgB * (1 - fgA))
        )
    }
#else
    private static let backgroundLight = ZenColorComponents.rgb(1, 1, 1)
    private static let backgroundDark = ZenColorComponents.rgb(0.118, 0.118, 0.118)
    private static let surfaceLight = ZenColorComponents.rgb(0.961, 0.961, 0.969)
    private static let surfaceDark = ZenColorComponents.rgb(0.165, 0.165, 0.173)
    private static let surfaceMutedLight = ZenColorComponents.rgb(0.93, 0.93, 0.94)
    private static let surfaceMutedDark = ZenColorComponents.rgb(0.180, 0.180, 0.192)
    private static let borderLight = ZenColorComponents.rgb(0.898, 0.898, 0.918)
    private static let borderDark = ZenColorComponents.rgb(0.227, 0.227, 0.243)
    private static let labelLight = ZenColorComponents.rgb(0, 0, 0)
    private static let labelDark = ZenColorComponents.rgb(1, 1, 1)
    private static let mutedLabelLight = ZenColorComponents.rgb(0.541, 0.541, 0.557)
    private static let mutedLabelDark = ZenColorComponents.rgb(0.597, 0.597, 0.624)
    private static let accentLight = ZenColorComponents.rgb(0, 0.478, 1)
    private static let accentDark = ZenColorComponents.rgb(0.039, 0.518, 1)
    private static let greenLight = ZenColorComponents.rgb(0.204, 0.780, 0.349)
    private static let greenDark = ZenColorComponents.rgb(0.188, 0.820, 0.345)
    private static let orangeLight = ZenColorComponents.rgb(1, 0.584, 0)
    private static let orangeDark = ZenColorComponents.rgb(1, 0.624, 0.039)
    private static let redLight = ZenColorComponents.rgb(1, 0.231, 0.188)
    private static let redDark = ZenColorComponents.rgb(1, 0.271, 0.227)
#endif
}

extension ZenColorComponents {
    func mixed(with other: ZenColorComponents, amount: Double) -> ZenColorComponents {
        let normalizedAmount = max(0, min(amount, 1))
        let inverseAmount = 1 - normalizedAmount

        return .rgb(
            (red * inverseAmount) + (other.red * normalizedAmount),
            (green * inverseAmount) + (other.green * normalizedAmount),
            (blue * inverseAmount) + (other.blue * normalizedAmount)
        )
    }

    var accessibleForeground: ZenColorComponents {
        let white = ZenColorComponents.rgb(1, 1, 1)
        let black = ZenColorComponents.rgb(0, 0, 0)

        return contrastRatio(with: white) >= contrastRatio(with: black) ? white : black
    }

    func contrastRatio(with other: ZenColorComponents) -> Double {
        let lighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    var relativeLuminance: Double {
        (0.2126 * red.linearized) + (0.7152 * green.linearized) + (0.0722 * blue.linearized)
    }
}

private extension Double {
    var linearized: Double {
        if self <= 0.04045 {
            return self / 12.92
        }

        return pow((self + 0.055) / 1.055, 2.4)
    }
}

private struct ZenThemeColorSwatch: View {
    let title: String
    let color: Color
    let hex: String

    var body: some View {
        HStack(spacing: ZenSpacing.small) {
            RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                        .stroke(Color.zenBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.zen(.body2, weight: .medium))
                    .foregroundStyle(Color.zenTextPrimary)
                Text(hex)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }
}

#Preview("Theme Colors") {
    let colors = ZenTheme.default.resolvedColors

    return VStack(alignment: .leading, spacing: ZenSpacing.medium) {
        ZenThemeColorSwatch(title: "Background", color: colors.background.color, hex: colors.background.light.hexString)
        ZenThemeColorSwatch(title: "Surface", color: colors.surface.color, hex: colors.surface.light.hexString)
        ZenThemeColorSwatch(title: "Surface Muted", color: colors.surfaceMuted.color, hex: colors.surfaceMuted.light.hexString)
        ZenThemeColorSwatch(title: "Border", color: colors.border.color, hex: colors.border.light.hexString)
        ZenThemeColorSwatch(title: "Primary", color: colors.primary.color, hex: colors.primary.light.hexString)
        ZenThemeColorSwatch(title: "Accent", color: colors.accent.color, hex: colors.accent.light.hexString)
    }
    .padding()
    .background(Color.zenBackground)
}
