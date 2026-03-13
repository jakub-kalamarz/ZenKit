import Combine
import Foundation
import SwiftUI

public typealias ZenToastID = UUID

public enum ZenToastTone: Sendable, Equatable {
    case `default`
    case success
    case error
    case loading
}

public struct ZenToastAction {
    public let label: String
    public let handler: @MainActor () -> Void

    public init(_ label: String, handler: @escaping @MainActor () -> Void) {
        self.label = label
        self.handler = handler
    }
}

public struct ZenToastItem: Identifiable {
    public let id: ZenToastID
    public var title: String
    public var message: String?
    public var tone: ZenToastTone
    public var duration: TimeInterval?
    public var progress: Double?
    public var action: ZenToastAction?
    public let createdAt: Date

    public init(
        id: ZenToastID = UUID(),
        title: String,
        message: String? = nil,
        tone: ZenToastTone = .default,
        duration: TimeInterval? = 4,
        progress: Double? = nil,
        action: ZenToastAction? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.tone = tone
        self.duration = duration
        self.progress = progress.map(Self.clampedProgressValue)
        self.action = action
        self.createdAt = createdAt
    }

    private static func clampedProgressValue(_ progress: Double) -> Double {
        min(max(progress, 0), 1)
    }
}

@MainActor
public final class ZenToastCenter: ObservableObject {
    public static let shared = ZenToastCenter()

    @Published public private(set) var visibleToasts: [ZenToastItem] = []
    @Published public private(set) var queuedToasts: [ZenToastItem] = []

    private let maxVisibleToasts: Int
    private let promotionDelayNanoseconds: UInt64 = 100_000_000
    private var dismissalTasks: [ZenToastID: Task<Void, Never>] = [:]
    private var dismissalDeadlines: [ZenToastID: Date] = [:]
    private var remainingDismissDurations: [ZenToastID: TimeInterval] = [:]
    private var queuedPromotionTask: Task<Void, Never>?
    private var isAutoDismissPaused = false

    public init(maxVisibleToasts: Int = 3) {
        self.maxVisibleToasts = maxVisibleToasts
    }

    @discardableResult
    public func show(
        _ title: String,
        message: String? = nil,
        tone: ZenToastTone = .default,
        duration: TimeInterval? = 4,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) -> ZenToastID {
        let toast = ZenToastItem(
            title: title,
            message: message,
            tone: tone,
            duration: tone == .loading ? nil : duration,
            progress: progress,
            action: action
        )
        append(toast)
        return toast.id
    }

    @discardableResult
    public func success(
        _ title: String,
        message: String? = nil,
        duration: TimeInterval? = 4,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) -> ZenToastID {
        show(title, message: message, tone: .success, duration: duration, progress: progress, action: action)
    }

    @discardableResult
    public func error(
        _ title: String,
        message: String? = nil,
        duration: TimeInterval? = 4,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) -> ZenToastID {
        show(title, message: message, tone: .error, duration: duration, progress: progress, action: action)
    }

    @discardableResult
    public func loading(
        _ title: String,
        message: String? = nil,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) -> ZenToastID {
        show(title, message: message, tone: .loading, duration: nil, progress: progress, action: action)
    }

    public func update(
        _ id: ZenToastID,
        title: String? = nil,
        message: String? = nil,
        tone: ZenToastTone? = nil,
        duration: TimeInterval? = nil,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) {
        if let index = visibleToasts.firstIndex(where: { $0.id == id }) {
            visibleToasts[index] = updatedToast(
                from: visibleToasts[index],
                title: title,
                message: message,
                tone: tone,
                duration: duration,
                progress: progress,
                action: action
            )
            remainingDismissDurations[id] = visibleToasts[index].duration
            scheduleDismissalIfNeeded(for: visibleToasts[index])
            return
        }

        if let index = queuedToasts.firstIndex(where: { $0.id == id }) {
            queuedToasts[index] = updatedToast(
                from: queuedToasts[index],
                title: title,
                message: message,
                tone: tone,
                duration: duration,
                progress: progress,
                action: action
            )
        }
    }

    public func dismiss(_ id: ZenToastID? = nil) {
        guard let id else {
            dismissalTasks.values.forEach { $0.cancel() }
            dismissalTasks.removeAll()
            dismissalDeadlines.removeAll()
            remainingDismissDurations.removeAll()
            queuedPromotionTask?.cancel()
            queuedPromotionTask = nil
            visibleToasts.removeAll()
            queuedToasts.removeAll()
            return
        }

        dismissToast(withID: id)
    }

    public func pauseAutoDismiss() {
        guard !isAutoDismissPaused else {
            return
        }

        isAutoDismissPaused = true

        for toast in visibleToasts where toast.duration != nil {
            pauseDismissal(for: toast.id)
        }
    }

    public func resumeAutoDismiss() {
        guard isAutoDismissPaused else {
            return
        }

        isAutoDismissPaused = false

        for toast in visibleToasts {
            scheduleDismissalIfNeeded(for: toast)
        }
    }

    private func append(_ toast: ZenToastItem) {
        if visibleToasts.count < maxVisibleToasts {
            visibleToasts.append(toast)
            remainingDismissDurations[toast.id] = toast.duration
            scheduleDismissalIfNeeded(for: toast)
        } else {
            queuedToasts.append(toast)
        }
    }

    private func dismissToast(withID id: ZenToastID) {
        dismissalTasks[id]?.cancel()
        dismissalTasks[id] = nil
        dismissalDeadlines[id] = nil
        remainingDismissDurations[id] = nil

        visibleToasts.removeAll { $0.id == id }
        queuedToasts.removeAll { $0.id == id }

        guard visibleToasts.count < maxVisibleToasts, !queuedToasts.isEmpty else {
            queuedPromotionTask?.cancel()
            queuedPromotionTask = nil
            return
        }

        queuedPromotionTask?.cancel()
        queuedPromotionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.promotionDelayNanoseconds)
            guard !Task.isCancelled else { return }
            self.promoteNextQueuedToastIfNeeded()
        }
    }

    private func promoteNextQueuedToastIfNeeded() {
        guard visibleToasts.count < maxVisibleToasts, !queuedToasts.isEmpty else {
            queuedPromotionTask = nil
            return
        }

        let next = queuedToasts.removeFirst()
        visibleToasts.append(next)
        remainingDismissDurations[next.id] = next.duration
        scheduleDismissalIfNeeded(for: next)
        queuedPromotionTask = nil
    }

    private func updatedToast(
        from toast: ZenToastItem,
        title: String?,
        message: String?,
        tone: ZenToastTone?,
        duration: TimeInterval?,
        progress: Double?,
        action: ZenToastAction?
    ) -> ZenToastItem {
        var updated = toast
        if let title {
            updated.title = title
        }
        if let message {
            updated.message = message
        }
        if let tone {
            updated.tone = tone
        }
        if let duration {
            updated.duration = duration
        } else if tone == .loading {
            updated.duration = nil
        }
        if let progress {
            updated.progress = min(max(progress, 0), 1)
        }
        if let action {
            updated.action = action
        }
        if updated.tone == .loading {
            updated.duration = nil
        }
        return updated
    }

    private func scheduleDismissalIfNeeded(for toast: ZenToastItem) {
        dismissalTasks[toast.id]?.cancel()
        dismissalTasks[toast.id] = nil

        guard let duration = toast.duration else {
            dismissalDeadlines[toast.id] = nil
            remainingDismissDurations[toast.id] = nil
            return
        }

        let remainingDuration = max(remainingDismissDurations[toast.id] ?? duration, 0)

        guard remainingDuration > 0 else {
            dismissalDeadlines[toast.id] = nil
            remainingDismissDurations[toast.id] = nil
            dismiss(toast.id)
            return
        }

        remainingDismissDurations[toast.id] = remainingDuration

        guard !isAutoDismissPaused else {
            dismissalDeadlines[toast.id] = nil
            return
        }

        dismissalDeadlines[toast.id] = Date().addingTimeInterval(remainingDuration)

        dismissalTasks[toast.id] = Task { [weak self] in
            let nanoseconds = UInt64(remainingDuration * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            self?.dismiss(toast.id)
        }
    }

    private func pauseDismissal(for id: ZenToastID) {
        dismissalTasks[id]?.cancel()
        dismissalTasks[id] = nil

        if let deadline = dismissalDeadlines[id] {
            remainingDismissDurations[id] = max(deadline.timeIntervalSinceNow, 0)
        }

        dismissalDeadlines[id] = nil
    }
}

@MainActor
public final class ZenToastClient {
    private let center: ZenToastCenter

    public init(center: ZenToastCenter) {
        self.center = center
    }

    @discardableResult
    public func callAsFunction(
        _ title: String,
        message: String? = nil,
        action: ZenToastAction? = nil,
        duration: TimeInterval? = 4,
        progress: Double? = nil
    ) -> ZenToastID {
        center.show(title, message: message, duration: duration, progress: progress, action: action)
    }

    @discardableResult
    public func success(
        _ title: String,
        message: String? = nil,
        action: ZenToastAction? = nil,
        duration: TimeInterval? = 4,
        progress: Double? = nil
    ) -> ZenToastID {
        center.success(title, message: message, duration: duration, progress: progress, action: action)
    }

    @discardableResult
    public func error(
        _ title: String,
        message: String? = nil,
        action: ZenToastAction? = nil,
        duration: TimeInterval? = 4,
        progress: Double? = nil
    ) -> ZenToastID {
        center.error(title, message: message, duration: duration, progress: progress, action: action)
    }

    @discardableResult
    public func loading(
        _ title: String,
        message: String? = nil,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) -> ZenToastID {
        center.loading(title, message: message, progress: progress, action: action)
    }

    public func update(
        _ id: ZenToastID,
        title: String? = nil,
        message: String? = nil,
        tone: ZenToastTone? = nil,
        duration: TimeInterval? = nil,
        progress: Double? = nil,
        action: ZenToastAction? = nil
    ) {
        center.update(id, title: title, message: message, tone: tone, duration: duration, progress: progress, action: action)
    }

    public func dismiss(_ id: ZenToastID? = nil) {
        center.dismiss(id)
    }
}

@MainActor
public let toast = ZenToastClient(center: .shared)

@MainActor
private func zenToastPreviewCenter() -> ZenToastCenter {
    let center = ZenToastCenter(maxVisibleToasts: 3)
    _ = center.success(
        "Saved changes",
        message: "Your workspace settings are up to date."
    )
    _ = center.loading(
        "Exporting previews",
        message: "Compressing assets",
        progress: 0.58,
        action: ZenToastAction("View queue", handler: {})
    )
    _ = center.error(
        "Sync failed",
        message: "Check your connection and try again."
    )
    return center
}

#Preview {
    ZStack {
        Color.zenBackground
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text("Toast state samples")
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            Text("Uses the shared toast models and center with a seeded host stack.")
                .font(.zenCaption)
                .foregroundStyle(Color.zenTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(ZenSpacing.large)

        ZenToastHost(center: zenToastPreviewCenter())
    }
}
