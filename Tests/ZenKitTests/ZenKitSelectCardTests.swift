import SwiftUI
import Testing
@testable import ZenKit

@Suite
struct ZenKitSelectCardTests {
    @Test
    func selectCardTracksSelectedAccessibilityTraitState() {
        let selected = ZenSelectCard(title: "Pro", isSelected: true) {}
        let unselected = ZenSelectCard(title: "Free", isSelected: false) {}

        #expect(selected.appliesSelectedAccessibilityTrait)
        #expect(!unselected.appliesSelectedAccessibilityTrait)
    }

    @Test
    func selectCardResolvesAssetIconSource() {
        let assetIcon = ZenSelectCard(
            title: "Custom",
            leadingIconSource: .asset("Bell", renderingMode: .template),
            isSelected: false
        ) {}

        #expect(assetIcon.resolvedLeadingIconSource == .asset("Bell", renderingMode: .template))
    }

    @Test
    func selectCardUsesCompactLayoutWhenSubtitleIsMissing() {
        let compact = ZenSelectCard(
            title: "Add new payment method",
            leadingIconSource: .asset("Plus", renderingMode: .template),
            isSelected: false
        ) {}
        let full = ZenSelectCard(
            title: "Pro",
            subtitle: "For professionals and small teams.",
            isSelected: true
        ) {}

        #expect(compact.usesCompactLayout)
        #expect(!full.usesCompactLayout)
    }

    @Test
    func inlineVariantHidesSelectionIndicator() {
        let inline = ZenSelectCard(
            title: "Add new payment method",
            leadingIconSource: .asset("Plus", renderingMode: .template),
            variant: .inline,
            isSelected: false
        ) {}
        let card = ZenSelectCard(title: "Pro", isSelected: true) {}

        #expect(inline.hidesSelectionIndicator)
        #expect(!card.hidesSelectionIndicator)
    }
}
