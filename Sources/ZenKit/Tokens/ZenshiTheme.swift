import SwiftUI

public enum ZenSemanticTone: CaseIterable, Sendable {
    case neutral
    case success
    case warning
    case critical
}

public enum ZenDensity: Sendable {
    case comfortable
    case compact
}

public enum ZenCornerStyle: Sendable {
    case none
    case rounded
    case pronounced
}

public enum ZenCornerRole: Sendable {
    case container
    case nestedContainer
    case control
    case nestedControl
}

public enum ZenMotion: Sendable {
    case standard
    case reduced
}

public enum ZenIconStyle: Sendable {
    case simple
    case gradient
    case single
}

public struct ZenTheme: Equatable, Sendable {
    public static var `default`: ZenTheme { ZenTheme() }

    public let density: ZenDensity
    public let cornerStyle: ZenCornerStyle
    public let motion: ZenMotion
    public let iconStyle: ZenIconStyle
    public let typography: ZenTypography
    public let accent: ZenDynamicColor?
    public let colors: ZenThemeColors?

    public init(
        density: ZenDensity = .comfortable,
        cornerStyle: ZenCornerStyle = .rounded,
        motion: ZenMotion = .standard,
        iconStyle: ZenIconStyle = .simple,
        typography: ZenTypography = .default,
        accent: ZenDynamicColor? = nil,
        colors: ZenThemeColors? = nil
    ) {
        self.density = density
        self.cornerStyle = cornerStyle
        self.motion = motion
        self.iconStyle = iconStyle
        self.typography = typography
        self.accent = accent
        self.colors = colors
    }

    public static var current: ZenTheme {
        ZenThemeStore.currentTheme()
    }

    public static func apply(_ theme: ZenTheme) {
        ZenThemeStore.apply(theme)
    }

    var resolvedColors: ZenResolvedColors {
        let base = colors ?? ZenNativeThemeTokens.defaultResolvedColors
        if let accent = accent {
            return base.applying(accent: accent)
        }
        return base
    }

    var resolvedMetrics: ZenResolvedMetrics {
        switch density {
        case .comfortable:
            return ZenResolvedMetrics(
                controlHeight: 44,
                controlHeightSmall: 36,
                controlHeightLarge: 52,
                cardPadding: ZenSpacing.medium,
                fieldVerticalPadding: 12
            )
        case .compact:
            return ZenResolvedMetrics(
                controlHeight: 40,
                controlHeightSmall: 32,
                controlHeightLarge: 48,
                cardPadding: 14,
                fieldVerticalPadding: 10
            )
        }
    }

    public var resolvedTypography: ZenResolvedTypography {
        makeResolvedTypography()
    }

    private func makeResolvedTypography() -> ZenResolvedTypography {
        ZenResolvedTypography(
            displayXL: makeResolvedFontSpec(role: .display, size: 30, weight: .semibold, leading: .tight),
            displayL: makeResolvedFontSpec(role: .display, size: 32, weight: .semibold, leading: .tight),
            displayM: makeResolvedFontSpec(role: .display, size: 22, weight: .semibold, leading: .tight),
            displayS: makeResolvedFontSpec(role: .display, size: 16, weight: .semibold),
            stat: makeResolvedFontSpec(role: .display, size: 18, weight: .semibold),
            body: makeResolvedFontSpec(role: .text, size: 16, weight: .medium),
            body2: makeResolvedFontSpec(role: .text, size: 13, weight: .medium),
            intro: makeResolvedFontSpec(role: .text, size: 15, weight: .regular),
            button: makeResolvedFontSpec(role: .text, size: 16, weight: .bold),
            tab: makeResolvedFontSpec(role: .text, size: 10, weight: .semibold),
            eyebrow: makeResolvedFontSpec(role: .text, size: 11, weight: .bold),
            group: makeResolvedFontSpec(role: .text, size: 12, weight: .semibold)
        )
    }

    private func makeResolvedFontSpec(
        role: ZenTypographyFamilyRole,
        size: CGFloat,
        weight: ZenFontWeight,
        leading: Font.Leading? = nil
    ) -> ZenResolvedFontSpec {
        let family = typography.family(for: role)
        let resolved = family.resolvedSource(for: weight)

        return ZenResolvedFontSpec(
            familyRole: role,
            source: family.source,
            resolvedSource: resolved.source,
            resolvedFontName: resolved.resolvedFontName,
            resolvedVariableAxes: resolved.resolvedVariableAxes,
            size: size,
            weight: weight,
            leading: leading
        )
    }

    public var resolvedCornerRadius: CGFloat {
        switch cornerStyle {
        case .none:
            return 0
        case .rounded:
            return ZenRadius.medium
        case .pronounced:
            return ZenRadius.large
        }
    }

    public func resolvedCornerRadius(for radius: CGFloat) -> CGFloat {
        guard cornerStyle != .none else {
            return 0
        }

        return radius
    }

    public func resolvedCornerRadius(for role: ZenCornerRole, parentRadius: CGFloat? = nil) -> CGFloat {
        guard cornerStyle != .none else {
            return 0
        }

        switch role {
        case .container:
            return resolvedCornerRadius
        case .nestedContainer:
            guard let parentRadius else {
                return resolvedCornerRadius
            }
            return resolvedNestedCornerRadius(inside: parentRadius, inset: 4)
        case .control:
            return resolvedCornerRadius(for: ZenRadius.small)
        case .nestedControl:
            guard let parentRadius else {
                return resolvedCornerRadius
            }
            return resolvedNestedCornerRadius(inside: parentRadius, inset: 4)
        }
    }

    public func resolvedNestedCornerRadius(inside parentRadius: CGFloat, inset: CGFloat) -> CGFloat {
        guard cornerStyle != .none else {
            return 0
        }

        let nestedRadius = max(0, parentRadius - inset)
        return min(parentRadius, nestedRadius)
    }

    public func resolvedFullyRoundedCornerRadius(for dimension: CGFloat) -> CGFloat {
        guard cornerStyle != .none else {
            return 0
        }

        return dimension / 2
    }
}

#Preview("Theme Core") {
    VStack(alignment: .leading, spacing: ZenSpacing.medium) {
        ZenCard(title: "Comfortable Rounded", subtitle: "Default theme axis sample") {
            Text("Control height \(Int(ZenTheme().resolvedMetrics.controlHeight))")
                .font(.zenIntro)
                .foregroundStyle(Color.zenTextPrimary)
        }

        ZenCard(title: "Compact None", subtitle: "Density and corner style") {
            Text("Control height \(Int(ZenTheme(density: .compact, cornerStyle: .none).resolvedMetrics.controlHeight))")
                .font(.zenIntro)
                .foregroundStyle(Color.zenTextPrimary)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
