import SwiftUI
import ZenKit

struct ToggleShowcaseScreen: View {
    @State private var notifications = true
    @State private var marketing = false
    @State private var autoSave = true

    var body: some View {
        ShowcaseScreen(title: "Toggle") {
            ZenCard(title: "Basic", subtitle: "On and off states") {
                VStack(spacing: ZenSpacing.small) {
                    ZenToggle("Push notifications", isOn: $notifications)
                    ZenToggle("Marketing emails", isOn: $marketing)
                }
            }

            ZenCard(title: "With Subtitle", subtitle: "Toggle with descriptive helper text") {
                VStack(spacing: ZenSpacing.small) {
                    ZenToggle(
                        "Push notifications",
                        isOn: $notifications,
                        subtitle: "Alerts for mentions and approvals"
                    )
                    ZenToggle(
                        "Auto-save",
                        isOn: $autoSave,
                        subtitle: "Saves changes every 30 seconds"
                    )
                    ZenToggle(
                        "Marketing emails",
                        isOn: $marketing,
                        subtitle: "Product updates and release notes"
                    )
                }
            }
        }
    }
}
