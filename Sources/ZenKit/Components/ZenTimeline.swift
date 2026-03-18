import SwiftUI

public struct ZenTimeline: View {
    private let content: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
    }
}

public struct ZenTimelineHeader: View {
    private let content: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ZenSpacing.small) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct ZenTimelineIndicator: View {
    public static let defaultSize: CGFloat = 28

    private let content: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    public var body: some View {
        let style = ZenTimelineIndicatorResolvedStyle()

        return ZStack {
            Circle()
                .fill(style.backgroundColor)

            content
                .foregroundStyle(style.foregroundColor)
        }
        .frame(width: Self.defaultSize, height: Self.defaultSize)
    }
}

public struct ZenTimelineSeparator: View {
    public static let lineWidth: CGFloat = 1

    public init() {}

    public var body: some View {
        let style = ZenTimelineSeparatorResolvedStyle()

        Rectangle()
            .fill(style.color)
            .frame(width: Self.lineWidth)
            .frame(maxHeight: .infinity)
    }
}

struct ZenTimelineIndicatorResolvedStyle {
    let backgroundRole: ZenTimelineColorRole
    let foregroundRole: ZenTimelineColorRole

    var backgroundColor: Color { backgroundRole.color }
    var foregroundColor: Color { foregroundRole.color }

    init() {
        backgroundRole = .textPrimary
        foregroundRole = .background
    }
}

struct ZenTimelineSeparatorResolvedStyle {
    let colorRole: ZenTimelineColorRole

    var color: Color { colorRole.color }

    init() {
        colorRole = .textPrimary
    }
}

enum ZenTimelineColorRole {
    case background
    case primary
    case textPrimary

    var color: Color {
        switch self {
        case .background:
            return .zenBackground
        case .primary:
            return .zenPrimary
        case .textPrimary:
            return .zenTextPrimary
        }
    }
}

public struct ZenTimelineContent: View {
    private let content: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            .frame(maxWidth: .infinity, alignment: .leading)
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
