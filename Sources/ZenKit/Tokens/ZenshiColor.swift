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

public extension Color {
    static var zenBackground: Color { ZenTheme.current.resolvedColors.background.color }
    static var zenSurface: Color { ZenTheme.current.resolvedColors.surface.color }
    static var zenSurfaceMuted: Color { ZenTheme.current.resolvedColors.surfaceMuted.color }
    static var zenBorder: Color { ZenTheme.current.resolvedColors.border.color }
    static var zenTextPrimary: Color { ZenTheme.current.resolvedColors.textPrimary.color }
    static var zenTextMuted: Color { ZenTheme.current.resolvedColors.textMuted.color }
    static var zenPrimary: Color { ZenTheme.current.resolvedColors.primary.color }
    static var zenAccent: Color { ZenTheme.current.resolvedColors.accent.color }
    static var zenPrimaryForeground: Color { ZenTheme.current.resolvedColors.primaryForeground.color }
    static var zenSuccess: Color { ZenTheme.current.resolvedColors.success.color }
    static var zenWarning: Color { ZenTheme.current.resolvedColors.warning.color }
    static var zenCritical: Color { ZenTheme.current.resolvedColors.critical.color }

    // Metric colors — matches web oklch values
    static var zenMetricClicks: Color {
        Color(light: Color(red: 0.0000, green: 0.5312, blue: 0.9710),
              dark:  Color(red: 0.0669, green: 0.6590, blue: 1.0000))
    }
    static var zenMetricImpressions: Color {
        Color(light: Color(red: 0.4797, green: 0.5310, blue: 0.5977),
              dark:  Color(red: 0.6337, green: 0.6874, blue: 0.7573))
    }
    static var zenMetricCtr: Color {
        Color(light: Color(red: 0.2164, green: 0.7319, blue: 0.3840),
              dark:  Color(red: 0.3394, green: 0.8347, blue: 0.4802))
    }
    static var zenMetricPosition: Color {
        Color(light: Color(red: 0.9842, green: 0.6297, blue: 0.0000),
              dark:  Color(red: 1.0000, green: 0.6804, blue: 0.1362))
    }
}
