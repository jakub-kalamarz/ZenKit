import SwiftUI
import ZenKit

struct StatusBannerShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Status Banner") {
            ZenCard(title: "Tones", subtitle: "Critical, warning, and success") {
                VStack(spacing: ZenSpacing.small) {
                    ZenStatusBanner(tone: .critical, message: "Invalid email or password.")
                    ZenStatusBanner(tone: .warning, message: "Connection looks unstable.")
                    ZenStatusBanner(tone: .success, message: "Google account linked successfully.")
                }
            }

            ZenCard(title: "Longer Messages", subtitle: "Multi-line banner text wrapping") {
                VStack(spacing: ZenSpacing.small) {
                    ZenStatusBanner(
                        tone: .critical,
                        message: "Your session has expired. Please sign in again to continue."
                    )
                    ZenStatusBanner(
                        tone: .warning,
                        message: "Your plan is approaching its usage limit. Upgrade to avoid interruptions."
                    )
                }
            }
        }
    }
}
