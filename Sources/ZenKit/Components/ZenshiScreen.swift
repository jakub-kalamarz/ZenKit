import SwiftUI

public struct ZenScreen<Header: View, ToolbarLeading: View, ToolbarPrincipal: View, ToolbarTrailing: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.zenScreenNavigationContext) private var navigationContext

    private let navigationTitle: ZenScreenTitle?
    private let navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode
    private let backButton: ZenScreenBackButton?
    private let onRefresh: (@Sendable () async -> Void)?
    private let header: (() -> Header)?
    private let toolbarLeading: (() -> ToolbarLeading)?
    private let toolbarPrincipal: (() -> ToolbarPrincipal)?
    private let toolbarTrailing: (() -> ToolbarTrailing)?
    private let content: () -> Content

    public init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.navigationTitle = navigationTitle
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
        self.backButton = backButton
        self.onRefresh = onRefresh
        self.header = header
        self.toolbarLeading = toolbarLeading
        self.toolbarPrincipal = toolbarPrincipal
        self.toolbarTrailing = toolbarTrailing
        self.content = content
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: ZenSpacing.medium) {
                if let header {
                    header()
                }

                content()
            }
            .padding(.horizontal, ZenSpacing.small)
        }
        .background(Color.zenBackground)
        .zenRefreshable(onRefresh)
        .applyNavigationTitle(navigationTitle, displayMode: resolvedDisplayMode)
        .toolbar {
            if let customBackButton = resolvedCustomBackButton {
                standardToolbarItem(placement: leadingToolbarPlacement) {
                    ZenScreenBackButtonView(backButton: customBackButton)
                }
            }

            if let toolbarLeading {
                standardToolbarItem(placement: leadingToolbarPlacement) {
                    toolbarLeading()
                }
            }

            if let toolbarPrincipal {
                principalToolbarItem {
                    toolbarPrincipal()
                }
            } else if shouldUseInlineTitleToolbarItem, let navigationTitle {
                principalToolbarItem {
                    ZenScreenInlineTitleView(title: navigationTitle)
                }
            }

            if let toolbarTrailing {
                standardToolbarItem(placement: trailingToolbarPlacement) {
                    toolbarTrailing()
                }
            }
        }
        .navigationBarBackButtonHidden(resolvedCustomBackButton != nil)
        .environment(
            \.zenScreenNavigationContext,
            ZenScreenNavigationContext(title: navigationTitle, backButton: backButton)
        )
    }

    private var resolvedDisplayMode: ZenNavigationBarTitleDisplayMode {
        guard navigationTitle != nil else { return .automatic }

        switch navigationBarTitleDisplayMode {
        case .automatic:
            return .inline
        case .inline:
            return .inline
        case .large:
            return .large
        }
    }

    private var resolvedCustomBackButton: ZenScreenBackButton? {
        let explicitBackButton = backButton ?? navigationContext.backButton
        guard let explicitBackButton else { return nil }

        let action = explicitBackButton.action ?? { dismiss() }
        return ZenScreenBackButton(explicitBackButton.text, action: action)
    }

    private var shouldUseInlineTitleToolbarItem: Bool {
        guard let navigationTitle else { return false }
        guard resolvedDisplayMode == .inline else { return false }
        return navigationTitle.leadingIconAsset != nil || navigationTitle.trailingIconAsset != nil
    }

    private var leadingToolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .navigation
        #else
        return .navigationBarLeading
        #endif
    }

    private var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #else
        return .navigationBarTrailing
        #endif
    }
}

// MARK: - Convenience overloads

public extension ZenScreen where Header == EmptyView, ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            backButton: backButton,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            backButton: backButton,
            header: header,
            toolbarPrincipal: toolbarPrincipal,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            backButton: backButton,
            header: header,
            content: content
        )
    }
}

public extension ZenScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView {
    @_disfavoredOverload
    init(
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        navigationTitle: String? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            backButton: backButton,
            header: header,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

// MARK: - Private subviews

private struct ZenScreenInlineTitleView: View {
    let title: ZenScreenTitle

    var body: some View {
        HStack(spacing: ZenSpacing.xSmall) {
            if let leadingIconAsset = title.leadingIconAsset {
                ZenIcon(assetName: leadingIconAsset, size: 13)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
            }

            Text(title.text)
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)
                .lineLimit(1)

            if let trailingIconAsset = title.trailingIconAsset {
                ZenIcon(assetName: trailingIconAsset, size: 13)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ZenScreenBackButtonView: View {
    let backButton: ZenScreenBackButton

    var body: some View {
        Button(action: {
            backButton.action?()
        }) {
            HStack(spacing: ZenSpacing.xSmall) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))

                if let text = backButton.text, !text.isEmpty {
                    Text(text)
                        .lineLimit(1)
                }
            }
            .font(.zenLabel)
            .foregroundStyle(Color.zenPrimary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
    func applyNavigationTitle(
        _ title: ZenScreenTitle?,
        displayMode: ZenNavigationBarTitleDisplayMode
    ) -> some View {
        if let title {
            #if os(macOS)
            navigationTitle(title.text)
            #else
            navigationTitle(title.text)
                .navigationBarTitleDisplayMode(displayMode.swiftUIValue)
            #endif
        } else {
            self
        }
    }
}

@ToolbarContentBuilder
private func principalToolbarItem<Content: View>(@ViewBuilder content: () -> Content) -> some ToolbarContent {
    standardToolbarItem(placement: .principal, content: content)
}

@ToolbarContentBuilder
private func standardToolbarItem<Content: View>(
    placement: ToolbarItemPlacement,
    @ViewBuilder content: () -> Content
) -> some ToolbarContent {
    #if os(iOS)
    if #available(iOS 26.0, *) {
        ToolbarItem(placement: placement) {
            content()
        }
        .sharedBackgroundVisibility(.hidden)
    } else {
        ToolbarItem(placement: placement) {
            content()
        }
    }
    #else
    ToolbarItem(placement: placement) {
        content()
    }
    #endif
}

#if !os(macOS)
private extension ZenNavigationBarTitleDisplayMode {
    var swiftUIValue: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic:
            return .automatic
        case .inline:
            return .inline
        case .large:
            return .large
        }
    }
}
#endif

#Preview {
    NavigationStack {
        ZenScreen(
            navigationTitle: ZenScreenTitle(
                "Dashboard",
                leadingIconAsset: "ChartBar",
                trailingIconAsset: "Lightning"
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
                ZenTextInput(text: .constant(""), prompt: "Email", leadingIconAsset: "Envelope")
                ZenButton("Continue") {}
            }
        }
    }
}
