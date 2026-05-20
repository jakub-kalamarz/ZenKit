import SwiftUI

public enum ZenNavigationBarTitleDisplayMode {
    case automatic
    case inline
    case large
}

public struct ZenScreenTitle: Equatable {
    public let text: LocalizedStringKey
    public let subheadline: LocalizedStringKey?
    public let leadingIcon: ZenIconSource?
    public let trailingIcon: ZenIconSource?
    private let comparisonText: String
    private let comparisonSubheadline: String?

    public var leadingIconAsset: String? {
        guard case .asset(let assetName, _)? = leadingIcon else { return nil }
        return assetName
    }

    public var trailingIconAsset: String? {
        guard case .asset(let assetName, _)? = trailingIcon else { return nil }
        return assetName
    }

    public init(
        _ text: LocalizedStringKey,
        subheadline: LocalizedStringKey? = nil,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        trailingIconAsset: String? = nil
    ) {
        self.text = text
        self.subheadline = subheadline
        self.comparisonText = String(describing: text)
        self.comparisonSubheadline = subheadline.map { String(describing: $0) }
        self.leadingIcon = leadingIcon ?? leadingIconAsset.map { .asset($0, renderingMode: .template) }
        self.trailingIcon = trailingIcon ?? trailingIconAsset.map { .asset($0, renderingMode: .template) }
    }

    public init(
        _ text: String,
        subheadline: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        trailingIconAsset: String? = nil
    ) {
        self.text = LocalizedStringKey(text)
        self.subheadline = subheadline.map { LocalizedStringKey($0) }
        self.comparisonText = text
        self.comparisonSubheadline = subheadline
        self.leadingIcon = leadingIcon ?? leadingIconAsset.map { .asset($0, renderingMode: .template) }
        self.trailingIcon = trailingIcon ?? trailingIconAsset.map { .asset($0, renderingMode: .template) }
    }

    public static func == (lhs: ZenScreenTitle, rhs: ZenScreenTitle) -> Bool {
        lhs.comparisonText == rhs.comparisonText
            && lhs.comparisonSubheadline == rhs.comparisonSubheadline
            && lhs.leadingIcon == rhs.leadingIcon
            && lhs.trailingIcon == rhs.trailingIcon
    }
}

public struct ZenScreenBackButton {
    public let text: LocalizedStringKey?
    public let action: (() -> Void)?

    public init(_ text: LocalizedStringKey? = nil, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }
}

struct ZenScreenNavigationContext {
    var title: ZenScreenTitle?
    var backButton: ZenScreenBackButton?
}

struct ZenScreenNavigationContextKey: EnvironmentKey {
    static let defaultValue = ZenScreenNavigationContext()
}

extension EnvironmentValues {
    var zenScreenNavigationContext: ZenScreenNavigationContext {
        get { self[ZenScreenNavigationContextKey.self] }
        set { self[ZenScreenNavigationContextKey.self] = newValue }
    }
}

public extension View {
    func zenScreenNavigationContext(
        title: ZenScreenTitle? = nil,
        backButton: ZenScreenBackButton? = nil
    ) -> some View {
        environment(
            \.zenScreenNavigationContext,
            ZenScreenNavigationContext(title: title, backButton: backButton)
        )
    }
}
