import SwiftUI
import ZenKit

struct AlertShowcaseScreen: View {
    @State private var showCritical = true
    @State private var showWarning = true
    @State private var showSuccess = true

    var body: some View {
        ShowcaseScreen(title: "Alert") {
            ZenCard(title: "Critical", subtitle: "Blocking error state") {
                VStack(spacing: ZenSpacing.small) {
                    ZenAlert(
                        tone: .critical,
                        message: "Invalid email or password. Please try again."
                    )
                    ZenAlert(
                        tone: .critical,
                        title: "Payment failed",
                        message: "Your card ending in 4242 was declined.",
                        action: ZenAlertAction("Update billing") {},
                        onDismiss: {}
                    )
                }
            }

            ZenCard(title: "Warning", subtitle: "Non-blocking notice") {
                VStack(spacing: ZenSpacing.small) {
                    ZenAlert(
                        tone: .warning,
                        message: "Your session will expire in 5 minutes."
                    )
                    ZenAlert(
                        tone: .warning,
                        title: "Storage almost full",
                        message: "You have used 90% of your storage quota.",
                        action: ZenAlertAction("Upgrade plan") {}
                    )
                }
            }

            ZenCard(title: "Success", subtitle: "Confirmation state") {
                VStack(spacing: ZenSpacing.small) {
                    ZenAlert(
                        tone: .success,
                        message: "Your changes have been saved successfully."
                    )
                    ZenAlert(
                        tone: .success,
                        title: "Account verified",
                        message: "You now have access to all features.",
                        onDismiss: {}
                    )
                }
            }
        }
    }
}
