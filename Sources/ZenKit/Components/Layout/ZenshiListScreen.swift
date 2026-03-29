import SwiftUI

public struct ZenListScreen<ToolbarLeading: View, ToolbarPrincipal: View, ToolbarTrailing: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.zenScreenNavigationContext) private var navigationContext

    private let navigationTitle: ZenScreenTitle?
    private let navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode
    private let hidesSharedToolbarBackground: Bool
    private let backButton: ZenScreenBackButton?
    private let onRefresh: (@Sendable () async -> Void)?
    private let toolbarLeading: (() -> ToolbarLeading)?
    private let toolbarPrincipal: (() -> ToolbarPrincipal)?
    private let toolbarTrailing: (() -> ToolbarTrailing)?
    private let content: () -> Content

    public init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.navigationTitle = navigationTitle
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
        self.hidesSharedToolbarBackground = hidesSharedToolbarBackground
        self.backButton = backButton
        self.onRefresh = onRefresh
        self.toolbarLeading = toolbarLeading
        self.toolbarPrincipal = toolbarPrincipal
        self.toolbarTrailing = toolbarTrailing
        self.content = content
    }

    public var body: some View {
        List {
            content()
        }
        .scrollContentBackground(.hidden)
        .zenBackground()
        .zenListScreenRefreshable(onRefresh)
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
}

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarLeading: { EmptyView() },
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: { EmptyView() },
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarPrincipal == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarLeading: toolbarLeading,
            toolbarPrincipal: { EmptyView() },
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarPrincipal: toolbarPrincipal,
            content: content
        )
    }
}

public extension ZenListScreen where ToolbarPrincipal == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        hidesSharedToolbarBackground: Bool = true,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

private extension View {
    @ViewBuilder
    func zenListScreenRefreshable(_ action: (@Sendable () async -> Void)?) -> some View {
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
        ZenListScreen(
            navigationTitle: "Settings",
            toolbarTrailing: {
                ZenButton("Edit", variant: .secondary, size: .sm) {}
            }
        ) {
            Section("Workspace") {
                ZenNavigationRow(
                    title: "Members",
                    subtitle: "Manage access",
                    leadingIconAsset: "UsersThree"
                )
            }
        }
    }
}
