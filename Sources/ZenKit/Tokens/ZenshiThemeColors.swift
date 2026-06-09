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
    public let surfaceElevated: ZenDynamicColor
    public let surfaceTint: ZenDynamicColor
    public let border: ZenDynamicColor
    public let borderSubtle: ZenDynamicColor
    public let textPrimary: ZenDynamicColor
    public let textStrong: ZenDynamicColor
    public let textMuted: ZenDynamicColor
    public let textPlaceholder: ZenDynamicColor
    public let accent: ZenDynamicColor
    public let primary: ZenDynamicColor
    public let primaryPressed: ZenDynamicColor
    public let primarySubtle: ZenDynamicColor
    public let primaryForeground: ZenDynamicColor
    public let focusRing: ZenDynamicColor
    public let success: ZenDynamicColor
    public let successSubtle: ZenDynamicColor
    public let successBorder: ZenDynamicColor
    public let successTint: ZenDynamicColor
    public let warning: ZenDynamicColor
    public let warningSubtle: ZenDynamicColor
    public let warningBorder: ZenDynamicColor
    public let warningTint: ZenDynamicColor
    public let critical: ZenDynamicColor
    public let criticalPressed: ZenDynamicColor
    public let criticalSubtle: ZenDynamicColor
    public let criticalBorder: ZenDynamicColor
    public let criticalTint: ZenDynamicColor
    public let infoTint: ZenDynamicColor

    public init(
        background: ZenDynamicColor,
        surface: ZenDynamicColor,
        surfaceMuted: ZenDynamicColor,
        surfaceElevated: ZenDynamicColor? = nil,
        surfaceTint: ZenDynamicColor? = nil,
        border: ZenDynamicColor,
        borderSubtle: ZenDynamicColor? = nil,
        textPrimary: ZenDynamicColor,
        textStrong: ZenDynamicColor? = nil,
        textMuted: ZenDynamicColor,
        textPlaceholder: ZenDynamicColor? = nil,
        accent: ZenDynamicColor,
        primary: ZenDynamicColor,
        primaryPressed: ZenDynamicColor,
        primarySubtle: ZenDynamicColor,
        primaryForeground: ZenDynamicColor,
        focusRing: ZenDynamicColor,
        success: ZenDynamicColor,
        successSubtle: ZenDynamicColor,
        successBorder: ZenDynamicColor,
        successTint: ZenDynamicColor? = nil,
        warning: ZenDynamicColor,
        warningSubtle: ZenDynamicColor,
        warningBorder: ZenDynamicColor,
        warningTint: ZenDynamicColor? = nil,
        critical: ZenDynamicColor,
        criticalPressed: ZenDynamicColor,
        criticalSubtle: ZenDynamicColor,
        criticalBorder: ZenDynamicColor,
        criticalTint: ZenDynamicColor? = nil,
        infoTint: ZenDynamicColor? = nil
    ) {
        self.background = background
        self.surface = surface
        self.surfaceMuted = surfaceMuted
        self.surfaceElevated = surfaceElevated ?? surface
        self.surfaceTint = surfaceTint ?? surfaceMuted
        self.border = border
        self.borderSubtle = borderSubtle ?? border
        self.textPrimary = textPrimary
        self.textStrong = textStrong ?? textPrimary
        self.textMuted = textMuted
        self.textPlaceholder = textPlaceholder ?? textMuted
        self.accent = accent
        self.primary = primary
        self.primaryPressed = primaryPressed
        self.primarySubtle = primarySubtle
        self.primaryForeground = primaryForeground
        self.focusRing = focusRing
        self.success = success
        self.successSubtle = successSubtle
        self.successBorder = successBorder
        self.successTint = successTint ?? successSubtle
        self.warning = warning
        self.warningSubtle = warningSubtle
        self.warningBorder = warningBorder
        self.warningTint = warningTint ?? warningSubtle
        self.critical = critical
        self.criticalPressed = criticalPressed
        self.criticalSubtle = criticalSubtle
        self.criticalBorder = criticalBorder
        self.criticalTint = criticalTint ?? criticalSubtle
        self.infoTint = infoTint ?? primarySubtle
    }

    public func applying(accent: ZenDynamicColor) -> ZenThemeColors {
        let white = ZenColorComponents.rgb(1, 1, 1)
        let black = ZenColorComponents.rgb(0, 0, 0)

        let newPrimarySubtle = ZenDynamicColor(
            light: accent.light.mixed(with: white, amount: ZenColorMixing.subtleLight),
            dark: accent.dark.mixed(with: black, amount: ZenColorMixing.subtleDark)
        )

        return ZenThemeColors(
            background: background,
            surface: surface,
            surfaceMuted: surfaceMuted,
            surfaceElevated: surfaceElevated,
            surfaceTint: surfaceTint,
            border: border,
            borderSubtle: borderSubtle,
            textPrimary: textPrimary,
            textStrong: textStrong,
            textMuted: textMuted,
            textPlaceholder: textPlaceholder,
            accent: accent,
            primary: accent,
            primaryPressed: .init(
                light: accent.light.mixed(with: black, amount: ZenColorMixing.pressedLight),
                dark: accent.dark.mixed(with: black, amount: ZenColorMixing.pressedDark)
            ),
            primarySubtle: newPrimarySubtle,
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
            successTint: successTint,
            warning: warning,
            warningSubtle: warningSubtle,
            warningBorder: warningBorder,
            warningTint: warningTint,
            critical: critical,
            criticalPressed: criticalPressed,
            criticalSubtle: criticalSubtle,
            criticalBorder: criticalBorder,
            criticalTint: criticalTint,
            infoTint: newPrimarySubtle
        )
    }
}

typealias ZenResolvedColors = ZenThemeColors

enum ZenColorMixing {
    static let pressedLight: Double = 0.16
    static let pressedDark: Double = 0.22
    static let subtleLight: Double = 0.90
    static let subtleDark: Double = 0.70
    static let borderLight: Double = 0.58
    static let borderDark: Double = 0.50
    static let focusLight: Double = 0.22
    static let focusDark: Double = 0.12
    static let tintLight: Double = 0.93
    static let tintDark: Double = 0.80
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

        let primaryPressedColor = ZenDynamicColor(
            light: accentLight.mixed(with: black, amount: ZenColorMixing.pressedLight),
            dark: accentDark.mixed(with: black, amount: ZenColorMixing.pressedDark)
        )
        let primarySubtleColor = ZenDynamicColor(
            light: accentLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
            dark: accentDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
        )
        let primaryFgColor = ZenDynamicColor(
            light: accentLight.accessibleForeground,
            dark: accentDark.accessibleForeground
        )
        let focusRingColor = ZenDynamicColor(
            light: accentLight.mixed(with: white, amount: ZenColorMixing.focusLight),
            dark: accentDark.mixed(with: white, amount: ZenColorMixing.focusDark)
        )
        let infoTintColor = ZenDynamicColor(
            light: accentLight.mixed(with: white, amount: ZenColorMixing.tintLight),
            dark: accentDark.mixed(with: black, amount: ZenColorMixing.tintDark)
        )

        let successColor = ZenDynamicColor(light: greenLight, dark: greenDark)
        let successSubtleColor = ZenDynamicColor(
            light: greenLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
            dark: greenDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
        )
        let successBorderColor = ZenDynamicColor(
            light: greenLight.mixed(with: white, amount: ZenColorMixing.borderLight),
            dark: greenDark.mixed(with: black, amount: ZenColorMixing.borderDark)
        )
        let successTintColor = ZenDynamicColor(
            light: greenLight.mixed(with: white, amount: ZenColorMixing.tintLight),
            dark: greenDark.mixed(with: black, amount: ZenColorMixing.tintDark)
        )

        let warningColor = ZenDynamicColor(light: amberLight, dark: amberDark)
        let warningSubtleColor = ZenDynamicColor(
            light: amberLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
            dark: amberDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
        )
        let warningBorderColor = ZenDynamicColor(
            light: amberLight.mixed(with: white, amount: ZenColorMixing.borderLight),
            dark: amberDark.mixed(with: black, amount: ZenColorMixing.borderDark)
        )
        let warningTintColor = ZenDynamicColor(
            light: amberLight.mixed(with: white, amount: ZenColorMixing.tintLight),
            dark: amberDark.mixed(with: black, amount: ZenColorMixing.tintDark)
        )

        let criticalColor = ZenDynamicColor(light: redLight, dark: redDark)
        let criticalPressedColor = ZenDynamicColor(
            light: redLight.mixed(with: black, amount: ZenColorMixing.pressedLight),
            dark: redDark.mixed(with: black, amount: ZenColorMixing.pressedDark)
        )
        let criticalSubtleColor = ZenDynamicColor(
            light: redLight.mixed(with: white, amount: ZenColorMixing.subtleLight),
            dark: redDark.mixed(with: black, amount: ZenColorMixing.subtleDark)
        )
        let criticalBorderColor = ZenDynamicColor(
            light: redLight.mixed(with: white, amount: ZenColorMixing.borderLight),
            dark: redDark.mixed(with: black, amount: ZenColorMixing.borderDark)
        )
        let criticalTintColor = ZenDynamicColor(
            light: redLight.mixed(with: white, amount: ZenColorMixing.tintLight),
            dark: redDark.mixed(with: black, amount: ZenColorMixing.tintDark)
        )

        return ZenThemeColors(
            background: ZenDynamicColor(light: backgroundLight, dark: backgroundDark),
            surface: ZenDynamicColor(light: surfaceLight, dark: surfaceDark),
            surfaceMuted: ZenDynamicColor(light: surfaceMutedLight, dark: surfaceMutedDark),
            surfaceElevated: ZenDynamicColor(light: surfaceElevatedLight, dark: surfaceElevatedDark),
            surfaceTint: ZenDynamicColor(light: surfaceTintLight, dark: surfaceTintDark),
            border: ZenDynamicColor(light: borderLight, dark: borderDark),
            borderSubtle: ZenDynamicColor(light: borderSubtleLight, dark: borderSubtleDark),
            textPrimary: ZenDynamicColor(light: labelLight, dark: labelDark),
            textStrong: ZenDynamicColor(light: labelStrongLight, dark: labelStrongDark),
            textMuted: ZenDynamicColor(light: mutedLabelLight, dark: mutedLabelDark),
            textPlaceholder: ZenDynamicColor(light: placeholderLight, dark: placeholderDark),
            accent: ZenDynamicColor(light: accentLight, dark: accentDark),
            primary: ZenDynamicColor(light: accentLight, dark: accentDark),
            primaryPressed: primaryPressedColor,
            primarySubtle: primarySubtleColor,
            primaryForeground: primaryFgColor,
            focusRing: focusRingColor,
            success: successColor,
            successSubtle: successSubtleColor,
            successBorder: successBorderColor,
            successTint: successTintColor,
            warning: warningColor,
            warningSubtle: warningSubtleColor,
            warningBorder: warningBorderColor,
            warningTint: warningTintColor,
            critical: criticalColor,
            criticalPressed: criticalPressedColor,
            criticalSubtle: criticalSubtleColor,
            criticalBorder: criticalBorderColor,
            criticalTint: criticalTintColor,
            infoTint: infoTintColor
        )
    }()

    // Kumo-derived neutral palette
    private static let backgroundLight = ZenColorComponents(hex: "FBFBFC")!
    private static let backgroundDark = ZenColorComponents(hex: "1A1A1A")!
    private static let surfaceLight = ZenColorComponents.rgb(1, 1, 1)
    private static let surfaceDark = ZenColorComponents(hex: "262626")!
    private static let surfaceMutedLight = ZenColorComponents(hex: "F5F5F5")!
    private static let surfaceMutedDark = ZenColorComponents(hex: "1F1F1F")!
    private static let surfaceElevatedLight = ZenColorComponents(hex: "FAFAFA")!
    private static let surfaceElevatedDark = ZenColorComponents(hex: "2A2A2A")!
    private static let surfaceTintLight = ZenColorComponents(hex: "F7F7F7")!
    private static let surfaceTintDark = ZenColorComponents(hex: "333333")!
    private static let borderLight = ZenColorComponents(hex: "E0E0E0")!
    private static let borderDark = ZenColorComponents(hex: "404040")!
    private static let borderSubtleLight = ZenColorComponents(hex: "EBEBEB")!
    private static let borderSubtleDark = ZenColorComponents(hex: "333333")!
    private static let labelLight = ZenColorComponents(hex: "1A1A1A")!
    private static let labelDark = ZenColorComponents(hex: "F5F5F5")!
    private static let labelStrongLight = ZenColorComponents(hex: "0F0F0F")!
    private static let labelStrongDark = ZenColorComponents(hex: "FAFAFA")!
    private static let mutedLabelLight = ZenColorComponents(hex: "737373")!
    private static let mutedLabelDark = ZenColorComponents(hex: "A0A0A0")!
    private static let placeholderLight = ZenColorComponents(hex: "A0A0A0")!
    private static let placeholderDark = ZenColorComponents(hex: "666666")!

    // Kumo brand blue
    private static let accentLight = ZenColorComponents(hex: "3B82F6")!
    private static let accentDark = ZenColorComponents(hex: "3B82F6")!

    // Kumo semantic colors
    private static let greenLight = ZenColorComponents(hex: "10B981")!
    private static let greenDark = ZenColorComponents(hex: "34D399")!
    private static let amberLight = ZenColorComponents(hex: "F59E0B")!
    private static let amberDark = ZenColorComponents(hex: "FBBF24")!
    private static let redLight = ZenColorComponents(hex: "EF4444")!
    private static let redDark = ZenColorComponents(hex: "F87171")!

#if canImport(UIKit)
    // Keep UIKit helpers for custom theme consumers
    static func resolved(_ color: UIColor, style: UIUserInterfaceStyle) -> ZenColorComponents {
        let traits = UITraitCollection(userInterfaceStyle: style)
        return ZenColorComponents(platformColor: color.resolvedColor(with: traits))
    }
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
