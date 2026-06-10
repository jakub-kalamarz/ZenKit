import SwiftUI
import ZenKit

struct MeterShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Meter") {
            ZenCard(title: "Basic", subtitle: "Displays percentage by default") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenMeter(value: 65, label: "Storage used")
                    ZenMeter(value: 15, label: "Memory usage")
                }
            }

            ZenCard(title: "Custom Value", subtitle: "Formatted value text instead of percentage") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenMeter(value: 75, label: "API requests", customValue: "750 / 1,000")
                    ZenMeter(value: 70, label: "Team members", customValue: "7 / 10")
                }
            }

            ZenCard(title: "Full & Hidden Value", subtitle: "100% reached and value hidden") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenMeter(value: 100, label: "Quota reached")
                    ZenMeter(value: 40, label: "Progress", showValue: false)
                }
            }

            ZenCard(title: "Custom Tint", subtitle: "Override indicator color") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenMeter(value: 80, label: "Upload progress", tint: .zenSuccess)
                    ZenMeter(value: 60, label: "Warning level", tint: .zenWarning)
                }
            }
        }
    }
}
