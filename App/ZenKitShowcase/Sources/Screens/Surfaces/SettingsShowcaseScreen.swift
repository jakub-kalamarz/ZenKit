import SwiftUI
import ZenKit

struct SettingsShowcaseScreen: View {
    @State private var language = "English"

    var body: some View {
        ZenListScreen(navigationTitle: "Settings") {
            ZenSection {
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
                    Text(language)
                }
                ZenSettingRow(
                    title: "Version",
                    leadingIconSystemName: "info.circle.fill",
                    iconColor: .gray
                ) {
                    Text("1.0.0")
                }
            } header: {
                ZenSectionHeader {
                    Text("Workspace")
                } subtitle: {
                    Text("Shared settings and access")
                }
            } footer: {
                ZenSectionFooter {
                    Text("Only admins can change billing details.")
                }
            }

            ZenSection {
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
            } header: {
                ZenSectionHeader {
                    Text("Preferences")
                }
            }

            ZenSection {
                ZenSettingRow(title: "Privacy Policy", accessory: .chevron)
                ZenSettingRow(title: "Terms of Service", accessory: .chevron)
                ZenSettingRow(title: "Help Center", accessory: .chevron)
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resources")
                        .font(.zenTitle)
                        .foregroundStyle(Color.zenTextPrimary)

                    Text("Custom header content without a dedicated string API")
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
                .textCase(nil)
            }
        }
    }
}
