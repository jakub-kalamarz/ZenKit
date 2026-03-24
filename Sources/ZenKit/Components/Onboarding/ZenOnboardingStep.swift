import SwiftUI

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

@resultBuilder
enum ZenOnboardingStepBuilder {
    static func buildExpression<ID: Hashable, Content: View>(
        _ expression: ZenOnboardingStep<ID, Content>
    ) -> ZenOnboardingStep<ID, AnyView> {
        ZenOnboardingStep(id: expression.id) {
            AnyView(expression.content)
        }
    }

    static func buildBlock<ID: Hashable>(
        _ components: ZenOnboardingStep<ID, AnyView>...
    ) -> [ZenOnboardingStep<ID, AnyView>] {
        components
    }

    static func buildOptional<ID: Hashable>(
        _ component: [ZenOnboardingStep<ID, AnyView>]?
    ) -> [ZenOnboardingStep<ID, AnyView>] {
        component ?? []
    }

    static func buildEither<ID: Hashable>(
        first component: [ZenOnboardingStep<ID, AnyView>]
    ) -> [ZenOnboardingStep<ID, AnyView>] {
        component
    }

    static func buildEither<ID: Hashable>(
        second component: [ZenOnboardingStep<ID, AnyView>]
    ) -> [ZenOnboardingStep<ID, AnyView>] {
        component
    }

    static func buildArray<ID: Hashable>(
        _ components: [[ZenOnboardingStep<ID, AnyView>]]
    ) -> [ZenOnboardingStep<ID, AnyView>] {
        components.flatMap { $0 }
    }
}
