import SwiftUI
import ZenKit

struct SectionShowcaseScreen: View {
    @State private var language = "English"

    var body: some View {
        ShowcaseScreen(title: "Section") {
            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                Text("Muted Group")
                    .font(.zenTitle)
                    .foregroundStyle(Color.zenTextPrimary)

                Text("Section acts as a softer container and holds stronger inner surfaces for rows and controls.")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }

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
                } subtitle: {
                    Text("Muted container with a single interactive surface inside.")
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

                    Text("Custom header content built without a dedicated string initializer")
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
                .textCase(nil)
                .padding(.horizontal, ZenSpacing.small)
                .padding(.top, ZenSpacing.small)
            }
        }
    }
}
