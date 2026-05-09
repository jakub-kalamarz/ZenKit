import SwiftUI

public enum ZenNavigationBarTitleDisplayMode {
    case automatic
    case inline
    case large
}

public struct ZenScreenTitle: Equatable, Sendable {
    public let text: String
    public let subheadline: String?
    public let leadingIcon: ZenIconSource?
    public let trailingIcon: ZenIconSource?

    public var leadingIconAsset: String? {
        guard case .asset(let assetName, _)? = leadingIcon else { return nil }
        return assetName
    }

    public var trailingIconAsset: String? {
        guard case .asset(let assetName, _)? = trailingIcon else { return nil }
        return assetName
    }

    public init(
        _ text: String,
        subheadline: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        trailingIcon: ZenIconSource? = nil,
        leadingIconAsset: String? = nil,
        trailingIconAsset: String? = nil
    ) {
        self.text = text
        self.subheadline = subheadline
        self.leadingIcon = leadingIcon ?? leadingIconAsset.map { .asset($0, renderingMode: .template) }
        self.trailingIcon = trailingIcon ?? trailingIconAsset.map { .asset($0, renderingMode: .template) }
    }
}

public struct ZenScreenBackButton {
    public let text: String?
    public let action: (() -> Void)?

    public init(_ text: String? = nil, action: (() -> Void)? = nil) {
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
