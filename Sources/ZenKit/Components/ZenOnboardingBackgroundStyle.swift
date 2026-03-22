import SwiftUI

public enum ZenOnboardingMotionIntensity: Sendable {
    case subtle
    case expressive
}

public struct ZenOnboardingBackgroundStyle: Sendable {
    let intensity: ZenOnboardingMotionIntensity

    public static func animatedMesh(intensity: ZenOnboardingMotionIntensity = .subtle) -> Self {
        Self(intensity: intensity)
    }

    private init(intensity: ZenOnboardingMotionIntensity) {
        self.intensity = intensity
    }
}
