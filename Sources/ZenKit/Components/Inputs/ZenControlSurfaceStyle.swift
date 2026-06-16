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
            borderToken: colors.borderSubtle,
            borderWidth: 1
        )
    }

    static func field(theme: ZenTheme = .current) -> ZenControlSurfaceStyle {
        let colors = theme.resolvedColors

        return ZenControlSurfaceStyle(
            backgroundToken: colors.surface,
            borderToken: colors.borderSubtle,
            borderWidth: 1
        )
    }

    static func searchField(theme: ZenTheme = .current) -> ZenControlSurfaceStyle {
        let colors = theme.resolvedColors

        return ZenControlSurfaceStyle(
            backgroundToken: colors.surfaceMuted,
            borderToken: colors.borderSubtle,
            borderWidth: 1
        )
    }
}

extension View {
    /// Subtle elevation shared by filled control surfaces (text fields, buttons,
    /// and selection controls) so they read as consistently raised. Apply after
    /// the surface's `clipShape`.
    func zenControlSurfaceShadow() -> some View {
        shadow(
            color: ZenShadow.xs.color,
            radius: ZenShadow.xs.radius,
            x: ZenShadow.xs.x,
            y: ZenShadow.xs.y
        )
    }
}

/// Applies `zenControlSurfaceShadow()` only when enabled, keeping a stable view
/// type so it can sit in a `ButtonStyle` body without breaking animations.
struct ZenConditionalControlShadow: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content.shadow(
            color: isEnabled ? ZenShadow.xs.color : .clear,
            radius: ZenShadow.xs.radius,
            x: ZenShadow.xs.x,
            y: ZenShadow.xs.y
        )
    }
}
