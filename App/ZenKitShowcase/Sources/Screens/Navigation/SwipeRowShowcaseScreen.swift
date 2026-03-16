import SwiftUI
import ZenKit

struct SwipeRowShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Swipe Row") {
            ZenCard(title: "Archive & Delete", subtitle: "Two trailing actions") {
                VStack(spacing: ZenSpacing.small) {
                    ZenSwipeRow(
                        trailingActions: [
                            ZenSwipeAction(label: "Archive", systemIconName: "archivebox", tint: .zenWarning) {},
                            ZenSwipeAction(label: "Delete", systemIconName: "trash", tint: .zenCritical) {}
                        ]
                    ) {
                        ZenNavigationRow(title: "Sprint Planning", subtitle: "Weekly team sync", accessory: .none)
                    }

                    ZenSwipeRow(
                        trailingActions: [
                            ZenSwipeAction(label: "Archive", systemIconName: "archivebox", tint: .zenWarning) {},
                            ZenSwipeAction(label: "Delete", systemIconName: "trash", tint: .zenCritical) {}
                        ]
                    ) {
                        ZenNavigationRow(title: "Design Review", subtitle: "Component audit session", accessory: .none)
                    }
                }
            }

            ZenCard(title: "Single Action", subtitle: "One trailing action") {
                VStack(spacing: ZenSpacing.small) {
                    ZenSwipeRow(
                        trailingActions: [
                            ZenSwipeAction(label: "Delete", systemIconName: "trash", tint: .zenCritical) {}
                        ]
                    ) {
                        ZenNavigationRow(title: "Workspace invite", subtitle: "alex@example.com", accessory: .none)
                    }

                    ZenSwipeRow(
                        trailingActions: [
                            ZenSwipeAction(label: "Mute", systemIconName: "bell.slash", tint: Color.zenTextMuted) {}
                        ]
                    ) {
                        ZenNavigationRow(title: "Product updates", subtitle: "Weekly digest", accessory: .none)
                    }
                }
            }
        }
    }
}
