import SwiftUI
import ZenKit

struct LabelShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Label") {
            ZenCard(title: "Basic", subtitle: "Standard form labels") {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenLabel("Email address")
                    ZenLabel("Password", isRequired: true)
                    ZenLabel("Nickname", isOptional: true)
                }
            }

            ZenCard(title: "With Tooltip", subtitle: "Label with info icon") {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenLabel("API Key", tooltip: "Your unique API key for authentication")
                    ZenLabel("Webhook URL", isRequired: true, tooltip: "The endpoint that will receive events")
                }
            }
        }
    }
}
