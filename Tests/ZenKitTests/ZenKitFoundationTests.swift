import Testing
@testable import ZenKit

struct ZenKitFoundationTests {
    @Test
    func initialsFormatterUsesFirstLettersForMultiWordNames() {
        #expect(InitialsFormatter.initials(for: "Alex Morgan") == "AM")
    }

    @Test
    func initialsFormatterFallsBackToFirstTwoCharacters() {
        #expect(InitialsFormatter.initials(for: "zen") == "ZE")
    }

    @Test
    func initialsFormatterUsesPlaceholderForEmptyInput() {
        #expect(InitialsFormatter.initials(for: "   ") == "?")
    }

    @Test
    func genericAccessibilityIdentifiersRemainStable() {
        #expect(ZenAccessibilityID.Toast.host == "toast.host")
        #expect(ZenAccessibilityID.Toast.closeButton == "toast.close")
        #expect(ZenAccessibilityID.ConfirmationDialog.confirmButton == "confirmation-dialog.confirm")
    }

    @Test
    func progressBarClampsValuesIntoUnitInterval() {
        #expect(ZenProgressBar(progress: -1).progress == 0)
        #expect(ZenProgressBar(progress: 0.25).progress == 0.25)
        #expect(ZenProgressBar(progress: 3).progress == 1)
    }

    @Test
    func zenIconSupportsSystemSymbolRendering() {
        let view = ZenIcon(systemName: "envelope", size: 18)
        let menuIcon = ZenMenuIcon(systemName: "ellipsis")

        _ = view
        _ = menuIcon
    }
}
