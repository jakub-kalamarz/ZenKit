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
                        color: Color.zenSuccess,
                        title: "Task created",
                        detail: "Created by Alex Johnson",
                        timestamp: "9:00 AM"
                    )

                    activityItem(
                        iconSystemName: "pencil",
                        color: Color.zenPrimary,
                        title: "Description updated",
                        detail: "Added acceptance criteria and edge cases",
                        timestamp: "10:34 AM"
                    )

                    activityItem(
                        iconSystemName: "person.badge.plus",
                        color: Color.zenWarning,
                        title: "Assigned to Sarah Chen",
                        detail: "Reviewer handoff completed",
                        timestamp: "11:15 AM"
                    )

                    activityItem(
                        iconSystemName: "bubble.left",
                        color: Color.zenTextMuted,
                        title: "Comment added",
                        detail: "\"Ready for review - see PR #412\"",
                        timestamp: "1:42 PM"
                    )

                    activityItem(
                        iconSystemName: "checkmark.circle.fill",
                        color: Color.zenSuccess,
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
                        stepColor: Color.zenPrimary,
                        title: "Discovery",
                        state: "Done",
                        summary: "Requirements captured and scoped with product.",
                        badge: ("Spec", .success)
                    )

                    pipelineItem(
                        step: "2",
                        stepColor: Color.zenWarning,
                        title: "Implementation",
                        state: "In Progress",
                        summary: "Timeline primitives are wired into the package and showcase.",
                        badge: ("Build", .warning)
                    )

                    pipelineItem(
                        step: "3",
                        stepColor: Color.zenTextMuted,
                        title: "Verification",
                        state: "Queued",
                        summary: "Run package tests and the iOS showcase build before release.",
                        badge: ("QA", .default),
                        showsSeparator: false
                    )
                }
            }
        }
    }

    private func activityItem(
        iconSystemName: String,
        color: Color,
        title: String,
        detail: String,
        timestamp: String,
        showsSeparator: Bool = true
    ) -> some View {
        ZenTimelineItem(showsSeparator: showsSeparator) {
            timelineGlyphIndicator(systemName: iconSystemName, color: color)
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
        stepColor: Color,
        title: String,
        state: String,
        summary: String,
        badge: (label: String, tone: ZenBadgeTone),
        showsSeparator: Bool = true
    ) -> some View {
        ZenTimelineItem(showsSeparator: showsSeparator) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(stepColor.opacity(0.14))

                Text(step)
                    .font(.zenLabel)
                    .foregroundStyle(stepColor)
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

    private func timelineGlyphIndicator(systemName: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))

            ZenIcon(systemName: systemName, size: 12)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(color)
        }
    }
}
