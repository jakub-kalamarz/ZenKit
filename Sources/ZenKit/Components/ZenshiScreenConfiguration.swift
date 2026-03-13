import SwiftUI

public enum ZenNavigationBarTitleDisplayMode {
    case automatic
    case inline
    case large
}

public struct ZenScreenTitle: Equatable, Sendable {
    public let text: String
    public let leadingIconAsset: String?
    public let trailingIconAsset: String?

    public init(
        _ text: String,
        leadingIconAsset: String? = nil,
        trailingIconAsset: String? = nil
    ) {
        self.text = text
        self.leadingIconAsset = leadingIconAsset
        self.trailingIconAsset = trailingIconAsset
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
