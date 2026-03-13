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

public enum ZenMotion: Sendable {
    case standard
    case reduced
}

public struct ZenTheme: Equatable, Sendable {
    public static let `default` = ZenTheme()

    public let density: ZenDensity
    public let cornerStyle: ZenCornerStyle
    public let motion: ZenMotion
    public let typography: ZenTypography
    public let accent: ZenDynamicColor?
    public let colors: ZenThemeColors?

    public init(
        density: ZenDensity = .comfortable,
        cornerStyle: ZenCornerStyle = .rounded,
        motion: ZenMotion = .standard,
        typography: ZenTypography = .default,
        accent: ZenDynamicColor? = nil,
        colors: ZenThemeColors? = nil
    ) {
        self.density = density
        self.cornerStyle = cornerStyle
        self.motion = motion
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
        makeResolvedTypography(
            titleSize: 18,
            bodySize: 15,
            labelSize: 14,
            captionSize: 12,
            buttonSize: 14,
            monoSize: 12
        )
    }

    private func makeResolvedTypography(
        titleSize: CGFloat,
        bodySize: CGFloat,
        labelSize: CGFloat,
        captionSize: CGFloat,
        buttonSize: CGFloat,
        monoSize: CGFloat
    ) -> ZenResolvedTypography {
        ZenResolvedTypography(
            heading: makeResolvedFontSpec(role: .display, size: 28, weight: .semibold),
            title: makeResolvedFontSpec(role: .display, size: titleSize, weight: .semibold),
            body: makeResolvedFontSpec(role: .body, size: bodySize, weight: .regular),
            label: makeResolvedFontSpec(role: .body, size: labelSize, weight: .medium),
            caption: makeResolvedFontSpec(role: .body, size: captionSize, weight: .regular),
            button: makeResolvedFontSpec(role: .body, size: buttonSize, weight: .medium),
            mono: makeResolvedFontSpec(role: .code, size: monoSize, weight: .regular)
        )
    }

    private func makeResolvedFontSpec(
        role: ZenTypographyFamilyRole,
        size: CGFloat,
        weight: ZenFontWeight
    ) -> ZenResolvedFontSpec {
        let family = typography.family(for: role)
        let resolved = family.resolvedSource(for: weight)

        return ZenResolvedFontSpec(
            familyRole: role,
            source: family.source,
            resolvedSource: resolved.source,
            resolvedFontName: resolved.resolvedFontName,
            size: size,
            weight: weight
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
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        }

        ZenCard(title: "Compact None", subtitle: "Density and corner style") {
            Text("Control height \(Int(ZenTheme(density: .compact, cornerStyle: .none).resolvedMetrics.controlHeight))")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
