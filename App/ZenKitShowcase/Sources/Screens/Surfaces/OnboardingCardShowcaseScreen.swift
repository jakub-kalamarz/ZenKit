import SwiftUI
import ZenKit

struct OnboardingCardShowcaseScreen: View {
    @State private var showFeature = true
    @State private var showPermission = true

    var body: some View {
        ShowcaseScreen(title: "Onboarding Card") {
            ZenCard(title: "Full", subtitle: "Icon, title, message, actions, and dismiss") {
                ZenOnboardingCard(
                    iconSystemName: "sparkles",
                    iconColor: .purple,
                    title: "Introducing AI Suggestions",
                    message: "Automatically surface insights from your data. Works across all reports and dashboards.",
                    primaryAction: ZenOnboardingAction("Try it now") {},
                    secondaryAction: ZenOnboardingAction("Learn more") {},
                    onDismiss: {}
                )
            }

            ZenCard(title: "With Primary Action", subtitle: "Permission or opt-in prompt") {
                ZenOnboardingCard(
                    iconSystemName: "bell.badge.fill",
                    iconColor: .orange,
                    title: "Enable Notifications",
                    message: "Get alerted when a teammate mentions you or a task is assigned.",
                    primaryAction: ZenOnboardingAction("Enable") {}
                )
            }

            ZenCard(title: "Informational", subtitle: "No actions, no dismiss") {
                ZenOnboardingCard(
                    iconSystemName: "lock.shield.fill",
                    iconColor: .green,
                    title: "Your data is encrypted",
                    message: "All workspace data is encrypted at rest and in transit using AES-256."
                )
            }
        }
    }
}
