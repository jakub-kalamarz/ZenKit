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
        ZenThemeColors(
            background: background,
            surface: surface,
            surfaceMuted: surfaceMuted,
            border: border,
            textPrimary: textPrimary,
            textMuted: textMuted,
            accent: accent,
            primary: accent,
            primaryPressed: .init(
                light: accent.light.mixed(with: .rgb(0, 0, 0), amount: 0.16),
                dark: accent.dark.mixed(with: .rgb(0, 0, 0), amount: 0.22)
            ),
            primarySubtle: .init(
                light: accent.light.mixed(with: .rgb(1, 1, 1), amount: 0.88),
                dark: accent.dark.mixed(with: .rgb(0, 0, 0), amount: 0.78)
            ),
            primaryForeground: .init(
                light: accent.light.accessibleForeground,
                dark: accent.dark.accessibleForeground
            ),
            focusRing: .init(
                light: accent.light.mixed(with: .rgb(1, 1, 1), amount: 0.22),
                dark: accent.dark.mixed(with: .rgb(1, 1, 1), amount: 0.12)
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
    static let defaultResolvedColors = ZenThemeColors(
        background: .init(light: lightBackground, dark: darkBackground),
        surface: .init(light: secondarySystemBackgroundLight, dark: secondarySystemBackgroundDark),
        surfaceMuted: .init(light: tertiarySystemBackgroundLight, dark: tertiarySystemBackgroundDark),
        border: .init(light: separatorLight, dark: separatorDark),
        textPrimary: .init(light: labelLight, dark: labelDark),
        textMuted: .init(light: secondaryLabelLight, dark: secondaryLabelDark),
        accent: .init(light: systemBlueLight, dark: systemBlueDark),
        primary: .init(light: systemBlueLight, dark: systemBlueDark),
        primaryPressed: .init(light: systemBlueLight.mixed(with: .rgb(0, 0, 0), amount: 0.16), dark: systemBlueDark.mixed(with: .rgb(0, 0, 0), amount: 0.22)),
        primarySubtle: .init(light: systemBlueLight.mixed(with: .rgb(1, 1, 1), amount: 0.88), dark: systemBlueDark.mixed(with: .rgb(0, 0, 0), amount: 0.78)),
        primaryForeground: .init(light: systemBlueLight.accessibleForeground, dark: systemBlueDark.accessibleForeground),
        focusRing: .init(light: systemBlueLight.mixed(with: .rgb(1, 1, 1), amount: 0.22), dark: systemBlueDark.mixed(with: .rgb(1, 1, 1), amount: 0.12)),
        success: .init(light: systemGreenLight, dark: systemGreenDark),
        successSubtle: .init(light: systemGreenLight.mixed(with: .rgb(1, 1, 1), amount: 0.88), dark: systemGreenDark.mixed(with: .rgb(0, 0, 0), amount: 0.78)),
        successBorder: .init(light: systemGreenLight.mixed(with: .rgb(1, 1, 1), amount: 0.58), dark: systemGreenDark.mixed(with: .rgb(0, 0, 0), amount: 0.5)),
        warning: .init(light: systemOrangeLight, dark: systemOrangeDark),
        warningSubtle: .init(light: systemOrangeLight.mixed(with: .rgb(1, 1, 1), amount: 0.88), dark: systemOrangeDark.mixed(with: .rgb(0, 0, 0), amount: 0.78)),
        warningBorder: .init(light: systemOrangeLight.mixed(with: .rgb(1, 1, 1), amount: 0.58), dark: systemOrangeDark.mixed(with: .rgb(0, 0, 0), amount: 0.5)),
        critical: .init(light: systemRedLight, dark: systemRedDark),
        criticalPressed: .init(light: systemRedLight.mixed(with: .rgb(0, 0, 0), amount: 0.16), dark: systemRedDark.mixed(with: .rgb(0, 0, 0), amount: 0.22)),
        criticalSubtle: .init(light: systemRedLight.mixed(with: .rgb(1, 1, 1), amount: 0.88), dark: systemRedDark.mixed(with: .rgb(0, 0, 0), amount: 0.78)),
        criticalBorder: .init(light: systemRedLight.mixed(with: .rgb(1, 1, 1), amount: 0.58), dark: systemRedDark.mixed(with: .rgb(0, 0, 0), amount: 0.5))
    )

#if canImport(UIKit)
    private static let lightBackground = resolved(.systemGroupedBackground, style: .light)
    private static let darkBackground = resolved(.systemGroupedBackground, style: .dark)
    private static let secondarySystemBackgroundLight = resolved(.systemBackground, style: .light)
    private static let secondarySystemBackgroundDark = resolved(.systemBackground, style: .dark)
    private static let tertiarySystemBackgroundLight = resolved(.tertiarySystemBackground, style: .light)
    private static let tertiarySystemBackgroundDark = resolved(.tertiarySystemBackground, style: .dark)
    private static let separatorLight = resolved(.systemGray5, style: .light)
    private static let separatorDark = resolved(.systemGray5, style: .dark)
    private static let labelLight = resolved(.label, style: .light)
    private static let labelDark = resolved(.label, style: .dark)
    private static let secondaryLabelLight = resolved(.secondaryLabel, style: .light)
    private static let secondaryLabelDark = resolved(.secondaryLabel, style: .dark)
    private static let systemBlueLight = resolved(.systemYellow, style: .light)
    private static let systemBlueDark = resolved(.systemYellow, style: .dark)
    private static let systemGreenLight = resolved(.systemGreen, style: .light)
    private static let systemGreenDark = resolved(.systemGreen, style: .dark)
    private static let systemOrangeLight = resolved(.systemOrange, style: .light)
    private static let systemOrangeDark = resolved(.systemOrange, style: .dark)
    private static let systemRedLight = resolved(.systemRed, style: .light)
    private static let systemRedDark = resolved(.systemRed, style: .dark)

    private static func resolved(_ color: UIColor, style: UIUserInterfaceStyle) -> ZenColorComponents {
        let traits = UITraitCollection(userInterfaceStyle: style)
        return ZenColorComponents(platformColor: color.resolvedColor(with: traits))
    }
#else
    private static let lightBackground = ZenColorComponents.rgb(1, 1, 1)
    private static let darkBackground = ZenColorComponents.rgb(0.0392, 0.0392, 0.0392)
    private static let secondarySystemBackgroundLight = ZenColorComponents.rgb(0.949, 0.949, 0.9686)
    private static let secondarySystemBackgroundDark = ZenColorComponents.rgb(0.1098, 0.1098, 0.1176)
    private static let tertiarySystemBackgroundLight = ZenColorComponents.rgb(1, 1, 1)
    private static let tertiarySystemBackgroundDark = ZenColorComponents.rgb(0.1725, 0.1725, 0.1804)
    private static let separatorLight = ZenColorComponents.rgb(0.2353, 0.2353, 0.2627)
    private static let separatorDark = ZenColorComponents.rgb(0.3294, 0.3294, 0.3451)
    private static let labelLight = ZenColorComponents.rgb(0, 0, 0)
    private static let labelDark = ZenColorComponents.rgb(1, 1, 1)
    private static let secondaryLabelLight = ZenColorComponents.rgb(0.2353, 0.2353, 0.2627)
    private static let secondaryLabelDark = ZenColorComponents.rgb(0.9216, 0.9216, 0.9608)
    private static let systemBlueLight = ZenColorComponents.rgb(0, 0.4784, 1)
    private static let systemBlueDark = ZenColorComponents.rgb(0.0392, 0.5176, 1)
    private static let systemGreenLight = ZenColorComponents.rgb(0.2039, 0.7804, 0.349)
    private static let systemGreenDark = ZenColorComponents.rgb(0.1882, 0.8196, 0.3451)
    private static let systemOrangeLight = ZenColorComponents.rgb(1, 0.5843, 0)
    private static let systemOrangeDark = ZenColorComponents.rgb(1, 0.6235, 0.0392)
    private static let systemRedLight = ZenColorComponents.rgb(1, 0.2314, 0.1882)
    private static let systemRedDark = ZenColorComponents.rgb(1, 0.2706, 0.2275)
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
                    .font(.zenLabel)
                    .foregroundStyle(Color.zenTextPrimary)
                Text(hex)
                    .font(.zenMono)
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
