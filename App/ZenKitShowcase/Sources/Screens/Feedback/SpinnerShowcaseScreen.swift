import SwiftUI
import ZenKit

struct SpinnerShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Spinner") {
            ZenCard(title: "Sizes", subtitle: "Small, medium, and large") {
                HStack(spacing: ZenSpacing.large) {
                    ZenSpinner(size: .small)
                    ZenSpinner(size: .medium)
                    ZenSpinner(size: .large)
                }
            }

            ZenCard(title: "Tints", subtitle: "Custom and muted tints") {
                HStack(spacing: ZenSpacing.large) {
                    ZenSpinner()
                    ZenSpinner(tint: .zenTextMuted)
                    ZenSpinner(tint: .zenSuccess)
                    ZenSpinner(tint: .zenWarning)
                }
            }

            ZenCard(title: "Track", subtitle: "With and without track ring") {
                HStack(spacing: ZenSpacing.large) {
                    ZenSpinner(size: .large, showsTrack: true)
                    ZenSpinner(size: .large, showsTrack: false)
                }
            }

            ZenCard(title: "Loading View", subtitle: "Full loading state with title and message") {
                ZenLoading(title: "Preparing your session", message: "Restoring your secure session.")
                    .frame(height: 160)
            }
        }
    }
}
