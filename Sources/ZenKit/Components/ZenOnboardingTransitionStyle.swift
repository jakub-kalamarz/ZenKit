import SwiftUI

public struct ZenOnboardingTransitionStyle: Sendable {
    enum Variant: Sendable {
        case `default`
        case expressive
    }

    let variant: Variant

    public static let `default` = Self(variant: .default)
    public static let expressive = Self(variant: .expressive)

    private init(variant: Variant) {
        self.variant = variant
    }
}
