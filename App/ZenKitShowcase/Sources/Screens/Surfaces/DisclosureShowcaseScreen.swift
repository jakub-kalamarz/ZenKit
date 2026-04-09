import SwiftUI
import ZenKit

struct DisclosureShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Disclosure") {
            ZenCard(title: "Basic", subtitle: "Collapsible content sections") {
                VStack(spacing: ZenSpacing.small) {
                    ZenDisclosure("Getting Started") {
                        Text("Follow the quick-start guide to configure your workspace and invite your first team member.")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ZenDisclosure("Billing & Plans", isExpanded: true) {
                        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                            Text("Current plan: Pro")
                                .font(.zenLabel)
                                .foregroundStyle(Color.zenTextPrimary)
                            Text("Renews on April 1, 2026 · $29/month")
                                .font(.zenCaption)
                                .foregroundStyle(Color.zenTextMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            ZenCard(title: "With Icon", subtitle: "Leading icon variant") {
                VStack(spacing: ZenSpacing.small) {
                    ZenDisclosure(
                        "Advanced Settings",
                        subtitle: "Power user options",
                        leadingIcon: .system("gearshape.2")
                    ) {
                        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                            Text("API access: Enabled")
                                .font(.zenCaption)
                                .foregroundStyle(Color.zenTextMuted)
                            Text("Debug mode: Disabled")
                                .font(.zenCaption)
                                .foregroundStyle(Color.zenTextMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ZenDisclosure(
                        "Notifications",
                        subtitle: "Email and push alerts",
                        leadingIcon: .system("bell")
                    ) {
                        Text("All notifications are enabled. Tap to manage channels.")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
