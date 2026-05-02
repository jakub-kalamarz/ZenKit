import SwiftUI

public enum ZenScreenContainerStyle: Sendable {
    case scroll
    case list
    case `static`
}

public struct ZenScreen<Header: View, ToolbarLeading: View, ToolbarPrincipal: View, ToolbarTrailing: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.zenScreenNavigationContext) private var navigationContext

    private let containerStyle: ZenScreenContainerStyle
    private let navigationTitle: ZenScreenTitle?
    private let navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode
    private let hidesSharedToolbarBackground: Bool
    private let ignoresTopSafeArea: Bool
    private let backButton: ZenScreenBackButton?
    private let onRefresh: (@Sendable () async -> Void)?
    private let onScroll: ((CGFloat) -> Void)?
    private let header: (() -> Header)?
    private let toolbarLeading: (() -> ToolbarLeading)?
    private let toolbarPrincipal: (() -> ToolbarPrincipal)?
    private let toolbarTrailing: (() -> ToolbarTrailing)?
    private let content: () -> Content

    public init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        onScroll: ((CGFloat) -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.containerStyle = containerStyle
        self.navigationTitle = navigationTitle
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
        self.hidesSharedToolbarBackground = hidesSharedToolbarBackground
        self.ignoresTopSafeArea = ignoresTopSafeArea
        self.backButton = backButton
        self.onRefresh = onRefresh
        self.onScroll = onScroll
        self.header = header
        self.toolbarLeading = toolbarLeading
        self.toolbarPrincipal = toolbarPrincipal
        self.toolbarTrailing = toolbarTrailing
        self.content = content
    }

    public var body: some View {
        screenContainer
        .zenBackground()
        .zenRefreshable(onRefresh)
        .applyZenNavigationTitle(navigationTitle, displayMode: resolvedDisplayMode)
        .toolbar { toolbarContent }
        .navigationBarBackButtonHidden(resolvedCustomBackButton != nil)
        .environment(
            \.zenScreenNavigationContext,
            ZenScreenNavigationContext(title: navigationTitle, backButton: backButton)
        )
    }

    private var resolvedDisplayMode: ZenNavigationBarTitleDisplayMode {
        ZenNavigationChrome.resolvedDisplayMode(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode
        )
    }

    private var resolvedCustomBackButton: ZenScreenBackButton? {
        ZenNavigationChrome.resolvedCustomBackButton(
            backButton: backButton,
            navigationContext: navigationContext,
            dismiss: dismiss.callAsFunction
        )
    }

    private var shouldUseInlineTitleToolbarItem: Bool {
        ZenNavigationChrome.shouldUseInlineTitleToolbarItem(
            navigationTitle: navigationTitle,
            resolvedDisplayMode: resolvedDisplayMode
        )
    }

    private var toolbarContent: some ToolbarContent {
        ZenNavigationToolbarContent(
            hidesSharedBackground: hidesSharedToolbarBackground,
            leadingPlacement: ZenNavigationChrome.leadingToolbarPlacement,
            trailingPlacement: ZenNavigationChrome.trailingToolbarPlacement,
            customBackButton: resolvedCustomBackButton,
            navigationTitle: navigationTitle,
            shouldUseInlineTitleToolbarItem: shouldUseInlineTitleToolbarItem,
            toolbarLeading: toolbarLeading,
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: toolbarTrailing
        )
    }

    @ViewBuilder
    private var screenContainer: some View {
        switch containerStyle {
        case .scroll:
            if ignoresTopSafeArea {
                scrollView.ignoresSafeArea(edges: .top)
            } else {
                scrollView
            }
        case .list:
            if ignoresTopSafeArea {
                List {
                    if let header { header() }
                    content()
                }
                .scrollContentBackground(.hidden)
                .ignoresSafeArea(edges: .top)
            } else {
                List {
                    if let header { header() }
                    content()
                }
                .scrollContentBackground(.hidden)
            }
        case .static:
            if ignoresTopSafeArea {
                staticScreenContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .ignoresSafeArea(edges: .top)
            } else {
                staticScreenContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    private var scrollScreenContent: some View {
        LazyVStack(alignment: .leading, spacing: ZenSpacing.medium) {
            if let header {
                header()
                    .frame(maxWidth: .infinity)
            }

            content()
        }
    }

    @ViewBuilder
    private var scrollView: some View {
        if #available(iOS 18, *) {
            ScrollView { scrollScreenContent }
                .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, y in
                    onScroll?(y)
                }
        } else {
            ScrollView { scrollScreenContent }
        }
    }

    private var staticScreenContent: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            if let header {
                header()
            }

            content()
        }
    }
}

// MARK: - Convenience overloads

public extension ZenScreen where Header == EmptyView, ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            onRefresh: onRefresh,
            header: { EmptyView() },
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            onRefresh: onRefresh,
            header: header,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            header: header,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            header: header,
            toolbarLeading: toolbarLeading,
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenScreen where Header == EmptyView, ToolbarPrincipal == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            header: { EmptyView() },
            toolbarLeading: toolbarLeading,
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where Header == EmptyView, ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            header: { EmptyView() },
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            header: header,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            header: header,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarPrincipal == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            onRefresh: onRefresh,
            header: header,
            toolbarLeading: toolbarLeading,
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

// MARK: - String title overloads

public extension ZenScreen where Header == EmptyView, ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            header: header,
            toolbarPrincipal: toolbarPrincipal,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            header: header,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            header: header,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            header: header,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            header: header,
            toolbarLeading: toolbarLeading,
            content: content
        )
    }
}

public extension ZenScreen where Header == EmptyView, ToolbarPrincipal == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarPrincipal == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            header: header,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

// MARK: - Private helpers

private extension View {
    @ViewBuilder
    func zenRefreshable(_ action: (@Sendable () async -> Void)?) -> some View {
        if let action {
            refreshable {
                await action()
            }
        } else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        ZenScreen(
            navigationTitle: ZenScreenTitle(
                "Dashboard",
                leadingIcon: .asset("ChartBar"),
                trailingIcon: .asset("Lightning")
            ),
            navigationBarTitleDisplayMode: .inline,
            backButton: ZenScreenBackButton("Overview"),
            header: {
                ZenScreenHeader(
                    title: "Welcome back",
                    subtitle: "Sign in to continue."
                )
            },
            toolbarLeading: {
                ZenIcon(assetName: "Sidebar", size: 18)
            },
            toolbarTrailing: {
                ZenIcon(assetName: "UserCircle", size: 18)
            }
        ) {
            VStack(spacing: ZenSpacing.medium) {
                ZenTextInput(text: .constant(""), prompt: "Email", leadingIcon: .asset("Envelope"))
                ZenButton("Continue") {}
            }
            .padding(.horizontal, ZenSpacing.small)
        }
    }
}
