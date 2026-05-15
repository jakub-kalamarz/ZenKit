import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum ZenHapticImpact: Equatable, Sendable {
    case light
    case medium
    case heavy
    case soft
    case rigid
}

public enum ZenHapticNotification: Equatable, Sendable {
    case success
    case warning
    case error
}

public enum ZenHapticFeedback: Equatable, Sendable {
    case none
    case selection
    case impact(ZenHapticImpact)
    case notification(ZenHapticNotification)
}

public struct ZenHaptics: Equatable, Sendable {
    public let enabled: Bool
    public let buttonPress: ZenHapticFeedback
    public let selectionChange: ZenHapticFeedback
    public let toggleChange: ZenHapticFeedback
    public let valueChange: ZenHapticFeedback
    public let limitReached: ZenHapticFeedback
    public let validationError: ZenHapticFeedback

    public init(
        enabled: Bool = true,
        buttonPress: ZenHapticFeedback = .impact(.light),
        selectionChange: ZenHapticFeedback = .selection,
        toggleChange: ZenHapticFeedback = .impact(.light),
        valueChange: ZenHapticFeedback = .selection,
        limitReached: ZenHapticFeedback = .impact(.rigid),
        validationError: ZenHapticFeedback = .notification(.error)
    ) {
        self.enabled = enabled
        self.buttonPress = buttonPress
        self.selectionChange = selectionChange
        self.toggleChange = toggleChange
        self.valueChange = valueChange
        self.limitReached = limitReached
        self.validationError = validationError
    }

    public static let standard = ZenHaptics()

    public static let reduced = ZenHaptics(
        buttonPress: .none,
        selectionChange: .none,
        toggleChange: .selection,
        valueChange: .none,
        limitReached: .none,
        validationError: .notification(.error)
    )

    public static let off = ZenHaptics(
        enabled: false,
        buttonPress: .none,
        selectionChange: .none,
        toggleChange: .none,
        valueChange: .none,
        limitReached: .none,
        validationError: .none
    )
}

enum ZenHapticEvent: Equatable, Sendable {
    case buttonPress
    case selectionChange
    case toggleChange
    case valueChange
    case limitReached
    case validationError
}

extension ZenHaptics {
    func feedback(for event: ZenHapticEvent) -> ZenHapticFeedback {
        guard enabled else { return .none }

        switch event {
        case .buttonPress:
            return buttonPress
        case .selectionChange:
            return selectionChange
        case .toggleChange:
            return toggleChange
        case .valueChange:
            return valueChange
        case .limitReached:
            return limitReached
        case .validationError:
            return validationError
        }
    }
}

private struct ZenHapticsOverrideKey: EnvironmentKey {
    static let defaultValue: ZenHaptics? = nil
}

extension EnvironmentValues {
    var zenHapticsOverride: ZenHaptics? {
        get { self[ZenHapticsOverrideKey.self] }
        set { self[ZenHapticsOverrideKey.self] = newValue }
    }
}

public extension View {
    func zenHaptics(_ haptics: ZenHaptics) -> some View {
        environment(\.zenHapticsOverride, haptics)
    }
}

enum ZenHapticEngine {
    static var performOverride: ((ZenHapticFeedback) -> Void)?

    static func perform(_ event: ZenHapticEvent, haptics: ZenHaptics? = nil) {
        perform((haptics ?? ZenTheme.current.haptics).feedback(for: event))
    }

    static func perform(_ feedback: ZenHapticFeedback) {
        guard feedback != .none else { return }

        if let performOverride {
            performOverride(feedback)
            return
        }

        performPlatformFeedback(feedback)
    }

    private static func performPlatformFeedback(_ feedback: ZenHapticFeedback) {
#if canImport(UIKit)
        switch feedback {
        case .none:
            break
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .impact(let impact):
            UIImpactFeedbackGenerator(style: impact.uiImpactStyle).impactOccurred()
        case .notification(let notification):
            UINotificationFeedbackGenerator().notificationOccurred(notification.uiNotificationType)
        }
#elseif canImport(AppKit)
        switch feedback {
        case .none:
            break
        case .selection, .impact:
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        case .notification(let notification):
            NSHapticFeedbackManager.defaultPerformer.perform(notification.nsHapticPattern, performanceTime: .default)
        }
#endif
    }
}

#if canImport(UIKit)
private extension ZenHapticImpact {
    var uiImpactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        case .soft:
            return .soft
        case .rigid:
            return .rigid
        }
    }
}

private extension ZenHapticNotification {
    var uiNotificationType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success:
            return .success
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}
#elseif canImport(AppKit)
private extension ZenHapticNotification {
    var nsHapticPattern: NSHapticFeedbackManager.FeedbackPattern {
        switch self {
        case .success:
            return .alignment
        case .warning, .error:
            return .levelChange
        }
    }
}
#endif
