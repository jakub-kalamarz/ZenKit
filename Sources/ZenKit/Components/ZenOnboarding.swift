import SwiftUI

public struct ZenOnboardingBackgroundStyle: Sendable {
    public static func animatedMesh() -> Self {
        Self()
    }

    private init() {}
}

public struct ZenOnboardingTransitionStyle: Sendable {
    public static let `default` = Self()
    public static let expressive = Self()

    private init() {}
}

public struct ZenOnboardingStep<ID: Hashable, Content: View>: Identifiable, View {
    public let id: ID
    public let content: Content

    public init(id: ID, @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
    }

    public var body: some View {
        content
    }
}

struct ZenOnboardingBuilderPage<ID: Hashable>: Identifiable {
    let id: ID
}

public struct ZenOnboarding<Page, Content>: View where Page: Identifiable, Content: View {
    public init(
        pages: [Page],
        selection: Binding<Page.ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        @ViewBuilder content: @escaping (Page) -> Content
    ) {
    }

    init<ID: Hashable>(
        selection: Binding<ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        @ViewBuilder content: @escaping () -> Content
    ) where Page == ZenOnboardingBuilderPage<ID> {
    }

    public var body: some View {
        EmptyView()
    }
}
