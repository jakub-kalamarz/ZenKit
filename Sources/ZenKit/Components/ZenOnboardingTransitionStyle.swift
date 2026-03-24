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

    internal func resolvedConfiguration(reduceMotion: Bool) -> ZenOnboardingTransitionConfiguration {
        guard !reduceMotion else {
            return .reduceMotion
        }

        switch variant {
        case .default:
            return .defaultMotion
        case .expressive:
            return .expressiveMotion
        }
    }
}

internal struct ZenOnboardingTransitionConfiguration: Equatable, Sendable {
    enum Style: Equatable, Sendable {
        case opacityOnly
        case animated(scale: CGFloat, offsetY: CGFloat)
    }

    let style: Style
    let response: Double
    let dampingFraction: Double

    static let reduceMotion = Self(
        style: .opacityOnly,
        response: 0.2,
        dampingFraction: 1.0
    )

    static let defaultMotion = Self(
        style: .animated(scale: 0.985, offsetY: 8),
        response: 0.34,
        dampingFraction: 0.88
    )

    static let expressiveMotion = Self(
        style: .animated(scale: 0.962, offsetY: 14),
        response: 0.48,
        dampingFraction: 0.82
    )

    var animation: Animation {
        switch style {
        case .opacityOnly:
            return .easeOut(duration: 0.18)
        case .animated:
            return .spring(response: response, dampingFraction: dampingFraction)
        }
    }

    var transition: AnyTransition {
        switch style {
        case .opacityOnly:
            return .opacity
        case .animated(let scale, let offsetY):
            let insertion = AnyTransition.opacity
                .combined(with: .scale(scale: scale))
                .combined(with: .offset(y: offsetY))

            let removal = AnyTransition.opacity
                .combined(with: .scale(scale: min(1.0, scale + 0.01)))
                .combined(with: .offset(y: -offsetY * 0.45))

            return .asymmetric(insertion: insertion, removal: removal)
        }
    }
}
