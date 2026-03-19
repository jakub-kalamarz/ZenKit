import SwiftUI
import ZenKit

struct SectionShowcaseScreen: View {
    @State private var language = "English"

    var body: some View {
        ShowcaseScreen(title: "Section") {
            ZenCard(title: "Basic", subtitle: "Header, grouped body, and footer") {
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
            }

            ZenCard(title: "Header Only", subtitle: "Lighter section without footer copy") {
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
            }

            ZenCard(title: "Custom Header", subtitle: "Composable without string API") {
                ZenSection {
                    ZenSettingRow(title: "Privacy Policy", accessory: .chevron)
                    ZenSettingRow(title: "Terms of Service", accessory: .chevron)
                    ZenSettingRow(title: "Help Center", accessory: .chevron)
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Resources")
                            .font(.zenTitle)
                            .foregroundStyle(Color.zenTextPrimary)

                        Text("Custom header content built without a dedicated string initializer")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                    .textCase(nil)
                }
            }
        }
    }
}
