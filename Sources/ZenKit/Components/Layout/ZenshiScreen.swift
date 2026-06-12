import SwiftUI

private enum ZenScreenMetrics {
    static let contentPadding = ZenSpacing.medium

    static var listRowInsets: EdgeInsets {
        EdgeInsets(
            top: ZenSpacing.xSmall,
            leading: contentPadding,
            bottom: ZenSpacing.xSmall,
            trailing: contentPadding
        )
    }
}

public enum ZenScreenContainerStyle: Sendable {
    case scroll
    case scrollBottomAnchored
    case list
    case `static`
}

public struct ZenScreen<Header: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.zenScreenNavigationContext) private var navigationContext

    private let containerStyle: ZenScreenContainerStyle
    private let navigationTitle: ZenScreenTitle?
    private let navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode
    private let ignoresTopSafeArea: Bool
    private let backButton: ZenScreenBackButton?
    private let onRefresh: (@Sendable () async -> Void)?
    private let onScroll: ((CGFloat) -> Void)?
    private let header: (() -> Header)?
    private let content: () -> Content

    public init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        onScroll: ((CGFloat) -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.containerStyle = containerStyle
        self.navigationTitle = navigationTitle
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
        self.ignoresTopSafeArea = ignoresTopSafeArea
        self.backButton = backButton
        self.onRefresh = onRefresh
        self.onScroll = onScroll
        self.header = header
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        screenContainer
            .zenBackground()
            .zenRefreshable(onRefresh)
            .applyZenNavigationTitle(navigationTitle, displayMode: resolvedDisplayMode)
            .applyZenBackButton(resolvedCustomBackButton)
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

    @ViewBuilder
    private var screenContainer: some View {
        switch containerStyle {
        case .scroll:
            if ignoresTopSafeArea {
                scrollView.ignoresSafeArea(edges: .top)
            } else {
                scrollView
            }
        case .scrollBottomAnchored:
            if ignoresTopSafeArea {
                bottomAnchoredScrollView.ignoresSafeArea(edges: .top)
            } else {
                bottomAnchoredScrollView
            }
        case .list:
            if ignoresTopSafeArea {
                listView
                .scrollContentBackground(.hidden)
                .ignoresSafeArea(edges: .top)
            } else {
                listView
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
        if #available(iOS 18, macOS 15, *) {
            ScrollView { scrollScreenContent }
                .scrollDismissesKeyboard(.interactively)
                .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, y in
                    onScroll?(y)
                }
        } else {
            ScrollView { scrollScreenContent }
                .scrollDismissesKeyboard(.interactively)
        }
    }

    @ViewBuilder
    private var bottomAnchoredScrollView: some View {
        if #available(iOS 18, macOS 15, *) {
            ScrollView { scrollScreenContent }
                .defaultScrollAnchor(.bottom)
                .scrollDismissesKeyboard(.interactively)
                .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, y in
                    onScroll?(y)
                }
        } else {
            if #available(iOS 17, macOS 14, *) {
                ScrollView { scrollScreenContent }
                    .defaultScrollAnchor(.bottom)
                    .scrollDismissesKeyboard(.interactively)
            } else {
                ScrollView { scrollScreenContent }
                    .scrollDismissesKeyboard(.interactively)
            }
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

    private var listView: some View {
        List {
            if let header {
                header()
                    .listRowInsets(ZenScreenMetrics.listRowInsets)
            }

            content()
                .listRowInsets(ZenScreenMetrics.listRowInsets)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Convenience overloads

public extension ZenScreen where Header == EmptyView {
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        onScroll: ((CGFloat) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            onRefresh: onRefresh,
            onScroll: onScroll,
            header: { EmptyView() },
            content: content
        )
    }
}

// MARK: - String title overloads

public extension ZenScreen where Header == EmptyView {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle(LocalizedStringKey($0)) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            onRefresh: onRefresh,
            content: content
        )
    }
}

public extension ZenScreen {
    @_disfavoredOverload
    init(
        containerStyle: ZenScreenContainerStyle = .scroll,
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        ignoresTopSafeArea: Bool = false,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            containerStyle: containerStyle,
            navigationTitle: navigationTitle.map { ZenScreenTitle(LocalizedStringKey($0)) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            ignoresTopSafeArea: ignoresTopSafeArea,
            backButton: backButton,
            onRefresh: onRefresh,
            header: header,
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

    @ViewBuilder
    func applyZenBackButton(_ backButton: ZenScreenBackButton?) -> some View {
        if let backButton {
            self
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: ZenNavigationChrome.leadingToolbarPlacement) {
                        ZenNavigationBackButtonView(backButton: backButton)
                    }
                }
        } else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        ZenScreen(
            navigationTitle: ZenScreenTitle("Dashboard"),
            navigationBarTitleDisplayMode: .inline,
            backButton: ZenScreenBackButton("Overview"),
            header: {
                ZenScreenHeader(
                    title: "Welcome back",
                    subtitle: "Sign in to continue."
                )
            }
        ) {
            VStack(spacing: ZenSpacing.medium) {
                ZenTextInput(text: .constant(""), prompt: "Email", leadingIcon: .system("envelope"))
                ZenButton("Continue") {}
            }
            .padding(.horizontal, ZenSpacing.small)
        }
        .toolbar {
            ToolbarItem(placement: ZenNavigationChrome.leadingToolbarPlacement) {
                ZenIcon(systemName: "sidebar.left")
            }
            ToolbarItem(placement: ZenNavigationChrome.trailingToolbarPlacement) {
                ZenIcon(systemName: "person.circle")
            }
        }
    }
}
