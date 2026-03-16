import SwiftUI
import ZenKit

struct BadgeShowcaseScreen: View {
    @State private var selectedTag = "Swift"

    var body: some View {
        ShowcaseScreen(title: "Badge") {
            ZenCard(title: "Tones", subtitle: "Neutral, success, warning, and critical") {
                HStack(spacing: ZenSpacing.small) {
                    ZenBadge("Draft")
                    ZenBadge("Synced", tone: .success)
                    ZenBadge("Review", tone: .warning)
                    ZenBadge("Failed", tone: .critical)
                }
            }

            ZenCard(title: "Selectable", subtitle: "Tap to toggle selection") {
                HStack(spacing: ZenSpacing.small) {
                    ZenBadge("Swift", isSelected: selectedTag == "Swift") {
                        selectedTag = "Swift"
                    }
                    ZenBadge("SwiftUI", isSelected: selectedTag == "SwiftUI") {
                        selectedTag = "SwiftUI"
                    }
                    ZenBadge("Xcode", isSelected: selectedTag == "Xcode") {
                        selectedTag = "Xcode"
                    }
                }
            }

            ZenCard(title: "Removable", subtitle: "Badge with remove button") {
                HStack(spacing: ZenSpacing.small) {
                    ZenBadge("Swift", onRemove: {})
                    ZenBadge("Design", tone: .warning, onRemove: {})
                    ZenBadge("iOS", tone: .success, onRemove: {})
                }
            }

            ZenCard(title: "Selectable + Removable", subtitle: "Combined action and remove") {
                HStack(spacing: ZenSpacing.small) {
                    ZenBadge("Design", tone: .warning, isSelected: true, action: {}, onRemove: {})
                    ZenBadge("Backend", isSelected: false, action: {}, onRemove: {})
                }
            }
        }
    }
}
