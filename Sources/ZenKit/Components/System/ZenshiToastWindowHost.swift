#if canImport(UIKit)
import UIKit
import SwiftUI

enum ZenToastWindowManager {
    private static var window: UIWindow?
    private static var observer: NSObjectProtocol?

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
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return hit == rootViewController?.view ? nil : hit
    }
}
#endif
