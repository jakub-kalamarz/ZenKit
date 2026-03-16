import SwiftUI
import ZenKit

struct FieldShowcaseScreen: View {
    @State private var email = "alex@example.com"
    @State private var name = "Alex"
    @State private var handle = "zen"

    var body: some View {
        ShowcaseScreen(title: "Field") {
            ZenCard(title: "Field with Label", subtitle: "Label above the input control") {
                ZenFieldGroup {
                    ZenField(label: "Email", message: "Used for account access") {
                        ZenTextInput(text: $email, prompt: "Email")
                    }
                    ZenField(label: "Display name", message: "Visible to teammates", state: .focused) {
                        ZenTextInput(text: $name, prompt: "Display name", state: .focused)
                    }
                }
            }

            ZenCard(title: "Validation States", subtitle: "Invalid and disabled field states") {
                ZenFieldGroup {
                    ZenField(
                        label: "Handle",
                        message: "This handle is already taken.",
                        state: .invalid
                    ) {
                        ZenTextInput(text: $handle, prompt: "Handle", state: .invalid)
                    }

                    ZenField(
                        label: "Email",
                        message: "Contact support to change your email.",
                        state: .disabled
                    ) {
                        ZenTextInput(text: .constant("readonly@example.com"), prompt: "Email", state: .disabled)
                    }
                }
            }

            ZenCard(title: "Field Section", subtitle: "Grouped fields with section title") {
                ZenFieldSection(
                    title: "Profile",
                    subtitle: "Update the details shown across your workspace"
                ) {
                    ZenFieldGroup {
                        ZenField(label: "Email") {
                            ZenTextInput(text: $email, prompt: "Email")
                        }
                        ZenField(label: "Display name") {
                            ZenTextInput(text: $name, prompt: "Display name")
                        }
                    }
                }
            }
        }
    }
}
