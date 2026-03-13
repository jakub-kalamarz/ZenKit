import SwiftUI

public extension View {
    @ViewBuilder
    func zenSymbolReplaceTransition() -> some View {
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1, *) {
            contentTransition(.symbolEffect(.replace))
        } else {
            self
        }
    }
}
