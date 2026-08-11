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
        #expect(layout.stackDirection == -1)
    }

    @Test
    func topEdgeUsesTopAnchoredLayoutOnCompactWidth() {
        let layout = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(layout.hostAlignment == .top)
        #expect(layout.stackAlignment == .top)
        #expect(layout.cardAlignment == .trailing)
        #expect(layout.cardAnchor == .topTrailing)
        #expect(layout.stackDirection == 1)
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
    func wideViewportPinsCardWidthAndUsesWiderInset() {
        let layout = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 900, height: 700))

        #expect(layout.cardWidth == 340)
        #expect(layout.viewportInset == 32)
    }

    @Test
    func compactViewportFillsAvailableWidthMinusInsets() {
        let layout = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))

        #expect(layout.cardWidth == 358)
        #expect(layout.viewportInset == 16)
    }

    @Test
    func stackScaleShrinksOneTenthPerStep() {
        #expect(ZenToastHost.Layout.scale(for: 0) == 1)
        #expect(abs(ZenToastHost.Layout.scale(for: 1) - 0.9) < 0.0001)
        #expect(abs(ZenToastHost.Layout.scale(for: 2) - 0.8) < 0.0001)
    }

    @Test
    func collapsedOffsetsSeparateOuterEdgesByPeekOnceScaleIsCancelled() {
        let bottom = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))
        let top = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(bottom.collapsedOffset(for: 0, stackHeight: 100) == 0)
        // depth 1: 1 * peek + (1 - 0.9) * 100
        #expect(abs(bottom.collapsedOffset(for: 1, stackHeight: 100) - -22) < 0.0001)
        // depth 2: 2 * peek + (1 - 0.8) * 100
        #expect(abs(bottom.collapsedOffset(for: 2, stackHeight: 100) - -44) < 0.0001)
        #expect(abs(top.collapsedOffset(for: 2, stackHeight: 100) - 44) < 0.0001)
    }

    @Test
    func expandedOffsetsClearEveryPrecedingCardPlusOneGapPerStep() {
        let bottom = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))
        let top = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(bottom.expandedOffset(for: 0, precedingHeight: 0) == 0)
        #expect(bottom.expandedOffset(for: 1, precedingHeight: 80) == -92)
        #expect(bottom.expandedOffset(for: 2, precedingHeight: 170) == -194)
        #expect(top.expandedOffset(for: 2, precedingHeight: 170) == 194)
    }

    @Test
    func cardsEnterAndLeaveBeyondTheAnchoredEdge() {
        let bottom = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))
        let top = ZenToastHost.Layout(edge: .top, size: CGSize(width: 390, height: 844))

        #expect(bottom.transitionOffset(cardHeight: 100) == 150)
        #expect(top.transitionOffset(cardHeight: 100) == -150)
    }

    @Test
    func transitionTravelNeverFallsBelowTheEstimatedCardHeight() {
        let layout = ZenToastHost.Layout(edge: .bottom, size: CGSize(width: 390, height: 844))

        #expect(layout.transitionOffset(cardHeight: 10) == ZenToastHost.Layout.estimatedCardHeight * 1.5)
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
