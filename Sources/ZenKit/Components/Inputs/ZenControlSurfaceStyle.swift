import SwiftUI

struct ZenControlSurfaceStyle {
    let backgroundToken: ZenDynamicColor
    let borderToken: ZenDynamicColor
    let borderWidth: CGFloat

    var backgroundColor: Color { backgroundToken.color }
    var borderColor: Color { borderToken.color }

    static func outline(theme: ZenTheme = .current) -> ZenControlSurfaceStyle {
        let colors = theme.resolvedColors

        return ZenControlSurfaceStyle(
            backgroundToken: colors.surface,
            borderToken: colors.border,
            borderWidth: 1
        )
    }

    static func field(theme: ZenTheme = .current) -> ZenControlSurfaceStyle {
        let colors = theme.resolvedColors

        return ZenControlSurfaceStyle(
            backgroundToken: colors.surface,
            borderToken: colors.border,
            borderWidth: 1
        )
    }
}
