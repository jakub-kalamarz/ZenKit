import SwiftUI

public extension View {
    /// Pins the scroll edge effect to `.soft` — the fade-and-blur under a bar — for every scroll view
    /// below this point.
    ///
    /// Nothing set it before, so every scroll view took `.automatic`, and the iOS 26 SDK resolved that
    /// to `.soft`. **The iOS 27 SDK resolves `.automatic` to `.hard`**: a flat, opaque band under the
    /// navigation bar and over the bottom bars, so an app rebuilt with Xcode 27 changed its top bar
    /// without a line of its own changing. Naming the style is what keeps the look the SDK's choice
    /// can't move.
    ///
    /// `scrollEdgeEffectStyle(_:for:)` flows down the hierarchy, so apply this once at an app's root.
    /// `ZenScreen`, `ZenListScreen` and `ZenSheetContainer` apply it themselves. A screen that wants
    /// the hard edge sets `.scrollEdgeEffectStyle(.hard, for:)` closer to its scroll view, which wins.
    /// Before iOS 26 / macOS 26 there is no edge effect and this does nothing.
    @ViewBuilder
    func zenScrollEdgeEffect(for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26, macOS 26, *) {
            scrollEdgeEffectStyle(.soft, for: edges)
        } else {
            self
        }
    }
}
