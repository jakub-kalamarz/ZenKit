import SwiftUI
import ZenKit

struct TimelineShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Timeline") {
            // Basic feed example: mirrors the previous activity-log use case.
            ZenCard(title: "Activity Feed", subtitle: "Simple updates built from the structural primitives") {
                ZenTimeline {
                    activityItem(
                        iconSystemName: "plus.circle.fill",
                        title: "Task created",
                        detail: "Created by Alex Johnson",
                        timestamp: "9:00 AM"
                    )

                    activityItem(
                        iconSystemName: "pencil",
                        title: "Description updated",
                        detail: "Added acceptance criteria and edge cases",
                        timestamp: "10:34 AM"
                    )

                    activityItem(
                        iconSystemName: "person.badge.plus",
                        title: "Assigned to Sarah Chen",
                        detail: "Reviewer handoff completed",
                        timestamp: "11:15 AM"
                    )

                    activityItem(
                        iconSystemName: "bubble.left",
                        title: "Comment added",
                        detail: "\"Ready for review - see PR #412\"",
                        timestamp: "1:42 PM"
                    )

                    activityItem(
                        iconSystemName: "checkmark.circle.fill",
                        title: "Marked as complete",
                        detail: "Closed by Sarah Chen",
                        timestamp: "2:52 PM",
                        showsSeparator: false
                    )
                }
            }

            // Advanced example: pipeline-like composition with custom indicators and card-like content.
            ZenCard(title: "Pipeline Layout", subtitle: "Custom indicators, badges, and richer step content") {
                ZenTimeline {
                    pipelineItem(
                        step: "1",
                        title: "Discovery",
                        state: "Done",
                        summary: "Requirements captured and scoped with product.",
                        badge: ("Spec", .success)
                    )

                    pipelineItem(
                        step: "2",
                        title: "Implementation",
                        state: "In Progress",
                        summary: "Timeline primitives are wired into the package and showcase.",
                        badge: ("Build", .warning)
                    )

                    pipelineItem(
                        step: "3",
                        title: "Verification",
                        state: "Queued",
                        summary: "Run package tests and the iOS showcase build before release.",
                        badge: ("QA", .neutral),
                        showsSeparator: false
                    )
                }
            }
        }
    }

    private func activityItem(
        iconSystemName: String,
        title: String,
        detail: String,
        timestamp: String,
        showsSeparator: Bool = true
    ) -> some View {
        ZenTimelineItem(showsSeparator: showsSeparator) {
            timelineGlyphIndicator(systemName: iconSystemName)
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle(title)
                ZenTimelineDate(timestamp)
            }
        } content: {
            ZenTimelineContent {
                Text(detail)
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }

    private func pipelineItem(
        step: String,
        title: String,
        state: String,
        summary: String,
        badge: (label: LocalizedStringKey, tone: ZenSemanticTone),
        showsSeparator: Bool = true
    ) -> some View {
        ZenTimelineItem(showsSeparator: showsSeparator) {
            ZenTimelineIndicator {
                Text(step)
                    .font(.zenLabel)
            }
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle(title)
                ZenTimelineDate(state)
            }
        } content: {
            ZenTimelineContent {
                ZenCard {
                    VStack(alignment: .leading, spacing: ZenSpacing.small) {
                        ZenBadge(badge.label, tone: badge.tone)
                        Text(summary)
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }
        }
    }

    private func timelineGlyphIndicator(systemName: String) -> some View {
        ZenTimelineIndicator {
            ZenIcon(systemName: systemName, size: 12)
                .font(.system(size: 12, weight: .medium))
        }
    }
}
