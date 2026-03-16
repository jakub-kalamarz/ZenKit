import SwiftUI
import ZenKit

struct SettingsShowcaseScreen: View {
    @State private var language = "English"

    var body: some View {
        ShowcaseScreen(title: "Settings") {
            ZenCard(title: "Setting Row", subtitle: "Row with colored icon badge") {
                ZenSettingGroup {
                    ZenSettingRow(
                        title: "Account",
                        subtitle: "Manage your plan",
                        leadingIconSystemName: "person.crop.circle.fill",
                        iconColor: .blue,
                        accessory: .chevron
                    )
                    ZenSettingRow(
                        title: "Language",
                        subtitle: "Used for notifications",
                        leadingIconSystemName: "globe",
                        iconColor: .cyan
                    ) {
                        Text("English")
                    }
                    ZenSettingRow(
                        title: "Version",
                        leadingIconSystemName: "info.circle.fill",
                        iconColor: .gray
                    ) {
                        Text("1.0.0")
                    }
                }
            }

            ZenCard(title: "Picker Row", subtitle: "Inline menu picker for settings") {
                ZenPickerRow(
                    title: "Language",
                    subtitle: "Used for notifications",
                    leadingIconSystemName: "globe",
                    iconColor: .cyan,
                    selection: $language,
                    options: ["English", "Polish", "German", "French"]
                ) { option in
                    Text(option)
                }
            }

            ZenCard(title: "Rows Without Icon", subtitle: "Minimal rows without leading icon") {
                ZenSettingGroup {
                    ZenSettingRow(title: "Privacy Policy", accessory: .chevron)
                    ZenSettingRow(title: "Terms of Service", accessory: .chevron)
                    ZenSettingRow(title: "Help Center", accessory: .chevron)
                }
            }
        }
    }
}
