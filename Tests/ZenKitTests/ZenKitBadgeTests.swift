import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitBadgeTests {
    @Test
    func badgeInitializersWorkWithNewParameters() {
        // Basic
        _ = ZenBadge("Test", iconSource: .system("star"), tint: .red)
        
        // Selectable
        _ = ZenBadge("Selectable", isSelected: true, iconSource: .system("heart"), tint: .blue) {
            // Action
        }
        
        // Removable
        _ = ZenBadge("Removable", iconSource: .system("lock"), tint: .green) {
            // On remove
        }
        
        // Selectable + Removable
        _ = ZenBadge("Both", isSelected: false, iconSource: .system("person"), tint: .purple, action: {}, onRemove: {})
    }
    
    @Test
    func badgeHandlesIconSource() {
        let badge = ZenBadge("Icon", iconSource: .system("apple.logo"))
        // We can't easily inspect private properties of a View in Swift Testing without reflection
        // but we verify it compiles and initializes.
        _ = badge
    }
    
    @Test
    func badgeHandlesTint() {
        let badge = ZenBadge("Tint", tint: .orange)
        _ = badge
    }
}
