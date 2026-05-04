import SwiftUI
import ZenKit

struct TextInputShowcaseScreen: View {
    @State private var email = "alex@example.com"
    @State private var password = ""
    @State private var handle = "zen"
    @State private var message = ""
    @State private var draftedReply = "Let's ship the polished version."

    var body: some View {
        ShowcaseScreen(title: "Text Input") {
            ZenCard(title: "States", subtitle: "Normal, focused, invalid, and disabled") {
                VStack(spacing: ZenSpacing.small) {
                    ZenTextInput(text: $email, prompt: "Email")
                    ZenTextInput(text: $password, prompt: "Password", kind: .secure, state: .focused)
                    ZenTextInput(text: $handle, prompt: "Handle", state: .invalid, message: "This handle is already taken.")
                    ZenTextInput(text: .constant("readonly"), prompt: "Disabled", state: .disabled)
                }
            }

            ZenCard(title: "With Message", subtitle: "Helper and error text below the field") {
                VStack(spacing: ZenSpacing.small) {
                    ZenTextInput(text: $email, prompt: "Email", message: "Used for account access and notifications.")
                    ZenTextInput(text: .constant(""), prompt: "Confirm email", state: .invalid, message: "Emails do not match.")
                }
            }

            ZenCard(title: "Input Bar", subtitle: "Composer with click or Return-to-send behavior") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenInputBar(
                        text: $message,
                        prompt: "Ask anything...",
                        submitsOnReturn: true
                    ) {}

                    ZenInputBar(
                        text: $draftedReply,
                        prompt: "Reply...",
                        submitsOnReturn: true
                    ) {}

                    ZenInputBar(
                        text: .constant("Sending this reply"),
                        prompt: "Reply...",
                        isLoading: true
                    ) {}
                }
            }
        }
    }
}
