import SwiftUI

public struct ZenSheetContainer<ToolbarLeading: View, ToolbarTrailing: View, Content: View, Footer: View>: View {
    private static var navigationBarHeight: CGFloat { 56 }

    @Environment(\.zenSheetSizingCallback) private var sizingCallback
    @State private var footerHeight: CGFloat = 0

    private let title: Text
    private let subtitle: Text?
    private let toolbarLeading: () -> ToolbarLeading
    private let toolbarTrailing: () -> ToolbarTrailing
    private let content: () -> Content
    private let footer: () -> Footer
    private let showsFooter: Bool

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
        NavigationStack {
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
                .safeAreaInset(edge: .bottom) {
                    if showsFooter {
                        footerBlock
                    }
                }
                .zenBackground()
        }
        .presentationDragIndicator(.visible)
    }

    private var scrollableContent: some View {
        ScrollView {
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
            .padding(.bottom, ZenSpacing.large)
            .zenReadSize { size in
                let totalHeight = size.height + Self.navigationBarHeight + footerHeight
                sizingCallback?(CGSize(width: size.width, height: totalHeight))
            }
        }
    }

    private var footerBlock: some View {
        VStack(spacing: 0) {
            footer()
                .padding(.horizontal, ZenSpacing.medium)
                .padding(.vertical, ZenSpacing.small)
        }
        .background(Color.zenBackground)
        .zenReadSize { size in
            footerHeight = size.height
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
                            leadingIcon: .asset("Envelope", renderingMode: .template)
                        )
                    }
                }
            }
        }
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
                            leadingIcon: .asset("Envelope", renderingMode: .template)
                        )
                    }
                }
            }
        }
}
