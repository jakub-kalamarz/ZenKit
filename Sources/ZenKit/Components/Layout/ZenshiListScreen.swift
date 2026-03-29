import SwiftUI

@available(*, deprecated, message: "Use ZenScreen(containerStyle: .list, ...) instead.")
public struct ZenListScreen<ToolbarLeading: View, ToolbarPrincipal: View, ToolbarTrailing: View, Content: View>: View {
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
        ZenScreen(
            containerStyle: .list,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            hidesSharedToolbarBackground: hidesSharedToolbarBackground,
            backButton: backButton,
            onRefresh: onRefresh,
            header: {
                EmptyView()
            },
            toolbarLeading: {
                if let toolbarLeading {
                    toolbarLeading()
                } else {
                    EmptyView()
                }
            },
            toolbarPrincipal: {
                if let toolbarPrincipal {
                    toolbarPrincipal()
                } else {
                    EmptyView()
                }
            },
            toolbarTrailing: {
                if let toolbarTrailing {
                    toolbarTrailing()
                } else {
                    EmptyView()
                }
            }
        ) {
            content()
        }
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

#Preview {
    NavigationStack {
        ZenScreen(
            containerStyle: .list,
            navigationTitle: "Settings",
            header: {
                EmptyView()
            },
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
