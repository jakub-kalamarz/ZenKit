import SwiftUI
import ZenKit

struct NavigationRowShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Navigation Row") {
            ZenCard(title: "With Icon Badge", subtitle: "Colored badge background with white icon") {
                VStack(spacing: ZenSpacing.small) {
                    ZenNavigationRow(
                        title: "Account",
                        subtitle: "Profile, email, and devices",
                        leadingIcon: .system("person.circle.fill"),
                        iconColor: .blue
                    )
                    ZenNavigationRow(
                        title: "Notifications",
                        subtitle: "Alerts and mentions",
                        leadingIcon: .system("bell.fill"),
                        iconColor: .red
                    )
                    ZenNavigationRow(
                        title: "Security",
                        subtitle: "Password and two-factor",
                        leadingIcon: .system("shield.fill"),
                        iconColor: .green
                    )
                }
            }

            ZenCard(title: "Without Icon", subtitle: "Plain title-only rows") {
                VStack(spacing: ZenSpacing.small) {
                    ZenNavigationRow(title: "Privacy Policy")
                    ZenNavigationRow(title: "Terms of Service")
                    ZenNavigationRow(title: "Help Center")
                }
            }

            ZenCard(title: "No Chevron", subtitle: "Rows without trailing accessory") {
                VStack(spacing: ZenSpacing.small) {
                    ZenNavigationRow(
                        title: "Notifications",
                        leadingIcon: .system("bell.fill"),
                        iconColor: .red,
                        accessory: .none
                    )
                    ZenNavigationRow(
                        title: "Appearance",
                        subtitle: "Theme and density",
                        leadingIcon: .system("paintpalette.fill"),
                        iconColor: .purple,
                        accessory: .none
                    )
                }
            }

            ZenCard(title: "Disabled", subtitle: "Inherited from SwiftUI disabled environment") {
                VStack(spacing: ZenSpacing.small) {
                    ZenNavigationRow(
                        title: "Billing",
                        subtitle: "Managed by workspace owner",
                        leadingIcon: .system("creditcard.fill"),
                        iconColor: .orange
                    )
                    .disabled(true)

                    ZenNavigationLink {
                        Text("Destination")
                    } label: {
                        ZenNavigationRow(
                            title: "Workspace Transfer",
                            subtitle: "Unavailable on trial plan",
                            leadingIcon: .system("arrow.left.arrow.right"),
                            iconColor: .indigo
                        )
                    }
                    .disabled(true)
                }
            }
        }
    }
}
