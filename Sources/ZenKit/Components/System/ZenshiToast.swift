import Combine
import Foundation
import SwiftUI

public typealias ZenToastID = UUID

public enum ZenToastTone: Sendable, Equatable {
    case `default`
    case success
    case error
    case warning
    case info
    /// ZenKit extension over the reference toast set: pairs a spinner with an
    /// indefinite lifetime so progress work can own a toast until it resolves.
    case loading
}

public struct ZenToastAction: Identifiable {
    public let id: UUID
    public let label: String
    public let variant: ZenButtonVariant
    public let dismissesToast: Bool
    public let handler: @MainActor () -> Void

    public init(
        _ label: String,
        variant: ZenButtonVariant = .secondary,
        dismissesToast: Bool = true,
        handler: @escaping @MainActor () -> Void
    ) {
        self.id = UUID()
        self.label = label
        self.variant = variant
        self.dismissesToast = dismissesToast
        self.handler = handler
    }
}

/// Identity for a toast raised on someone else's behalf — a household member
/// checking items off a shared list, say. Rendered as the card's leading
/// element in place of the tone icon, so the reader sees *who* before *what*.
public struct ZenToastAvatar: Equatable, Sendable {
    public let name: String
    public let imageURL: URL?
    /// Small glyph pinned to the avatar's corner, saying what the person did
    /// without spending a second line of the card on it.
    public let badge: ZenToastAvatarBadge?

    public init(name: String, imageURL: URL? = nil, badge: ZenToastAvatarBadge? = nil) {
        self.name = name
        self.imageURL = imageURL
        self.badge = badge
    }
}

public enum ZenToastAvatarBadge: Equatable, Sendable {
    /// Animates on appear: the box starts in the opposite state and flips to
    /// `isChecked`, so the toast shows the action happening rather than
    /// reporting that it happened.
    case checkbox(isChecked: Bool)
    case icon(HugeIcon)

    public var tone: ZenToastTone {
        switch self {
        case .checkbox(let isChecked): isChecked ? .success : .default
        case .icon: .default
        }
    }
}

public struct ZenToastItem: Identifiable {
    /// Matches the reference toast's 5s timeout.
    public static let defaultDuration: TimeInterval = 5

    public let id: ZenToastID
    public var title: String
    public var message: String?
    public var tone: ZenToastTone
    public var duration: TimeInterval?
    public var progress: Double?
    public var actions: [ZenToastAction]
    public var avatar: ZenToastAvatar?
    public let createdAt: Date

    public init(
        id: ZenToastID = UUID(),
        title: String,
        message: String? = nil,
        tone: ZenToastTone = .default,
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil,
        actions: [ZenToastAction] = [],
        avatar: ZenToastAvatar? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.tone = tone
        self.duration = duration
        self.progress = progress.map(Self.clampedProgressValue)
        self.actions = actions
        self.avatar = avatar
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
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil,
        actions: [ZenToastAction] = [],
        avatar: ZenToastAvatar? = nil
    ) -> ZenToastID {
        let toast = ZenToastItem(
            title: title,
            message: message,
            tone: tone,
            duration: tone == .loading ? nil : duration,
            progress: progress,
            actions: actions,
            avatar: avatar
        )
        append(toast)
        return toast.id
    }

    /// A toast attributed to a person: neutral tone, their avatar where the tone
    /// icon would go.
    @discardableResult
    public func activity(
        _ title: String,
        message: String? = nil,
        avatar: ZenToastAvatar,
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        show(title, message: message, tone: .default, duration: duration, actions: actions, avatar: avatar)
    }

    @discardableResult
    public func success(
        _ title: String,
        message: String? = nil,
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        show(title, message: message, tone: .success, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func error(
        _ title: String,
        message: String? = nil,
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        show(title, message: message, tone: .error, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func warning(
        _ title: String,
        message: String? = nil,
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        show(title, message: message, tone: .warning, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func info(
        _ title: String,
        message: String? = nil,
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        show(title, message: message, tone: .info, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func loading(
        _ title: String,
        message: String? = nil,
        progress: Double? = nil,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        show(title, message: message, tone: .loading, duration: nil, progress: progress, actions: actions)
    }

    public func update(
        _ id: ZenToastID,
        title: String? = nil,
        message: String? = nil,
        tone: ZenToastTone? = nil,
        duration: TimeInterval? = nil,
        progress: Double? = nil,
        actions: [ZenToastAction]? = nil
    ) {
        if let index = visibleToasts.firstIndex(where: { $0.id == id }) {
            visibleToasts[index] = updatedToast(
                from: visibleToasts[index],
                title: title,
                message: message,
                tone: tone,
                duration: duration,
                progress: progress,
                actions: actions
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
                actions: actions
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
        actions: [ZenToastAction]?
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
        if let actions {
            updated.actions = actions
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
        actions: [ZenToastAction] = [],
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil
    ) -> ZenToastID {
        center.show(title, message: message, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func success(
        _ title: String,
        message: String? = nil,
        actions: [ZenToastAction] = [],
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil
    ) -> ZenToastID {
        center.success(title, message: message, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func error(
        _ title: String,
        message: String? = nil,
        actions: [ZenToastAction] = [],
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil
    ) -> ZenToastID {
        center.error(title, message: message, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func warning(
        _ title: String,
        message: String? = nil,
        actions: [ZenToastAction] = [],
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil
    ) -> ZenToastID {
        center.warning(title, message: message, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func info(
        _ title: String,
        message: String? = nil,
        actions: [ZenToastAction] = [],
        duration: TimeInterval? = ZenToastItem.defaultDuration,
        progress: Double? = nil
    ) -> ZenToastID {
        center.info(title, message: message, duration: duration, progress: progress, actions: actions)
    }

    @discardableResult
    public func loading(
        _ title: String,
        message: String? = nil,
        progress: Double? = nil,
        actions: [ZenToastAction] = []
    ) -> ZenToastID {
        center.loading(title, message: message, progress: progress, actions: actions)
    }

    public func update(
        _ id: ZenToastID,
        title: String? = nil,
        message: String? = nil,
        tone: ZenToastTone? = nil,
        duration: TimeInterval? = nil,
        progress: Double? = nil,
        actions: [ZenToastAction]? = nil
    ) {
        center.update(id, title: title, message: message, tone: tone, duration: duration, progress: progress, actions: actions)
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
        actions: [ZenToastAction("View queue", handler: {})]
    )
    _ = center.error(
        "Sync failed",
        message: "Check your connection and try again."
    )
    return center
}

#Preview("Toast center – seeded") {
    ZStack {
        Color.zenBackground
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text("Toast state samples")
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            Text("Uses the shared toast models and center with a seeded host stack.")
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(ZenSpacing.large)

        ZenToastHost(center: zenToastPreviewCenter())
    }
}

@MainActor
private func zenToastAutoDismissPreviewCenter() -> ZenToastCenter {
    let center = ZenToastCenter(maxVisibleToasts: 3)
    _ = center.info("Dismisses in 2s", message: "Short-lived confirmation.", duration: 2)
    _ = center.show("Dismisses in 5s", message: "The default timeout.")
    _ = center.loading("Never dismisses", message: "Loading toasts own their lifetime.")
    return center
}

#Preview("Toast center – auto dismiss") {
    ZStack {
        Color.zenBackground
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text("Auto-dismiss timing")
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            Text("Three lifetimes running live: 2s, the 5s default, and an indefinite loading toast.")
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(ZenSpacing.large)

        ZenToastHost(center: zenToastAutoDismissPreviewCenter())
    }
}
