import SwiftUI

#if canImport(UIKit)
import UIKit

private enum ZenToastWindowManager {
    static var window: UIWindow?
    static var observer: NSObjectProtocol?

    static func scheduleSetup() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let scene = notification.object as? UIWindowScene,
                  window == nil
            else { return }
            install(in: scene)
        }
    }

    private static func install(in scene: UIWindowScene) {
        let w = ZenToastWindow(windowScene: scene)
        let vc = UIHostingController(rootView: ZenToastHost(center: .shared, edge: .top))
        vc.view.backgroundColor = .clear
        w.rootViewController = vc
        w.windowLevel = .alert - 1
        w.isHidden = false
        window = w
    }
}

private final class ZenToastWindow: UIWindow {
    /// Only the toast cards may consume touches; everything else has to reach the app below.
    ///
    /// Comparing the hit view against the root view does not distinguish the two: a SwiftUI
    /// hosting view answers with its own root for every point inside it, so that check swallowed
    /// nothing — it made the whole window transparent to touches and left the toast's own
    /// buttons ("Undo", the close control) unreachable. The cards publish their frames to
    /// `ZenToastHitRegistry`, so ask that instead.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard MainActor.assumeIsolated({ ZenToastHitRegistry.shared.containsPoint(point) }) else {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
#endif

func zenScheduleToastWindow() {
    #if canImport(UIKit)
    ZenToastWindowManager.scheduleSetup()
    #endif
}
