import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public enum ZenTypographyFamilyRole: CaseIterable, Sendable {
    case display
    case text
}

public enum ZenTypographyToken: String, CaseIterable, Sendable {
    case textXS
    case textSM
    case textBase
    case textLG
    case textXL
    case displayXS
    case displaySM
    case displayMD
    case displayLG
    case displayXL
    case display2XL
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

#if canImport(UIKit)
    fileprivate var uiKitWeight: UIFont.Weight {
        switch self {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        }
    }
#endif
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
    public static var `default`: ZenTypography {
        ZenFontRegistry.registeredTypography() ?? ZenTypography(
            display: .init(source: .system(.default)),
            text: .init(source: .system(.default))
        )
    }

    public let display: ZenTypographyFamily
    public let text: ZenTypographyFamily

    public init(
        display: ZenTypographyFamily = .init(source: .system(.default)),
        text: ZenTypographyFamily = .init(source: .system(.default))
    ) {
        self.display = display
        self.text = text
    }

    func family(for role: ZenTypographyFamilyRole) -> ZenTypographyFamily {
        switch role {
        case .display:
            return display
        case .text:
            return text
        }
    }
}

public enum ZenFontRegistry {
    private static let lock = NSLock()
    private static var typography: ZenTypography?

    public static func register(display: ZenTypographyFamily, text: ZenTypographyFamily) {
        lock.withLock {
            typography = ZenTypography(display: display, text: text)
        }
    }

    public static func clear() {
        lock.withLock {
            typography = nil
        }
    }

    static func registeredTypography() -> ZenTypography? {
        lock.withLock { typography }
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

#if canImport(UIKit)
    var uiFont: UIFont {
        switch resolvedSource {
        case .system:
            return .systemFont(ofSize: size, weight: weight.uiKitWeight)
        case .custom:
            if let resolvedFontName, let customFont = UIFont(name: resolvedFontName, size: size) {
                return customFont
            }

            return .systemFont(ofSize: size, weight: weight.uiKitWeight)
        }
    }
#endif

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
    public let textXS: ZenResolvedFontSpec
    public let textSM: ZenResolvedFontSpec
    public let textBase: ZenResolvedFontSpec
    public let textLG: ZenResolvedFontSpec
    public let textXL: ZenResolvedFontSpec
    public let displayXS: ZenResolvedFontSpec
    public let displaySM: ZenResolvedFontSpec
    public let displayMD: ZenResolvedFontSpec
    public let displayLG: ZenResolvedFontSpec
    public let displayXL: ZenResolvedFontSpec
    public let display2XL: ZenResolvedFontSpec

    public init(
        textXS: ZenResolvedFontSpec,
        textSM: ZenResolvedFontSpec,
        textBase: ZenResolvedFontSpec,
        textLG: ZenResolvedFontSpec,
        textXL: ZenResolvedFontSpec,
        displayXS: ZenResolvedFontSpec,
        displaySM: ZenResolvedFontSpec,
        displayMD: ZenResolvedFontSpec,
        displayLG: ZenResolvedFontSpec,
        displayXL: ZenResolvedFontSpec,
        display2XL: ZenResolvedFontSpec
    ) {
        self.textXS = textXS
        self.textSM = textSM
        self.textBase = textBase
        self.textLG = textLG
        self.textXL = textXL
        self.displayXS = displayXS
        self.displaySM = displaySM
        self.displayMD = displayMD
        self.displayLG = displayLG
        self.displayXL = displayXL
        self.display2XL = display2XL
    }

    public func fontSpec(for role: ZenTypographyToken) -> ZenResolvedFontSpec {
        switch role {
        case .textXS:
            return textXS
        case .textSM:
            return textSM
        case .textBase:
            return textBase
        case .textLG:
            return textLG
        case .textXL:
            return textXL
        case .displayXS:
            return displayXS
        case .displaySM:
            return displaySM
        case .displayMD:
            return displayMD
        case .displayLG:
            return displayLG
        case .displayXL:
            return displayXL
        case .display2XL:
            return display2XL
        }
    }

    public func font(for role: ZenTypographyToken) -> Font {
        fontSpec(for: role).font
    }
}

public extension Font {
    static var zenTextXS: Font { ZenTheme.current.resolvedTypography.font(for: .textXS) }
    static var zenTextSM: Font { ZenTheme.current.resolvedTypography.font(for: .textSM) }
    static var zenTextBase: Font { ZenTheme.current.resolvedTypography.font(for: .textBase) }
    static var zenTextLG: Font { ZenTheme.current.resolvedTypography.font(for: .textLG) }
    static var zenTextXL: Font { ZenTheme.current.resolvedTypography.font(for: .textXL) }
    static var zenDisplayXS: Font { ZenTheme.current.resolvedTypography.font(for: .displayXS) }
    static var zenDisplaySM: Font { ZenTheme.current.resolvedTypography.font(for: .displaySM) }
    static var zenDisplayMD: Font { ZenTheme.current.resolvedTypography.font(for: .displayMD) }
    static var zenDisplayLG: Font { ZenTheme.current.resolvedTypography.font(for: .displayLG) }
    static var zenDisplayXL: Font { ZenTheme.current.resolvedTypography.font(for: .displayXL) }
    static var zenDisplay2XL: Font { ZenTheme.current.resolvedTypography.font(for: .display2XL) }
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

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
