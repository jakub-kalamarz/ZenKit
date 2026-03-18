import SwiftUI

public struct ZenTimelineItem: View {
    private let showsSeparator: Bool
    private let indicator: AnyView
    private let header: AnyView
    private let separator: AnyView
    private let content: AnyView

    public init<Indicator: View, Header: View, Content: View>(
        showsSeparator: Bool = true,
        @ViewBuilder indicator: () -> Indicator,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            showsSeparator: showsSeparator,
            indicator: indicator,
            header: header,
            separator: { ZenTimelineSeparator() },
            content: content
        )
    }

    public init<Indicator: View, Header: View, Separator: View, Content: View>(
        showsSeparator: Bool = true,
        @ViewBuilder indicator: () -> Indicator,
        @ViewBuilder header: () -> Header,
        @ViewBuilder separator: () -> Separator,
        @ViewBuilder content: () -> Content
    ) {
        self.showsSeparator = showsSeparator
        self.indicator = AnyView(indicator())
        self.header = AnyView(header())
        self.separator = AnyView(separator())
        self.content = AnyView(content())
    }

    public var body: some View {
        HStack(alignment: .top, spacing: ZenSpacing.small) {
            VStack(spacing: 0) {
                indicator
                    .frame(width: ZenTimelineIndicator.defaultSize, height: ZenTimelineIndicator.defaultSize)

                if showsSeparator {
                    separator
                        .padding(.top, 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: ZenTimelineIndicator.defaultSize)
            .frame(maxHeight: .infinity, alignment: .top)

            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                header
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZenTimeline {
        ZenTimelineItem {
            ZStack {
                Circle()
                    .fill(Color.zenSuccess.opacity(0.15))

                ZenIcon(systemName: "plus.circle.fill", size: 12)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.zenSuccess)
            }
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle("Task created")
                ZenTimelineDate("9:00 AM")
            }
        } content: {
            ZenTimelineContent {
                Text("Created by Alex Johnson")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }

        ZenTimelineItem {
            ZStack {
                Circle()
                    .fill(Color.zenPrimary.opacity(0.15))

                ZenIcon(systemName: "pencil", size: 12)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.zenPrimary)
            }
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle("Description updated")
                ZenTimelineDate("10:34 AM")
            }
        } content: {
            ZenTimelineContent {
                Text("Added acceptance criteria and edge cases")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }

        ZenTimelineItem(showsSeparator: false) {
            ZStack {
                Circle()
                    .fill(Color.zenWarning.opacity(0.15))

                ZenIcon(systemName: "person.badge.plus", size: 12)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.zenWarning)
            }
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle("Assigned to Sarah")
                ZenTimelineDate("11:15 AM")
            }
        } content: {
            ZenTimelineContent { EmptyView() }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
