import SwiftUI

public struct ZenTimelineItem: View {
    private let iconSystemName: String
    private let iconColor: Color
    private let title: String
    private let subtitle: String?
    private let timestamp: String?
    private let isLast: Bool

    public init(
        iconSystemName: String,
        iconColor: Color = Color.zenTextMuted,
        title: String,
        subtitle: String? = nil,
        timestamp: String? = nil,
        isLast: Bool = false
    ) {
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
        self.isLast = isLast
    }

    public var body: some View {
        HStack(alignment: .top, spacing: ZenSpacing.small) {
            // Left column: dot + vertical line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 28, height: 28)

                    ZenIcon(systemName: iconSystemName, size: 12)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.zenBorder)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 2)
                }
            }

            // Right content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.zenLabel)
                        .foregroundStyle(Color.zenTextPrimary)

                    Spacer()

                    if let timestamp {
                        Text(timestamp)
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }

                if !isLast {
                    Spacer()
                        .frame(minHeight: ZenSpacing.medium)
                }
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
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
            title: "Assigned to Sarah",
            timestamp: "11:15 AM"
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
    .padding()
    .background(Color.zenBackground)
}
