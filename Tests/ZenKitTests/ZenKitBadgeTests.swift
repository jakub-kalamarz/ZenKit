import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitBadgeTests {
    @Test
    func badgeInitializersWorkWithNewParameters() {
        // Basic
        _ = ZenBadge("Test", iconSource: .hugeIcon(.star), tint: .red)
        
        // Selectable
        _ = ZenBadge("Selectable", isSelected: true, iconSource: .hugeIcon(.heart), tint: .blue) {
            // Action
        }
        
        // Removable
        _ = ZenBadge("Removable", iconSource: .hugeIcon(.lock), tint: .green) {
            // On remove
        }
        
        // Selectable + Removable
        _ = ZenBadge("Both", isSelected: false, iconSource: .hugeIcon(.person), tint: .purple, action: {}, onRemove: {})
    }
    
    @Test
    func badgeHandlesIconSource() {
        let badge = ZenBadge("Icon", iconSource: .hugeIcon(.appleLogo))
        // We can't easily inspect private properties of a View in Swift Testing without reflection
        // but we verify it compiles and initializes.
        _ = badge
    }
    
    @Test
    func badgeHandlesTint() {
        let badge = ZenBadge("Tint", tint: .orange)
        _ = badge
    }

    @Test
    func removableBadgeMetricsStayFixedForCompactChips() {
        #expect(ZenBadgeStyleMetrics.removeButtonWidth == 24)
        #expect(ZenBadgeStyleMetrics.height == 28)
        #expect(ZenBadgeStyleMetrics.smallHeight == 20)
        #expect(ZenBadgeStyleMetrics.removeIconSize == 10)
    }
}
