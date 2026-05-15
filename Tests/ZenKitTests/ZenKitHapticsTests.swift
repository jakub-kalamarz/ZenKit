import Testing
@testable import ZenKit

@Suite(.serialized)
struct ZenKitHapticsTests {
    @Test
    func standardHapticsMapSemanticEventsToRestrainedFeedback() {
        let haptics = ZenHaptics.standard

        #expect(haptics.enabled)
        #expect(haptics.feedback(for: .buttonPress) == .impact(.light))
        #expect(haptics.feedback(for: .selectionChange) == .selection)
        #expect(haptics.feedback(for: .toggleChange) == .impact(.light))
        #expect(haptics.feedback(for: .valueChange) == .selection)
        #expect(haptics.feedback(for: .limitReached) == .impact(.rigid))
        #expect(haptics.feedback(for: .validationError) == .notification(.error))
    }

    @Test
    func disabledHapticsSuppressAllSemanticFeedback() {
        let haptics = ZenHaptics(
            enabled: false,
            buttonPress: .impact(.heavy),
            selectionChange: .selection,
            toggleChange: .impact(.medium),
            valueChange: .selection,
            limitReached: .impact(.rigid),
            validationError: .notification(.error)
        )

        #expect(haptics.feedback(for: .buttonPress) == .none)
        #expect(haptics.feedback(for: .selectionChange) == .none)
        #expect(haptics.feedback(for: .toggleChange) == .none)
        #expect(haptics.feedback(for: .valueChange) == .none)
        #expect(haptics.feedback(for: .limitReached) == .none)
        #expect(haptics.feedback(for: .validationError) == .none)
    }

    @Test
    func offPresetSuppressesEngineOutput() {
        var performed: [ZenHapticFeedback] = []
        ZenHapticEngine.performOverride = { performed.append($0) }
        defer { ZenHapticEngine.performOverride = nil }

        ZenHapticEngine.perform(.buttonPress, haptics: .off)
        ZenHapticEngine.perform(.validationError, haptics: .off)

        #expect(performed.isEmpty)
    }

    @Test
    func engineRecordsResolvedSemanticFeedback() {
        var performed: [ZenHapticFeedback] = []
        ZenHapticEngine.performOverride = { performed.append($0) }
        defer { ZenHapticEngine.performOverride = nil }

        ZenHapticEngine.perform(.buttonPress, haptics: .standard)
        ZenHapticEngine.perform(.validationError, haptics: .standard)

        #expect(performed == [.impact(.light), .notification(.error)])
    }

    @Test
    func themeCarriesHapticPolicy() {
        let theme = ZenTheme(haptics: .reduced)

        #expect(theme.haptics == .reduced)
        #expect(theme.haptics.feedback(for: .buttonPress) == .none)
        #expect(theme.haptics.feedback(for: .validationError) == .notification(.error))
    }
}
