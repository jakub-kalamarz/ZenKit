import Foundation
import SwiftUI
import CoreText

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

public struct ZenVariableFontAxes: Equatable, Sendable {
    public let weight: Double?
    public let width: Double?
    public let opticalSize: Double?

    public init(
        weight: Double? = nil,
        width: Double? = nil,
        opticalSize: Double? = nil
    ) {
        self.weight = weight
        self.width = width
        self.opticalSize = opticalSize
    }

    public var isEmpty: Bool {
        weight == nil && width == nil && opticalSize == nil
    }

    fileprivate func merged(weight: Double?) -> ZenVariableFontAxes {
        ZenVariableFontAxes(
            weight: weight ?? self.weight,
            width: width,
            opticalSize: opticalSize
        )
    }

    fileprivate func filtered(supportedTags: Set<Int>) -> ZenVariableFontAxes {
        ZenVariableFontAxes(
            weight: supportedTags.contains(ZenVariableFontAxisTag.weight.rawValue) ? weight : nil,
            width: supportedTags.contains(ZenVariableFontAxisTag.width.rawValue) ? width : nil,
            opticalSize: supportedTags.contains(ZenVariableFontAxisTag.opticalSize.rawValue) ? opticalSize : nil
        )
    }

    fileprivate func variationAttributes() -> [NSNumber: NSNumber] {
        var attributes: [NSNumber: NSNumber] = [:]

        if let weight {
            attributes[NSNumber(value: ZenVariableFontAxisTag.weight.rawValue)] = NSNumber(value: weight)
        }

        if let width {
            attributes[NSNumber(value: ZenVariableFontAxisTag.width.rawValue)] = NSNumber(value: width)
        }

        if let opticalSize {
            attributes[NSNumber(value: ZenVariableFontAxisTag.opticalSize.rawValue)] = NSNumber(value: opticalSize)
        }

        return attributes
    }
}

public struct ZenVariableFontWeightMap: Equatable, Sendable {
    public let regular: Double
    public let medium: Double
    public let semibold: Double

    public init(
        regular: Double = 400,
        medium: Double = 500,
        semibold: Double = 600
    ) {
        self.regular = regular
        self.medium = medium
        self.semibold = semibold
    }

    public func value(for weight: ZenFontWeight) -> Double {
        switch weight {
        case .regular:
            return regular
        case .medium:
            return medium
        case .semibold:
            return semibold
        }
    }
}

public struct ZenVariableFont: Equatable, Sendable {
    public let name: String
    public let axes: ZenVariableFontAxes
    public let weights: ZenVariableFontWeightMap

    public init(
        name: String,
        axes: ZenVariableFontAxes = .init(),
        weights: ZenVariableFontWeightMap = .init()
    ) {
        self.name = name
        self.axes = axes
        self.weights = weights
    }

    public func axes(for weight: ZenFontWeight) -> ZenVariableFontAxes {
        axes.merged(weight: weights.value(for: weight))
    }
}

public enum ZenFontSource: Sendable, Equatable {
    case system(ZenSystemFontDesign)
    case custom(ZenFontFamily)
    case variable(ZenVariableFont)
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
#elseif canImport(AppKit)
    fileprivate var appKitWeight: NSFont.Weight {
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
        case .custom, .variable:
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
    public let resolvedVariableAxes: ZenVariableFontAxes?
    public let size: CGFloat
    public let weight: ZenFontWeight

    public init(
        familyRole: ZenTypographyFamilyRole,
        source: ZenFontSource,
        resolvedSource: ZenFontSource,
        resolvedFontName: String? = nil,
        resolvedVariableAxes: ZenVariableFontAxes? = nil,
        size: CGFloat,
        weight: ZenFontWeight
    ) {
        self.familyRole = familyRole
        self.source = source
        self.resolvedSource = resolvedSource
        self.resolvedFontName = resolvedFontName
        self.resolvedVariableAxes = resolvedVariableAxes
        self.size = size
        self.weight = weight
    }

    var font: Font {
        switch resolvedSource {
        case let .system(design):
            return .system(size: size, weight: weight.swiftUIWeight, design: design.swiftUIDesign)
        case .custom, .variable:
            #if canImport(UIKit)
            if let platformFont = resolvedUIFont {
                return Font(platformFont)
            }
            #elseif canImport(AppKit)
            if let platformFont = resolvedNSFont {
                return Font(platformFont)
            }
            #endif

            return .system(size: size, weight: weight.swiftUIWeight, design: .default)
        }
    }

#if canImport(UIKit)
    var uiFont: UIFont {
        switch resolvedSource {
        case .system:
            return .systemFont(ofSize: size, weight: weight.uiKitWeight)
        case .custom, .variable:
            if let resolvedUIFont {
                return resolvedUIFont
            }

            return .systemFont(ofSize: size, weight: weight.uiKitWeight)
        }
    }
#elseif canImport(AppKit)
    var nsFont: NSFont {
        switch resolvedSource {
        case .system:
            return .systemFont(ofSize: size, weight: weight.appKitWeight)
        case .custom, .variable:
            if let resolvedNSFont {
                return resolvedNSFont
            }

            return .systemFont(ofSize: size, weight: weight.appKitWeight)
        }
    }
#endif

    func with(size: CGFloat, weight: ZenFontWeight? = nil) -> ZenResolvedFontSpec {
        let resolvedWeight = weight ?? self.weight
        let resolved = {
            switch resolvedSource {
            case .system:
                return (
                    fontName: self.resolvedFontName,
                    variableAxes: self.resolvedVariableAxes
                )
            case let .custom(family):
                return (
                    fontName: family.fontName(for: resolvedWeight),
                    variableAxes: nil as ZenVariableFontAxes?
                )
            case let .variable(variableFont):
                let supportedTags = supportedVariationAxisTags(forFontNamed: variableFont.name)
                return (
                    fontName: variableFont.name,
                    variableAxes: {
                        let axes = variableFont.axes(for: resolvedWeight).filtered(supportedTags: supportedTags)
                        return axes.isEmpty ? nil : axes
                    }()
                )
            }
        }()

        return ZenResolvedFontSpec(
            familyRole: familyRole,
            source: source,
            resolvedSource: resolvedSource,
            resolvedFontName: resolved.fontName,
            resolvedVariableAxes: resolved.variableAxes,
            size: size,
            weight: resolvedWeight
        )
    }

#if canImport(UIKit)
    private var resolvedUIFont: UIFont? {
        guard let resolvedFontName else {
            return nil
        }

        return makeUIFont(
            named: resolvedFontName,
            size: size,
            variableAxes: resolvedVariableAxes
        )
    }
#elseif canImport(AppKit)
    private var resolvedNSFont: NSFont? {
        guard let resolvedFontName else {
            return nil
        }

        return makeNSFont(
            named: resolvedFontName,
            size: size,
            variableAxes: resolvedVariableAxes
        )
    }
#endif
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
    func resolvedSource(for weight: ZenFontWeight) -> (source: ZenFontSource, resolvedFontName: String?, resolvedVariableAxes: ZenVariableFontAxes?) {
        switch source {
        case .system:
            return (source, nil, nil)
        case let .custom(family):
            let fontName = family.fontName(for: weight)

            if isAvailableCustomFont(named: fontName) {
                return (.custom(family), fontName, nil)
            }

            return (.system(fallback), nil, nil)
        case let .variable(variableFont):
            guard isAvailableCustomFont(named: variableFont.name) else {
                return (.system(fallback), nil, nil)
            }

            let supportedTags = supportedVariationAxisTags(forFontNamed: variableFont.name)
            let resolvedAxes = variableFont.axes(for: weight).filtered(supportedTags: supportedTags)

            return (.variable(variableFont), variableFont.name, resolvedAxes.isEmpty ? nil : resolvedAxes)
        }
    }
}

private enum ZenVariableFontAxisTag: Int, Sendable {
    case weight = 2003265652
    case width = 2003072104
    case opticalSize = 1869640570
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

private func supportedVariationAxisTags(forFontNamed name: String) -> Set<Int> {
    guard let baseFont = makeCTFont(named: name, size: 12) else {
        return []
    }

    guard let axes = CTFontCopyVariationAxes(baseFont) as? [[CFString: Any]] else {
        return []
    }

    return Set(
        axes.compactMap { axis in
            axis[kCTFontVariationAxisIdentifierKey] as? NSNumber
        }.map(\.intValue)
    )
}

private func makeCTFont(named name: String, size: CGFloat) -> CTFont? {
#if canImport(UIKit)
    guard let font = UIFont(name: name, size: size) else {
        return nil
    }
    return CTFontCreateWithName(font.fontName as CFString, size, nil)
#elseif canImport(AppKit)
    guard let font = NSFont(name: name, size: size) else {
        return nil
    }
    return CTFontCreateWithName(font.fontName as CFString, size, nil)
#else
    return nil
#endif
}

#if canImport(UIKit)
private func makeUIFont(named name: String, size: CGFloat, variableAxes: ZenVariableFontAxes?) -> UIFont? {
    guard let baseFont = UIFont(name: name, size: size) else {
        return nil
    }

    guard let variableAxes else {
        return baseFont
    }

    let attributes = variableAxes.variationAttributes()
    guard !attributes.isEmpty else {
        return baseFont
    }

    let descriptor = baseFont.fontDescriptor.addingAttributes([
        UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): attributes
    ])

    return UIFont(descriptor: descriptor, size: size)
}
#elseif canImport(AppKit)
private func makeNSFont(named name: String, size: CGFloat, variableAxes: ZenVariableFontAxes?) -> NSFont? {
    guard let baseFont = NSFont(name: name, size: size) else {
        return nil
    }

    guard let variableAxes else {
        return baseFont
    }

    let attributes = variableAxes.variationAttributes()
    guard !attributes.isEmpty else {
        return baseFont
    }

    let descriptor = baseFont.fontDescriptor.addingAttributes([
        NSFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): attributes
    ])

    return NSFont(descriptor: descriptor, size: size)
}
#endif

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
