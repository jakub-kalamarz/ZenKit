import SwiftUI
import ZenKit

struct ButtonShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Buttons") {
            ZenCard(
                title: "Variants",
                subtitle: "Primary actions and secondary emphasis"
            ) {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenButton("Default") {}
                    ZenButton("Outline", variant: .outline) {}
                    ZenButton("Secondary", variant: .secondary) {}
                    ZenButton("Ghost", variant: .ghost) {}
                    ZenButton("Destructive", variant: .destructive) {}
                }
            }

            ZenCard(
                title: "States",
                subtitle: "Loading, disabled and sizing checks"
            ) {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenButton("Saving", isLoading: true) {}
                    ZenButton("Disabled") {}
                        .disabled(true)
                    ZenButton("Large", size: .lg) {}
                    ZenButton("Full Width", fullWidth: true) {}
                }
            }
        }
    }
}
