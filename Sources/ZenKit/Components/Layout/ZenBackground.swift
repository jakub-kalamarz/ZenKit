import SwiftUI

public struct ZenBackgroundView: View {
    @Environment(\.zenBackgroundView) private var customBackground

    public init() {}

    public var body: some View {
        if let customBackground {
            customBackground
                .ignoresSafeArea()
        } else {
            Color.zenBackground
                .ignoresSafeArea()
        }
    }
}

public struct ZenBackground<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack {
            ZenBackgroundView()
            content
        }
    }
}

public extension View {
    func zenBackground() -> some View {
        self.background(ZenBackgroundView())
    }

    func zenBackgroundView<V: View>(_ view: V) -> some View {
        environment(\.zenBackgroundView, AnyView(view))
    }
}

private struct ZenBackgroundViewKey: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    var zenBackgroundView: AnyView? {
        get { self[ZenBackgroundViewKey.self] }
        set { self[ZenBackgroundViewKey.self] = newValue }
    }
}
