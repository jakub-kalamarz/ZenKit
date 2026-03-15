import SwiftUI

private struct ZenContainerCornerRadiusKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var zenContainerCornerRadius: CGFloat? {
        get { self[ZenContainerCornerRadiusKey.self] }
        set { self[ZenContainerCornerRadiusKey.self] = newValue }
    }
}

extension View {
    func zenContainerCornerRadius(_ radius: CGFloat) -> some View {
        environment(\.zenContainerCornerRadius, radius)
    }
}
