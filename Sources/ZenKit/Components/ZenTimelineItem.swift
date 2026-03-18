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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(width: ZenTimelineIndicator.defaultSize, height: ZenTimelineIndicator.defaultSize)

                if showsSeparator {
                    separator
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: ZenTimelineIndicator.defaultSize)
            .frame(maxHeight: .infinity, alignment: .top)

            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                header
                content
            }
            .padding(.bottom, showsSeparator ? ZenSpacing.medium : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZenTimeline {
        ZenTimelineItem {
            ZenTimelineIndicator {
                ZenIcon(systemName: "plus.circle.fill", size: 12)
                    .font(.system(size: 12, weight: .medium))
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
            ZenTimelineIndicator {
                Text("2")
                    .font(.zenLabel)
            }
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle("Implementation")
                ZenTimelineDate("In Progress")
            }
        } content: {
            ZenTimelineContent {
                ZenCard {
                    VStack(alignment: .leading, spacing: ZenSpacing.small) {
                        ZenBadge("Build", tone: .warning)

                        Text("Timeline primitives are wired into the package and showcased with richer nested content.")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }
        }

        ZenTimelineItem(showsSeparator: false) {
            ZenTimelineIndicator {
                ZenIcon(systemName: "person.badge.plus", size: 12)
                    .font(.system(size: 12, weight: .medium))
            }
        } header: {
            ZenTimelineHeader {
                ZenTimelineTitle("Ready for QA")
                ZenTimelineDate("Queued")
            }
        } content: {
            ZenTimelineContent {
                Text("Final item hides the separator for a clean terminal state.")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
