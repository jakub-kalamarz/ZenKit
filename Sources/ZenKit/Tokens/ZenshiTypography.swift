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
    case displayXL
    case displayL
    case displayM
    case displayS
    case stat
    case body
    case body2
    case intro
    case button
    case tab
    case eyebrow
    case group
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
        case .bold:
            return bold ?? semibold ?? medium ?? regular
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
    public let bold: Double

    public init(
        regular: Double = 400,
        medium: Double = 500,
        semibold: Double = 600,
        bold: Double = 700
    ) {
        self.regular = regular
        self.medium = medium
        self.semibold = semibold
        self.bold = bold
    }

    public func value(for weight: ZenFontWeight) -> Double {
        switch weight {
        case .regular:
            return regular
        case .medium:
            return medium
        case .semibold:
            return semibold
        case .bold:
            return bold
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
    case bold

    fileprivate var swiftUIWeight: Font.Weight {
        switch self {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
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
        case .bold:
            return .bold
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
        case .bold:
            return .bold
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
    public let leading: Font.Leading?

    public init(
        familyRole: ZenTypographyFamilyRole,
        source: ZenFontSource,
        resolvedSource: ZenFontSource,
        resolvedFontName: String? = nil,
        resolvedVariableAxes: ZenVariableFontAxes? = nil,
        size: CGFloat,
        weight: ZenFontWeight,
        leading: Font.Leading? = nil
    ) {
        self.familyRole = familyRole
        self.source = source
        self.resolvedSource = resolvedSource
        self.resolvedFontName = resolvedFontName
        self.resolvedVariableAxes = resolvedVariableAxes
        self.size = size
        self.weight = weight
        self.leading = leading
    }

    var font: Font {
        var result: Font

        switch resolvedSource {
        case let .system(design):
            result = .system(size: size, weight: weight.swiftUIWeight, design: design.swiftUIDesign)
        case .custom, .variable:
            #if canImport(UIKit)
            if let platformFont = resolvedUIFont {
                result = Font(platformFont)
            } else {
                result = .system(size: size, weight: weight.swiftUIWeight, design: .default)
            }
            #elseif canImport(AppKit)
            if let platformFont = resolvedNSFont {
                result = Font(platformFont)
            } else {
                result = .system(size: size, weight: weight.swiftUIWeight, design: .default)
            }
            #else
            result = .system(size: size, weight: weight.swiftUIWeight, design: .default)
            #endif
        }

        if let leading {
            result = result.leading(leading)
        }

        return result
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

    func with(size: CGFloat, weight: ZenFontWeight? = nil, leading: Font.Leading?? = nil) -> ZenResolvedFontSpec {
        let resolvedWeight = weight ?? self.weight
        let resolvedLeading: Font.Leading? = {
            switch leading {
            case .some(let value): return value
            case .none: return self.leading
            }
        }()
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
            weight: resolvedWeight,
            leading: resolvedLeading
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
    public let displayXL: ZenResolvedFontSpec
    public let displayL: ZenResolvedFontSpec
    public let displayM: ZenResolvedFontSpec
    public let displayS: ZenResolvedFontSpec
    public let stat: ZenResolvedFontSpec
    public let body: ZenResolvedFontSpec
    public let body2: ZenResolvedFontSpec
    public let intro: ZenResolvedFontSpec
    public let button: ZenResolvedFontSpec
    public let tab: ZenResolvedFontSpec
    public let eyebrow: ZenResolvedFontSpec
    public let group: ZenResolvedFontSpec

    public init(
        displayXL: ZenResolvedFontSpec,
        displayL: ZenResolvedFontSpec,
        displayM: ZenResolvedFontSpec,
        displayS: ZenResolvedFontSpec,
        stat: ZenResolvedFontSpec,
        body: ZenResolvedFontSpec,
        body2: ZenResolvedFontSpec,
        intro: ZenResolvedFontSpec,
        button: ZenResolvedFontSpec,
        tab: ZenResolvedFontSpec,
        eyebrow: ZenResolvedFontSpec,
        group: ZenResolvedFontSpec
    ) {
        self.displayXL = displayXL
        self.displayL = displayL
        self.displayM = displayM
        self.displayS = displayS
        self.stat = stat
        self.body = body
        self.body2 = body2
        self.intro = intro
        self.button = button
        self.tab = tab
        self.eyebrow = eyebrow
        self.group = group
    }

    public func fontSpec(for role: ZenTypographyToken) -> ZenResolvedFontSpec {
        switch role {
        case .displayXL: return displayXL
        case .displayL: return displayL
        case .displayM: return displayM
        case .displayS: return displayS
        case .stat: return stat
        case .body: return body
        case .body2: return body2
        case .intro: return intro
        case .button: return button
        case .tab: return tab
        case .eyebrow: return eyebrow
        case .group: return group
        }
    }

    public func font(for role: ZenTypographyToken) -> Font {
        fontSpec(for: role).font
    }
}

public extension Font {
    static func zen(_ role: ZenTypographyToken, weight: ZenFontWeight? = nil) -> Font {
        let spec = ZenTheme.current.resolvedTypography.fontSpec(for: role)
        return spec.with(size: spec.size, weight: weight).font
    }

    static var zenDisplayXL: Font { ZenTheme.current.resolvedTypography.font(for: .displayXL) }
    static var zenDisplayL: Font { ZenTheme.current.resolvedTypography.font(for: .displayL) }
    static var zenDisplayM: Font { ZenTheme.current.resolvedTypography.font(for: .displayM) }
    static var zenDisplayS: Font { ZenTheme.current.resolvedTypography.font(for: .displayS) }
    static var zenStat: Font { ZenTheme.current.resolvedTypography.font(for: .stat) }
    static var zenBody: Font { ZenTheme.current.resolvedTypography.font(for: .body) }
    static var zenBody2: Font { ZenTheme.current.resolvedTypography.font(for: .body2) }
    static var zenIntro: Font { ZenTheme.current.resolvedTypography.font(for: .intro) }
    static var zenButton: Font { ZenTheme.current.resolvedTypography.font(for: .button) }
    static var zenTab: Font { ZenTheme.current.resolvedTypography.font(for: .tab) }
    static var zenEyebrow: Font { ZenTheme.current.resolvedTypography.font(for: .eyebrow) }
    static var zenGroup: Font { ZenTheme.current.resolvedTypography.font(for: .group) }
}

public extension View {
    func zenEyebrowStyle() -> some View {
        self.font(.zenEyebrow)
            .tracking(0.6)
            .textCase(.uppercase)
    }

    func zenGroupStyle() -> some View {
        self.font(.zenGroup)
            .tracking(0.5)
            .textCase(.uppercase)
    }
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
