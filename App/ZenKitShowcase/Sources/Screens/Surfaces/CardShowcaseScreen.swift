import SwiftUI
import ZenKit

struct CardShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Card") {
            ZenCard {
                ZenCardHeader(
                    title: "Notifications",
                    subtitle: "Manage delivery settings",
                    leadingIconSystemName: "bell.badge.fill",
                    iconColor: .red
                )
            }

            ZenCard {
                ZenCardHeader(
                    title: "Security",
                    subtitle: "Password and two-factor auth",
                    leadingIconSystemName: "shield.fill",
                    iconColor: .green
                )
            }

            ZenCard(title: "Basic Card", subtitle: "Title, subtitle, and content") {
                Text("Card content goes here.")
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextPrimary)
            }

            ZenCard(title: "With Footer", subtitle: "Includes a divider and footer action") {
                ZenInfoCard(title: "Plan", value: "Pro")
            } footer: {
                ZenInlineAction("Manage subscription") {}
            }

            ZenCard(title: "Info Card", subtitle: "Read-only value display") {
                VStack(spacing: ZenSpacing.small) {
                    ZenInfoCard(title: "Workspace", value: "zenshi-inc")
                    ZenInfoCard(title: "Session token", value: "tok_abc123def456ghi789", monospaced: true)
                }
            }

            ZenCard(title: "Collection Card", subtitle: "Titled group with optional badge") {
                ZenCollectionCard(title: "Recent Projects", subtitle: "3 items", badgeText: "New") {
                    VStack(spacing: ZenSpacing.xSmall) {
                        ForEach(["Zenshi iOS", "Design System", "API Gateway"], id: \.self) { item in
                            Text(item)
                                .font(.zenLabel)
                                .foregroundStyle(Color.zenTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.zenBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }
}
