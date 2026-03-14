import SwiftUI

public struct ZenListScreen<ToolbarLeading: View, ToolbarPrincipal: View, ToolbarTrailing: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.zenScreenNavigationContext) private var navigationContext

    private let navigationTitle: ZenScreenTitle?
    private let navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode
    private let backButton: ZenScreenBackButton?
    private let onRefresh: (@Sendable () async -> Void)?
    private let toolbarLeading: (() -> ToolbarLeading)?
    private let toolbarPrincipal: (() -> ToolbarPrincipal)?
    private let toolbarTrailing: (() -> ToolbarTrailing)?
    private let content: () -> Content

    public init(
        navigationTitle: ZenScreenTitle? = nil,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode = .automatic,
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.navigationTitle = navigationTitle
        self.navigationBarTitleDisplayMode = navigationBarTitleDisplayMode
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
        .background(Color.zenBackground)
        .zenListScreenRefreshable(onRefresh)
        .applyZenListScreenNavigationTitle(navigationTitle, displayMode: resolvedDisplayMode)
        .toolbar {
            if let customBackButton = resolvedCustomBackButton {
                zenListScreenToolbarItem(placement: leadingToolbarPlacement) {
                    ZenListScreenBackButtonView(backButton: customBackButton)
                }
            }

            if let toolbarLeading {
                zenListScreenToolbarItem(placement: leadingToolbarPlacement) {
                    toolbarLeading()
                }
            }

            if let toolbarPrincipal {
                zenListScreenPrincipalToolbarItem {
                    toolbarPrincipal()
                }
            } else if shouldUseInlineTitleToolbarItem, let navigationTitle {
                zenListScreenPrincipalToolbarItem {
                    ZenListScreenInlineTitleView(title: navigationTitle)
                }
            }

            if let toolbarTrailing {
                zenListScreenToolbarItem(placement: trailingToolbarPlacement) {
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

public extension ZenListScreen where ToolbarLeading == EmptyView, ToolbarPrincipal == EmptyView, ToolbarTrailing == EmptyView {
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle,
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarPrincipal: @escaping () -> ToolbarPrincipal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
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
        backButton: ZenScreenBackButton? = nil,
        onRefresh: (@Sendable () async -> Void)? = nil,
        @ViewBuilder toolbarLeading: @escaping () -> ToolbarLeading,
        @ViewBuilder toolbarTrailing: @escaping () -> ToolbarTrailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            navigationTitle: navigationTitle.map { ZenScreenTitle($0) },
            navigationBarTitleDisplayMode: navigationBarTitleDisplayMode,
            backButton: backButton,
            onRefresh: onRefresh,
            toolbarLeading: toolbarLeading,
            toolbarTrailing: toolbarTrailing,
            content: content
        )
    }
}

private struct ZenListScreenInlineTitleView: View {
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

private struct ZenListScreenBackButtonView: View {
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

    @ViewBuilder
    func applyZenListScreenNavigationTitle(
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
private func zenListScreenPrincipalToolbarItem<Content: View>(@ViewBuilder content: () -> Content) -> some ToolbarContent {
    zenListScreenToolbarItem(placement: .principal, content: content)
}

@ToolbarContentBuilder
private func zenListScreenToolbarItem<Content: View>(
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
