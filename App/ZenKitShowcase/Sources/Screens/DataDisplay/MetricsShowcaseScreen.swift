import SwiftUI
import ZenKit

struct MetricsShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Metrics") {
            ZenCard(title: "Metric Strip", subtitle: "2-column grid of key metrics") {
                ZenMetricStrip(values: [
                    ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent),
                    ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess),
                    ZenMetricValue(label: "CTR", value: "4%"),
                    ZenMetricValue(label: "Position", value: "16", tint: .zenWarning)
                ])
            }

            ZenCard(title: "Stat Row", subtitle: "Ranked list row with metrics") {
                VStack(spacing: 0) {
                    Divider()
                    ZenStatRow(
                        title: "Zenshi iOS",
                        subtitle: "Mobile app",
                        metrics: [
                            ZenMetricValue(label: "Stars", value: "4.9"),
                            ZenMetricValue(label: "DL", value: "12K", tint: .zenSuccess)
                        ]
                    )
                    Divider()
                    ZenStatRow(
                        title: "Design System",
                        subtitle: "Component library",
                        metrics: [
                            ZenMetricValue(label: "Stars", value: "4.7"),
                            ZenMetricValue(label: "DL", value: "8.2K")
                        ]
                    )
                    Divider()
                    ZenStatRow(
                        title: "API Gateway",
                        subtitle: "Backend service",
                        metrics: [
                            ZenMetricValue(label: "Uptime", value: "99.9%", tint: .zenSuccess),
                            ZenMetricValue(label: "p99", value: "42ms")
                        ]
                    )
                    Divider()
                }
            }
        }
    }
}
