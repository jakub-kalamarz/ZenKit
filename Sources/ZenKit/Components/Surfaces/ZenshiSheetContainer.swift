import SwiftUI

public struct ZenSheetContainer<ToolbarLeading: View, ToolbarTrailing: View, Content: View, Footer: View>: View {
    private let title: Text
    private let subtitle: Text?
    private let toolbarLeading: () -> ToolbarLeading
    private let toolbarTrailing: () -> ToolbarTrailing
    private let content: () -> Content
    private let footer: () -> Footer
    private let showsFooter: Bool
    private var scrollsContent = true

    init(
        storedTitle: Text,
        storedSubtitle: Text?,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer,
        showsFooter: Bool
    ) {
        self.title = storedTitle
        self.subtitle = storedSubtitle
        self.toolbarLeading = toolbarLeading
        self.toolbarTrailing = toolbarTrailing
        self.content = content
        self.footer = footer
        self.showsFooter = showsFooter
    }

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = Text(title)
        self.subtitle = subtitle.map { key in Text(key) }
        self.toolbarLeading = toolbarLeading
        self.toolbarTrailing = toolbarTrailing
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == EmptyView {
        self.title = Text(title)
        self.subtitle = subtitle.map { key in Text(key) }
        self.toolbarLeading = toolbarLeading
        self.toolbarTrailing = toolbarTrailing
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) where ToolbarLeading == EmptyView, Footer == EmptyView {
        self.title = Text(title)
        self.subtitle = subtitle.map { key in Text(key) }
        self.toolbarLeading = { EmptyView() }
        self.toolbarTrailing = toolbarTrailing
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
        self.title = Text(title)
        self.subtitle = subtitle.map { key in Text(key) }
        self.toolbarLeading = { EmptyView() }
        self.toolbarTrailing = { EmptyView() }
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
        self.title = Text(title)
        self.subtitle = subtitle.map(Text.init)
        self.toolbarLeading = { EmptyView() }
        self.toolbarTrailing = { EmptyView() }
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView, Footer == EmptyView {
        self.title = Text(title)
        self.subtitle = subtitle.map { key in Text(key) }
        self.toolbarLeading = { EmptyView() }
        self.toolbarTrailing = { EmptyView() }
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView, Footer == EmptyView {
        self.title = Text(title)
        self.subtitle = subtitle.map(Text.init)
        self.toolbarLeading = { EmptyView() }
        self.toolbarTrailing = { EmptyView() }
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: Text,
        subtitle: Text? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView, Footer == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.toolbarLeading = { EmptyView() }
        self.toolbarTrailing = { EmptyView() }
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public var body: some View {
        #if DEBUG
        #endif
        NavigationStack {
            if #available(iOS 26, macOS 26, *) {
                sheetContent
                    .safeAreaBar(edge: .bottom) {
                        if showsFooter {
                            footerBlock
                        }
                    }
            } else {
                sheetContent
                    .safeAreaInset(edge: .bottom) {
                        if showsFooter {
                            footerBlock
                                .background(Color.zenBackground)
                        }
                    }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var sheetContent: some View {
        scrollableContent
            .navigationTitle(title)
            .zenInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: ZenNavigationChrome.leadingToolbarPlacement) {
                    toolbarLeading()
                }
                ToolbarItem(placement: ZenNavigationChrome.trailingToolbarPlacement) {
                    toolbarTrailing()
                }
            }
            .zenBackground()
    }

    /// Content that manages its own scrolling (a web view, a list, a map) collapses to
    /// zero height inside the default `ScrollView`; this opts the sheet out of it.
    public func scrollsContent(_ scrolls: Bool) -> Self {
        var copy = self
        copy.scrollsContent = scrolls
        return copy
    }

    @ViewBuilder
    private var scrollableContent: some View {
        if scrollsContent {
            ScrollView {
                innerContent
            }
        } else {
            innerContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var innerContent: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            if let subtitle {
                subtitle
                    .font(.zen(.eyebrow, weight: .bold))
                    .foregroundStyle(Color.zenPrimary)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            content()
        }
        .padding(.horizontal, ZenSpacing.medium)
        .padding(.top, ZenSpacing.small)
        .padding(.bottom, ZenSpacing.small)
    }

    private var footerBlock: some View {
        VStack(spacing: 0) {
            footer()
                .padding(.horizontal, ZenSpacing.medium)
                .padding(.vertical, ZenSpacing.xSmall)
        }
    }
}

private extension View {
    @ViewBuilder
    func zenInlineNavigationTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

private struct ZenSheetContainerPreview: View {
    @State private var isPresented = false

    var body: some View {
        ZStack {
            Color.zenBackground.ignoresSafeArea()
            ZenButton("Open sheet") { isPresented = true }
        }
        .sheet(isPresented: $isPresented) {
            ZenSheetContainer(
                title: "Share workspace",
                subtitle: "Invite collaborators by email",
                toolbarLeading: {
                    ZenButton("Cancel", variant: .glass, size: .sm) {
                        isPresented = false
                    }
                },
                toolbarTrailing: {
                    ZenButton("Send", variant: .glassProminent, size: .sm) {}
                }
            ) {
                ZenFieldGroup {
                    ZenField(label: "Email", message: "We'll send them an invite") {
                        ZenTextInput(
                            text: .constant("new-teammate@example.com"),
                            prompt: "Email",
                            leadingIcon: .hugeIcon(.envelope)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Text titles

/// The container already stores its title as a `Text`; these hand one in directly, so a
/// sheet titled with the host's own content — a record's name — can use `Text(verbatim:)`
/// and skip the catalog. Every `LocalizedStringKey` and `String` initializer above wraps
/// its argument in a key, which looks the text up: a record named the same as one of the
/// host's strings came back translated.
public extension ZenSheetContainer {
    init(
        titleText: Text,
        subtitleText: Text? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            storedTitle: titleText,
            storedSubtitle: subtitleText,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content,
            footer: footer,
            showsFooter: true
        )
    }
}

public extension ZenSheetContainer where Footer == EmptyView {
    init(
        titleText: Text,
        subtitleText: Text? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            storedTitle: titleText,
            storedSubtitle: subtitleText,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content,
            footer: { EmptyView() },
            showsFooter: false
        )
    }
}

public extension ZenSheetContainer
where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView, Footer == EmptyView {
    init(
        titleText: Text,
        subtitleText: Text? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            storedTitle: titleText,
            storedSubtitle: subtitleText,
            toolbarLeading: { EmptyView() },
            toolbarTrailing: { EmptyView() },
            content: content,
            footer: { EmptyView() },
            showsFooter: false
        )
    }
}

#Preview {
    ZenSheetContainerPreview()
}

#Preview("Presented") {
    Color.zenBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ZenSheetContainer(
                title: "Share workspace",
                subtitle: "Invite collaborators by email",
                toolbarLeading: {
                    ZenButton("Cancel", variant: .glass, size: .sm) {}
                },
                toolbarTrailing: {
                    ZenButton("Send", variant: .glassProminent, size: .sm) {}
                }
            ) {
                ZenFieldGroup {
                    ZenField(label: "Email", message: "We'll send them an invite") {
                        ZenTextInput(
                            text: .constant("new-teammate@example.com"),
                            prompt: "Email",
                            leadingIcon: .hugeIcon(.envelope)
                        )
                    }
                }
            }
        }
}
