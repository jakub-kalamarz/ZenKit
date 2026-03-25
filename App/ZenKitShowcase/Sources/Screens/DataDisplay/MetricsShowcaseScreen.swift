import SwiftUI
import ZenKit

struct MetricsShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Metrics") {
            ZenCard(title: "Metric Strip", subtitle: "2-column grid of key metrics") {
                ZenMetricStrip(values: [
                    ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent, iconSource: .asset("CursorClick")),
                    ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess, iconSource: .asset("ChartBar")),
                    ZenMetricValue(label: "CTR", value: "4%", iconSource: .system("percent")),
                    ZenMetricValue(label: "Position", value: "16", tint: .zenWarning, iconSource: .asset("TrendUp"))
                ])
            }

            ZenCard(title: "Comparison Metrics", subtitle: "Metrics with trend indicators") {
                ZenMetricStrip(values: [
                    ZenMetricValue(
                        label: "Revenue",
                        value: "$12.4K",
                        tint: .zenAccent,
                        iconSource: .system("dollarsign.circle"),
                        comparisonValue: "+12%",
                        trend: .up
                    ),
                    ZenMetricValue(
                        label: "Churn Rate",
                        value: "2.1%",
                        tint: .zenCritical,
                        iconSource: .system("person.badge.minus"),
                        comparisonValue: "+0.4%",
                        trend: .up,
                        comparisonLogic: .lessIsBetter
                    ),
                    ZenMetricValue(
                        label: "NPS",
                        value: "72",
                        tint: .zenSuccess,
                        iconSource: .system("heart"),
                        comparisonValue: "+4",
                        trend: .up
                    ),
                    ZenMetricValue(
                        label: "Latency",
                        value: "42ms",
                        tint: .zenWarning,
                        iconSource: .system("bolt"),
                        comparisonValue: "-12ms",
                        trend: .down,
                        comparisonLogic: .lessIsBetter
                    )
                ])
            }

            ZenCard(title: "Compact Metric Grid", subtitle: "2x2 icon and value tiles") {
                ZenMetricStrip(
                    values: [
                        ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent, iconSource: .asset("CursorClick")),
                        ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess, iconSource: .asset("ChartBar")),
                        ZenMetricValue(label: "CTR", value: "4%", iconSource: .system("percent")),
                        ZenMetricValue(label: "Position", value: "16", tint: .zenWarning, iconSource: .asset("TrendUp"))
                    ],
                    style: .compact,
                    layout: .grid(columns: 2)
                )
            }

            ZenCard(title: "Compact Metric Row", subtitle: "1x4 icon and value strip") {
                ZenMetricStrip(
                    values: [
                        ZenMetricValue(label: "Clicks", value: "694", tint: .zenAccent, iconSource: .asset("CursorClick")),
                        ZenMetricValue(label: "Impressions", value: "17.8K", tint: .zenSuccess, iconSource: .asset("ChartBar")),
                        ZenMetricValue(label: "CTR", value: "4%", iconSource: .system("percent")),
                        ZenMetricValue(label: "Position", value: "16", tint: .zenWarning, iconSource: .asset("TrendUp"))
                    ],
                    style: .compact,
                    layout: .row
                )
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
