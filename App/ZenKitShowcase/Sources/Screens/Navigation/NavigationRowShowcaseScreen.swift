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
                        leadingIconSystemName: "person.circle.fill",
                        iconColor: .blue
                    )
                    ZenNavigationRow(
                        title: "Notifications",
                        subtitle: "Alerts and mentions",
                        leadingIconSystemName: "bell.fill",
                        iconColor: .red
                    )
                    ZenNavigationRow(
                        title: "Security",
                        subtitle: "Password and two-factor",
                        leadingIconSystemName: "shield.fill",
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
                        leadingIconSystemName: "bell.fill",
                        iconColor: .red,
                        accessory: .none
                    )
                    ZenNavigationRow(
                        title: "Appearance",
                        subtitle: "Theme and density",
                        leadingIconSystemName: "paintpalette.fill",
                        iconColor: .purple,
                        accessory: .none
                    )
                }
            }
        }
    }
}
