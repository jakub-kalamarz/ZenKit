import SwiftUI
import ZenKit

struct PickerRowShowcaseScreen: View {
    @State private var language = "English"
    @State private var timezone = "UTC"

    var body: some View {
        ShowcaseScreen(title: "Picker Row") {
            ZenCard(title: "Basic Picker", subtitle: "Inline menu-driven selection") {
                VStack(spacing: ZenSpacing.small) {
                    ZenPickerRow(
                        title: "Language",
                        subtitle: "Used for notifications",
                        leadingIcon: .system("globe"),
                        selection: $language,
                        options: ["English", "Polish", "German", "French"]
                    ) { option in
                        Text(option)
                    }

                    ZenPickerRow(
                        title: "Timezone",
                        leadingIcon: .system("clock"),
                        selection: $timezone,
                        options: ["UTC", "GMT+1", "EST", "PST"]
                    ) { option in
                        Text(option)
                    }
                }
            }
        }
    }
}
