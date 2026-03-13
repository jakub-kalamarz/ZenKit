import CoreGraphics
import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitToastHostTests {
    @Test
    @MainActor
    func toastHostStillComposesVisibleToastStack() {
        let center = ZenToastCenter(maxVisibleToasts: 1)
        _ = center.show("Saved")

        let view = ZenToastHost(center: center)

        _ = view
    }

    @Test
    func bottomEdgeUsesBottomAnchoredLayoutOnCompactWidth() {
        let layout = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))

        #expect(layout.hostAlignment == .bottom)
        #expect(layout.stackAlignment == .bottom)
        #expect(layout.cardAlignment == .trailing)
        #expect(layout.cardAnchor == .bottomTrailing)
        #expect(layout.verticalOffset(for: 2, expanded: false) == -24)
        #expect(layout.verticalOffset(for: 2, expanded: true) == -144)
        #expect(layout.insertionOffsetY == 88)
        #expect(layout.removalOffsetY == 88)
    }

    @Test
    func topEdgeUsesTopAnchoredLayoutOnCompactWidth() {
        let layout = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(layout.hostAlignment == .top)
        #expect(layout.stackAlignment == .top)
        #expect(layout.cardAlignment == .trailing)
        #expect(layout.cardAnchor == .topTrailing)
        #expect(layout.verticalOffset(for: 2, expanded: false) == 24)
        #expect(layout.verticalOffset(for: 2, expanded: true) == 144)
        #expect(layout.insertionOffsetY == -88)
        #expect(layout.removalOffsetY == -88)
    }

    @Test
    func wideLayoutsStayTrailingAlignedForEitherEdge() {
        let bottom = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 900, height: 700))
        let top = ZenToastHost.Layout(edge: .top, size: CGSize(width: 900, height: 700))

        #expect(bottom.hostAlignment == .bottomTrailing)
        #expect(bottom.stackAlignment == .bottomTrailing)
        #expect(top.hostAlignment == .topTrailing)
        #expect(top.stackAlignment == .topTrailing)
    }

    @Test
    func dismissesForHorizontalSwipeInEitherDirection() {
        let layout = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(layout.shouldDismiss(for: CGSize(width: 97, height: 0)))
        #expect(layout.shouldDismiss(for: CGSize(width: -97, height: 0)))
    }

    @Test
    func topEdgeDismissesForUpwardSwipeOnly() {
        let layout = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(layout.shouldDismiss(for: CGSize(width: 0, height: -97)))
        #expect(!layout.shouldDismiss(for: CGSize(width: 0, height: 97)))
    }

    @Test
    func bottomEdgeDismissesForDownwardSwipeOnly() {
        let layout = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))

        #expect(layout.shouldDismiss(for: CGSize(width: 0, height: 97)))
        #expect(!layout.shouldDismiss(for: CGSize(width: 0, height: -97)))
    }
}
