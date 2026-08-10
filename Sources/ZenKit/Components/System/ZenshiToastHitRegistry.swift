import SwiftUI

/// Window-coordinate rects of the currently visible toast cards.
///
/// The toast host lives in its own `UIWindow` so toasts float above sheets and alerts. That
/// window has to pass touches through everywhere except the cards themselves, and it cannot
/// work that out from `super.hitTest`: a SwiftUI hosting view answers with its own root view for
/// every point inside it, so "did the touch land on a card?" is unanswerable from UIKit alone.
/// The cards therefore publish their frames here and the window consults them.
@MainActor
final class ZenToastHitRegistry {
    static let shared = ZenToastHitRegistry()

    private var rects: [ZenToastID: CGRect] = [:]

    private init() {}

    func update(_ id: ZenToastID, rect: CGRect) {
        rects[id] = rect
    }

    func remove(_ id: ZenToastID) {
        rects.removeValue(forKey: id)
    }

    func containsPoint(_ point: CGPoint) -> Bool {
        rects.values.contains { $0.contains(point) }
    }
}

extension View {
    /// Publishes this toast card's frame to `ZenToastHitRegistry` for the lifetime of the card.
    func zenToastHitRegion(id: ZenToastID) -> some View {
        background(
            GeometryReader { proxy in
                let frame = proxy.frame(in: .global)
                Color.clear
                    .onAppear { ZenToastHitRegistry.shared.update(id, rect: frame) }
                    .onChange(of: frame) { _, newFrame in
                        ZenToastHitRegistry.shared.update(id, rect: newFrame)
                    }
                    .onDisappear { ZenToastHitRegistry.shared.remove(id) }
            }
        )
    }
}
