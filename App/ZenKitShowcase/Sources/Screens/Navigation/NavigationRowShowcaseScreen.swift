import SwiftUI
import ZenKit

struct NavigationRowShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Navigation Row") {
            ZenCard(title: "Bare Icons", subtitle: "Kumo-style rows with plain icons and dividers") {
                VStack(spacing: 0) {
                    ZenNavigationRow(
                        title: "Account",
                        subtitle: "Profile, email, and devices",
                        leadingIcon: .system("person.circle")
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Notifications",
                        subtitle: "Alerts and mentions",
                        leadingIcon: .system("bell")
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Security",
                        subtitle: "Password and two-factor",
                        leadingIcon: .system("shield")
                    )
                }
            }

            ZenCard(title: "With Icon Badge", subtitle: "Colored badge background behind icon") {
                VStack(spacing: 0) {
                    ZenNavigationRow(
                        title: "Account",
                        subtitle: "Profile, email, and devices",
                        leadingIcon: .system("person.circle.fill"),
                        iconColor: .blue,
                        iconStyle: .badge
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Notifications",
                        subtitle: "Alerts and mentions",
                        leadingIcon: .system("bell.fill"),
                        iconColor: .red,
                        iconStyle: .badge
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Security",
                        subtitle: "Password and two-factor",
                        leadingIcon: .system("shield.fill"),
                        iconColor: .green,
                        iconStyle: .badge
                    )
                }
            }

            ZenCard(title: "With Trailing Content", subtitle: "Values, badges, or controls on the right") {
                VStack(spacing: 0) {
                    ZenNavigationRow(
                        title: "Language",
                        leadingIcon: .system("globe")
                    ) {
                        Text("English")
                    }
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Theme",
                        leadingIcon: .system("paintpalette")
                    ) {
                        Text("System")
                    }
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Storage",
                        leadingIcon: .system("internaldrive")
                    ) {
                        Text("4.2 GB")
                    }
                }
            }

            ZenCard(title: "Without Icon", subtitle: "Plain title-only rows") {
                VStack(spacing: 0) {
                    ZenNavigationRow(title: "Privacy Policy")
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(title: "Terms of Service")
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(title: "Help Center")
                }
            }

            ZenCard(title: "Disabled", subtitle: "Inherited from SwiftUI disabled environment") {
                VStack(spacing: 0) {
                    ZenNavigationRow(
                        title: "Billing",
                        subtitle: "Managed by workspace owner",
                        leadingIcon: .system("creditcard"),
                        iconColor: .orange
                    )
                    .disabled(true)
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Workspace Transfer",
                        subtitle: "Unavailable on trial plan",
                        leadingIcon: .system("arrow.left.arrow.right")
                    )
                    .disabled(true)
                }
            }
        }
    }
}
