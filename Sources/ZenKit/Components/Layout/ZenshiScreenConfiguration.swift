import SwiftUI

public enum ZenNavigationBarTitleDisplayMode {
    case automatic
    case inline
    case large
}

public struct ZenScreenTitle: Equatable {
    /// `Text`, not `LocalizedStringKey`, so a screen titled with the host's own content —
    /// a board's name, a document's name — can be passed verbatim. Wrapped in a key, such
    /// a name is looked up in the host's catalog, and one that happens to match a key is
    /// replaced by that key's translation.
    public let text: Text
    public let subheadline: Text?
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
        self.text = Text(text)
        self.subheadline = subheadline.map { Text($0) }
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
        self.text = Text(LocalizedStringKey(text))
        self.subheadline = subheadline.map { Text(LocalizedStringKey($0)) }
        self.comparisonText = text
        self.comparisonSubheadline = subheadline
        self.leadingIcon = leadingIcon ?? leadingIconAsset.map { .asset($0, renderingMode: .template) }
        self.trailingIcon = trailingIcon ?? trailingIconAsset.map { .asset($0, renderingMode: .template) }
    }

    /// A screen whose title is content rather than copy — a record's own name.
    public init(
        verbatim text: String,
        subheadlineVerbatim subheadline: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil
    ) {
        self.text = Text(verbatim: text)
        self.subheadline = subheadline.map { Text(verbatim: $0) }
        self.comparisonText = text
        self.comparisonSubheadline = subheadline
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
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
