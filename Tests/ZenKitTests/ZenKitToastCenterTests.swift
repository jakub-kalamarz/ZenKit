import Foundation
import Testing
@testable import ZenKit

@MainActor
struct ZenKitToastCenterTests {
    @Test
    func dismissDefersQueuedPromotionToAllowExitAnimation() async {
        let center = ZenToastCenter(maxVisibleToasts: 2)

        let firstID = center.show("One", duration: nil)
        center.show("Two", duration: nil)
        center.show("Three", duration: nil)

        center.dismiss(firstID)

        #expect(center.visibleToasts.map(\.title) == ["Two"])
        #expect(center.queuedToasts.map(\.title) == ["Three"])

        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(center.visibleToasts.map(\.title) == ["Two"])
        #expect(center.queuedToasts.map(\.title) == ["Three"])

        await waitForQueuedPromotion(in: center)
        #expect(center.visibleToasts.map(\.title) == ["Two", "Three"])
        #expect(center.queuedToasts.isEmpty)
    }

    @Test
    func showAddsToastToVisibleStack() {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.show("Saved", message: "Your settings were updated.")

        #expect(center.visibleToasts.count == 1)
        #expect(center.visibleToasts.first?.id == id)
        #expect(center.visibleToasts.first?.title == "Saved")
        #expect(center.visibleToasts.first?.message == "Your settings were updated.")
        #expect(center.queuedToasts.isEmpty)
    }

    @Test
    func showQueuesItemsBeyondVisibleLimit() {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        center.show("One")
        center.show("Two")
        center.show("Three")
        let queuedID = center.show("Four")

        #expect(center.visibleToasts.map(\.title) == ["One", "Two", "Three"])
        #expect(center.queuedToasts.map(\.id) == [queuedID])
    }

    @Test
    func dismissEventuallyPromotesNextQueuedToast() async {
        let center = ZenToastCenter(maxVisibleToasts: 2)

        let firstID = center.show("One")
        center.show("Two")
        center.show("Three")

        center.dismiss(firstID)

        #expect(center.visibleToasts.map(\.title) == ["Two"])
        #expect(center.queuedToasts.map(\.title) == ["Three"])

        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(center.visibleToasts.map(\.title) == ["Two"])
        #expect(center.queuedToasts.map(\.title) == ["Three"])

        await waitForQueuedPromotion(in: center)
        #expect(center.visibleToasts.map(\.title) == ["Two", "Three"])
        #expect(center.queuedToasts.isEmpty)
    }

    @Test
    func dismissWithoutIdentifierClearsAllToasts() {
        let center = ZenToastCenter(maxVisibleToasts: 2)

        center.show("One")
        center.show("Two")
        center.show("Three")

        center.dismiss()

        #expect(center.visibleToasts.isEmpty)
        #expect(center.queuedToasts.isEmpty)
    }

    @Test
    func loadingToastsDoNotAutoDismiss() {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.loading("Syncing")

        #expect(center.visibleToasts.first?.id == id)
        #expect(center.visibleToasts.first?.duration == nil)
        #expect(center.visibleToasts.first?.tone == .loading)
    }

    @Test
    func showStoresOptionalProgressValue() {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.show("Uploading", message: "2 of 5 files", duration: nil, progress: 0.4)

        #expect(center.visibleToasts.first?.id == id)
        #expect(center.visibleToasts.first?.progress == 0.4)
    }

    @Test
    func updateChangesProgressInPlace() {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.loading("Uploading", message: "2 of 5 files", progress: 0.4)
        center.update(id, message: "4 of 5 files", progress: 0.8)

        #expect(center.visibleToasts.count == 1)
        #expect(center.visibleToasts.first?.id == id)
        #expect(center.visibleToasts.first?.message == "4 of 5 files")
        #expect(center.visibleToasts.first?.progress == 0.8)
    }

    @Test
    func updateReplacesExistingToastContentInPlace() {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.loading("Syncing", progress: 0.6)
        center.update(
            id,
            title: "Synced",
            message: "Everything is up to date.",
            tone: .success,
            duration: 2,
            progress: 1
        )

        #expect(center.visibleToasts.count == 1)
        #expect(center.visibleToasts.first?.id == id)
        #expect(center.visibleToasts.first?.title == "Synced")
        #expect(center.visibleToasts.first?.message == "Everything is up to date.")
        #expect(center.visibleToasts.first?.tone == .success)
        #expect(center.visibleToasts.first?.duration == 2)
        #expect(center.visibleToasts.first?.progress == 1)
    }

    @Test
    func pauseAutoDismissKeepsTimedToastVisiblePastOriginalDeadline() async {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.show("Saved", duration: 0.2)
        center.pauseAutoDismiss()

        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(center.visibleToasts.map(\.id) == [id])
    }

    @Test
    func resumeAutoDismissUsesRemainingTimeInsteadOfRestartingFullDuration() async {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.show("Saved", duration: 0.4)

        try? await Task.sleep(nanoseconds: 150_000_000)
        center.pauseAutoDismiss()

        try? await Task.sleep(nanoseconds: 350_000_000)
        #expect(center.visibleToasts.map(\.id) == [id])

        center.resumeAutoDismiss()

        try? await Task.sleep(nanoseconds: 120_000_000)
        #expect(center.visibleToasts.map(\.id) == [id])

        try? await Task.sleep(nanoseconds: 180_000_000)
        #expect(center.visibleToasts.isEmpty)
    }

    @Test
    func pauseAndResumeDoNotAffectPersistentToasts() async {
        let center = ZenToastCenter(maxVisibleToasts: 3)

        let id = center.loading("Syncing")
        center.pauseAutoDismiss()
        center.resumeAutoDismiss()

        try? await Task.sleep(nanoseconds: 300_000_000)

        #expect(center.visibleToasts.map(\.id) == [id])
        #expect(center.visibleToasts.first?.duration == nil)
    }

    private func waitForQueuedPromotion(
        in center: ZenToastCenter,
        timeoutNanoseconds: UInt64 = 400_000_000,
        pollIntervalNanoseconds: UInt64 = 20_000_000
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

        while DispatchTime.now().uptimeNanoseconds < deadline {
            if center.visibleToasts.map(\.title) == ["Two", "Three"], center.queuedToasts.isEmpty {
                return
            }

            try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
        }
    }
}
