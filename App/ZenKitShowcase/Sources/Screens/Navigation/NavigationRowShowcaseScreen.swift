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
                        leadingIcon: .hugeIcon(.personCircle)
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Notifications",
                        subtitle: "Alerts and mentions",
                        leadingIcon: .hugeIcon(.bell)
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Security",
                        subtitle: "Password and two-factor",
                        leadingIcon: .hugeIcon(.shield)
                    )
                }
            }

            ZenCard(title: "With Icon Badge", subtitle: "Colored badge background behind icon") {
                VStack(spacing: 0) {
                    ZenNavigationRow(
                        title: "Account",
                        subtitle: "Profile, email, and devices",
                        leadingIcon: .hugeIcon(.personCircleFill),
                        iconColor: .blue,
                        iconStyle: .badge
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Notifications",
                        subtitle: "Alerts and mentions",
                        leadingIcon: .hugeIcon(.bellFill),
                        iconColor: .red,
                        iconStyle: .badge
                    )
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Security",
                        subtitle: "Password and two-factor",
                        leadingIcon: .hugeIcon(.shieldFill),
                        iconColor: .green,
                        iconStyle: .badge
                    )
                }
            }

            ZenCard(title: "With Trailing Content", subtitle: "Values, badges, or controls on the right") {
                VStack(spacing: 0) {
                    ZenNavigationRow(
                        title: "Language",
                        leadingIcon: .hugeIcon(.globe)
                    ) {
                        Text("English")
                    }
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Theme",
                        leadingIcon: .hugeIcon(.paintpalette)
                    ) {
                        Text("System")
                    }
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Storage",
                        leadingIcon: .hugeIcon(.internaldrive)
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
                        leadingIcon: .hugeIcon(.creditcard),
                        iconColor: .orange
                    )
                    .disabled(true)
                    Divider().padding(.leading, ZenSpacing.medium)
                    ZenNavigationRow(
                        title: "Workspace Transfer",
                        subtitle: "Unavailable on trial plan",
                        leadingIcon: .hugeIcon(.arrowLeftArrowRight)
                    )
                    .disabled(true)
                }
            }
        }
    }
}
