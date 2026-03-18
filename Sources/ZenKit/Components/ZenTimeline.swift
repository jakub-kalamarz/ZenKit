import SwiftUI

public struct ZenTimeline<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
    }
}

public struct ZenTimelineHeader<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ZenSpacing.small) {
            content
        }
    }
}

public struct ZenTimelineIndicator<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

public struct ZenTimelineSeparator: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(Color.zenBorder)
            .frame(width: 1)
            .frame(maxHeight: .infinity)
    }
}

public struct ZenTimelineContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            content
        }
    }
}

public struct ZenTimelineTitle: View {
    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.zenLabel)
            .foregroundStyle(Color.zenTextPrimary)
    }
}

public struct ZenTimelineDate: View {
    private let value: String

    public init(_ value: String) {
        self.value = value
    }

    public var body: some View {
        Text(value)
            .font(.zenCaption)
            .foregroundStyle(Color.zenTextMuted)
    }
}
