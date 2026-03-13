import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public enum ZenTypographyFamilyRole: CaseIterable, Sendable {
    case display
    case body
    case code
}

public enum ZenTypographyRole: Sendable {
    case heading
    case title
    case body
    case label
    case caption
    case button
    case mono
}

public enum ZenSystemFontDesign: Sendable, Equatable {
    case `default`
    case rounded
    case serif
    case monospaced

    fileprivate var swiftUIDesign: Font.Design {
        switch self {
        case .default:
            return .default
        case .rounded:
            return .rounded
        case .serif:
            return .serif
        case .monospaced:
            return .monospaced
        }
    }
}

public struct ZenFontFamily: Equatable, Sendable {
    public let regular: String
    public let medium: String?
    public let semibold: String?
    public let bold: String?

    public init(
        regular: String,
        medium: String? = nil,
        semibold: String? = nil,
        bold: String? = nil
    ) {
        self.regular = regular
        self.medium = medium
        self.semibold = semibold
        self.bold = bold
    }

    public func fontName(for weight: ZenFontWeight) -> String {
        switch weight {
        case .regular:
            return regular
        case .medium:
            return medium ?? semibold ?? regular
        case .semibold:
            return semibold ?? medium ?? bold ?? regular
        }
    }

    public static let bricolageGrotesque = ZenFontFamily(
        regular: "BricolageGrotesque-Regular",
        medium: "BricolageGrotesque-Medium",
        semibold: "BricolageGrotesque-SemiBold",
        bold: "BricolageGrotesque-Bold"
    )
}

public enum ZenFontSource: Sendable, Equatable {
    case system(ZenSystemFontDesign)
    case custom(ZenFontFamily)
}

public enum ZenFontWeight: Sendable, Equatable {
    case regular
    case medium
    case semibold

    fileprivate var swiftUIWeight: Font.Weight {
        switch self {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        }
    }
}

public struct ZenTypographyFamily: Equatable, Sendable {
    public let source: ZenFontSource
    public let fallback: ZenSystemFontDesign

    public init(source: ZenFontSource, fallback: ZenSystemFontDesign? = nil) {
        self.source = source

        switch source {
        case let .system(design):
            self.fallback = fallback ?? design
        case .custom:
            self.fallback = fallback ?? .default
        }
    }
}

public struct ZenTypography: Equatable, Sendable {
    public static let `default` = ZenTypography(
        display: .init(source: .custom(.bricolageGrotesque)),
        body: .init(source: .custom(.bricolageGrotesque)),
        code: .init(source: .system(.monospaced))
    )

    public let display: ZenTypographyFamily
    public let body: ZenTypographyFamily
    public let code: ZenTypographyFamily

    public init(
        display: ZenTypographyFamily = .init(source: .system(.default)),
        body: ZenTypographyFamily = .init(source: .system(.default)),
        code: ZenTypographyFamily = .init(source: .system(.monospaced))
    ) {
        self.display = display
        self.body = body
        self.code = code
    }

    func family(for role: ZenTypographyFamilyRole) -> ZenTypographyFamily {
        switch role {
        case .display:
            return display
        case .body:
            return body
        case .code:
            return code
        }
    }
}

public struct ZenResolvedFontSpec: Equatable, Sendable {
    public let familyRole: ZenTypographyFamilyRole
    public let source: ZenFontSource
    public let resolvedSource: ZenFontSource
    public let resolvedFontName: String?
    public let size: CGFloat
    public let weight: ZenFontWeight

    public init(
        familyRole: ZenTypographyFamilyRole,
        source: ZenFontSource,
        resolvedSource: ZenFontSource,
        resolvedFontName: String? = nil,
        size: CGFloat,
        weight: ZenFontWeight
    ) {
        self.familyRole = familyRole
        self.source = source
        self.resolvedSource = resolvedSource
        self.resolvedFontName = resolvedFontName
        self.size = size
        self.weight = weight
    }

    var font: Font {
        switch resolvedSource {
        case let .system(design):
            return .system(size: size, weight: weight.swiftUIWeight, design: design.swiftUIDesign)
        case .custom:
            if let resolvedFontName {
                return .custom(resolvedFontName, size: size)
            }

            return .system(size: size, weight: weight.swiftUIWeight, design: .default)
        }
    }

    func with(size: CGFloat, weight: ZenFontWeight? = nil) -> ZenResolvedFontSpec {
        let resolvedWeight = weight ?? self.weight
        let resolvedFontName = {
            switch resolvedSource {
            case .system:
                return self.resolvedFontName
            case let .custom(family):
                return family.fontName(for: resolvedWeight)
            }
        }()

        return ZenResolvedFontSpec(
            familyRole: familyRole,
            source: source,
            resolvedSource: resolvedSource,
            resolvedFontName: resolvedFontName,
            size: size,
            weight: resolvedWeight
        )
    }
}

public struct ZenResolvedTypography: Equatable, Sendable {
    public let heading: ZenResolvedFontSpec
    public let title: ZenResolvedFontSpec
    public let body: ZenResolvedFontSpec
    public let label: ZenResolvedFontSpec
    public let caption: ZenResolvedFontSpec
    public let button: ZenResolvedFontSpec
    public let mono: ZenResolvedFontSpec

    public init(
        heading: ZenResolvedFontSpec,
        title: ZenResolvedFontSpec,
        body: ZenResolvedFontSpec,
        label: ZenResolvedFontSpec,
        caption: ZenResolvedFontSpec,
        button: ZenResolvedFontSpec,
        mono: ZenResolvedFontSpec
    ) {
        self.heading = heading
        self.title = title
        self.body = body
        self.label = label
        self.caption = caption
        self.button = button
        self.mono = mono
    }

    public func fontSpec(for role: ZenTypographyRole) -> ZenResolvedFontSpec {
        switch role {
        case .heading:
            return heading
        case .title:
            return title
        case .body:
            return body
        case .label:
            return label
        case .caption:
            return caption
        case .button:
            return button
        case .mono:
            return mono
        }
    }

    public func font(for role: ZenTypographyRole) -> Font {
        fontSpec(for: role).font
    }
}

public extension Font {
    static var zenHeading: Font { ZenTheme.current.resolvedTypography.font(for: .heading) }
    static var zenTitle: Font { ZenTheme.current.resolvedTypography.font(for: .title) }
    static var zenBody: Font { ZenTheme.current.resolvedTypography.font(for: .body) }
    static var zenLabel: Font { ZenTheme.current.resolvedTypography.font(for: .label) }
    static var zenCaption: Font { ZenTheme.current.resolvedTypography.font(for: .caption) }
    static var zenButton: Font { ZenTheme.current.resolvedTypography.font(for: .button) }
    static var zenMono: Font { ZenTheme.current.resolvedTypography.font(for: .mono) }
}

extension ZenTypographyFamily {
    func resolvedSource(for weight: ZenFontWeight) -> (source: ZenFontSource, resolvedFontName: String?) {
        switch source {
        case .system:
            return (source, nil)
        case let .custom(family):
            let fontName = family.fontName(for: weight)

            if isAvailableCustomFont(named: fontName) {
                return (.custom(family), fontName)
            }

            return (.system(fallback), nil)
        }
    }
}

private func isAvailableCustomFont(named name: String) -> Bool {
#if canImport(UIKit)
    UIFont(name: name, size: 12) != nil
#elseif canImport(AppKit)
    NSFont(name: name, size: 12) != nil
#else
    false
#endif
}
