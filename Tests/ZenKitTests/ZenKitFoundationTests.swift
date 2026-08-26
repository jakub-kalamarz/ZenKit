import Testing
import SwiftUI
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
    }

    @Test
    func progressBarClampsValuesIntoUnitInterval() {
        #expect(ZenProgressBar(progress: -1).progress == 0)
        #expect(ZenProgressBar(progress: 0.25).progress == 0.25)
        #expect(ZenProgressBar(progress: 3).progress == 1)
    }

    @Test
    func zenIconSupportsSystemSymbolRendering() {
        let view = ZenIcon(icon: .envelope, size: 18)
        let menuIcon = ZenMenuIcon(icon: .ellipsis)

        _ = view
        _ = menuIcon
    }

    @Test
    func shimmerProvidesThemeAwareDefaultGradient() {
        #expect(ZenShimmer.defaultGradient(for: .light).stops.count == 3)
        #expect(ZenShimmer.defaultGradient(for: .dark).stops.count == 3)
    }

    @Test
    func shimmerStillAcceptsCustomGradients() {
        let shimmer = ZenShimmer(gradient: Gradient(colors: [.clear, .white, .clear]), mode: .overlay())

        _ = shimmer
    }
}
