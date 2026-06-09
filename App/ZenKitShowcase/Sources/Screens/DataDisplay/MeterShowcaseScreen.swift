import SwiftUI
import ZenKit

struct MeterShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Meter") {
            ZenCard(title: "Basic", subtitle: "Progress with label and value") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenMeter(value: 42, total: 100, label: "API Requests")
                    ZenMeter(value: 7, total: 10, label: "Team Members")
                }
            }

            ZenCard(title: "Threshold Colors", subtitle: "Auto-colors at 75% and 90%") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenMeter(value: 50, total: 100, label: "Storage (50%)")
                    ZenMeter(value: 80, total: 100, label: "Storage (80%)")
                    ZenMeter(value: 95, total: 100, label: "Storage (95%)")
                }
            }

            ZenCard(title: "Custom Tint", subtitle: "Without value display") {
                ZenMeter(value: 0.6, label: "Upload progress", showValue: false, tint: .zenSuccess)
            }
        }
    }
}
