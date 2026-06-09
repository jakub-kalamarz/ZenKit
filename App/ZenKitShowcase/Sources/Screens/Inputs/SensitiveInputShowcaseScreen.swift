import SwiftUI
import ZenKit

struct SensitiveInputShowcaseScreen: View {
    @State private var password = ""
    @State private var apiKey = "sk-proj-abc123def456"

    var body: some View {
        ShowcaseScreen(title: "Sensitive Input") {
            ZenCard(title: "Password", subtitle: "Toggle visibility with eye icon") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenSensitiveInput(text: $password, placeholder: "Enter password", label: "Password")
                    ZenSensitiveInput(text: $apiKey, placeholder: "API Key", label: "API Key")
                }
            }
        }
    }
}
