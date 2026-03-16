import SwiftUI
import ZenKit

struct TimelineShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Timeline") {
            ZenCard(title: "Activity Feed", subtitle: "Task lifecycle events") {
                VStack(alignment: .leading, spacing: 0) {
                    ZenTimelineItem(
                        iconSystemName: "plus.circle.fill",
                        iconColor: Color.zenSuccess,
                        title: "Task created",
                        subtitle: "Created by Alex Johnson",
                        timestamp: "9:00 AM"
                    )

                    ZenTimelineItem(
                        iconSystemName: "pencil",
                        iconColor: Color.zenPrimary,
                        title: "Description updated",
                        subtitle: "Added acceptance criteria and edge cases",
                        timestamp: "10:34 AM"
                    )

                    ZenTimelineItem(
                        iconSystemName: "person.badge.plus",
                        iconColor: Color.zenWarning,
                        title: "Assigned to Sarah Chen",
                        timestamp: "11:15 AM"
                    )

                    ZenTimelineItem(
                        iconSystemName: "bubble.left",
                        iconColor: Color.zenTextMuted,
                        title: "Comment added",
                        subtitle: "\"Ready for review — see PR #412\"",
                        timestamp: "1:42 PM"
                    )

                    ZenTimelineItem(
                        iconSystemName: "checkmark.circle.fill",
                        iconColor: Color.zenSuccess,
                        title: "Marked as complete",
                        subtitle: "Closed by Sarah Chen",
                        timestamp: "2:52 PM",
                        isLast: true
                    )
                }
            }

            ZenCard(title: "Minimal", subtitle: "No subtitles or timestamps") {
                VStack(alignment: .leading, spacing: 0) {
                    ZenTimelineItem(iconSystemName: "envelope", iconColor: Color.zenPrimary, title: "Invited to workspace")
                    ZenTimelineItem(iconSystemName: "checkmark", iconColor: Color.zenSuccess, title: "Accepted invitation")
                    ZenTimelineItem(iconSystemName: "person.crop.circle", iconColor: Color.zenTextMuted, title: "Profile completed", isLast: true)
                }
            }
        }
    }
}
