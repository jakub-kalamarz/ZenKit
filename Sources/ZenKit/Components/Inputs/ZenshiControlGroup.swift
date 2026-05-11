import SwiftUI

public enum ZenControlGroupLayout: Equatable, Sendable {
    case horizontal
    case vertical
    case adaptive

    public func resolvedLayout(forWidth width: CGFloat?) -> Self {
        switch self {
        case .horizontal, .vertical:
            return self
        case .adaptive:
            guard let width else {
                return .horizontal
            }

            return width >= ZenControlGroupLayoutMetrics.adaptiveBreakpoint ? .horizontal : .vertical
        }
    }
}

public enum ZenControlGroupLayoutMetrics {
    public static let defaultSpacing = ZenSpacing.small
    public static let adaptiveBreakpoint: CGFloat = 320
}

private struct ZenControlGroupWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue() ?? value
    }
}

public struct ZenControlGroupStyle: ControlGroupStyle {
    private let layout: ZenControlGroupLayout
    private let spacing: CGFloat
    private let showsLabel: Bool

    public init(
        layout: ZenControlGroupLayout = .horizontal,
        spacing: CGFloat = ZenControlGroupLayoutMetrics.defaultSpacing,
        showsLabel: Bool = true
    ) {
        self.layout = layout
        self.spacing = spacing
        self.showsLabel = showsLabel
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            if showsLabel {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            groupContent(configuration.content)
        }
    }

    @ViewBuilder
    private func groupContent<C: View>(_ content: C) -> some View {
        switch layout {
        case .horizontal:
            HStack(spacing: spacing) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .vertical, .adaptive:
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

public struct ZenControlGroup<Content: View, Label: View>: View {
    private let layout: ZenControlGroupLayout
    private let spacing: CGFloat
    private let showsLabel: Bool
    private let content: () -> Content
    private let label: () -> Label

    @State private var availableWidth: CGFloat?

    public init(
        layout: ZenControlGroupLayout = .horizontal,
        spacing: CGFloat = ZenControlGroupLayoutMetrics.defaultSpacing,
        showsLabel: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.layout = layout
        self.spacing = spacing
        self.showsLabel = showsLabel
        self.content = content
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if showsLabel {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            groupContent(content())
        }
        .background(widthReader)
    }

    @ViewBuilder
    private func groupContent<C: View>(_ content: C) -> some View {
        #if os(iOS)
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                layoutContent(content)
            }
        } else {
            layoutContent(content)
        }
        #else
        layoutContent(content)
        #endif
    }

    @ViewBuilder
    private func layoutContent<C: View>(_ content: C) -> some View {
        switch layout.resolvedLayout(forWidth: availableWidth) {
        case .horizontal:
            HStack(spacing: spacing) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .vertical, .adaptive:
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var widthReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ZenControlGroupWidthPreferenceKey.self, value: proxy.size.width)
        }
        .onPreferenceChange(ZenControlGroupWidthPreferenceKey.self) { width in
            availableWidth = width
        }
    }
}

public extension ZenControlGroup where Label == EmptyView {
    init(
        layout: ZenControlGroupLayout = .horizontal,
        spacing: CGFloat = ZenControlGroupLayoutMetrics.defaultSpacing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(layout: layout, spacing: spacing, showsLabel: false, content: content) {
            EmptyView()
        }
    }
}

#Preview("Horizontal") {
    ZenControlGroup(layout: .horizontal) {
        ZenButton("Edit") {}
        ZenButton("Duplicate", variant: .secondary) {}
        ZenButton("Delete", variant: .ghost) {}
    } label: {
        Text("Actions")
    }
    .padding()
    .background(Color.zenBackground)
}

#Preview("Vertical") {
    ZenControlGroup(layout: .vertical) {
        ZenButton("Save draft", fullWidth: true) {}
        ZenButton("Publish", variant: .secondary, fullWidth: true) {}
    } label: {
        Text("Publishing")
    }
    .padding()
    .background(Color.zenBackground)
}
