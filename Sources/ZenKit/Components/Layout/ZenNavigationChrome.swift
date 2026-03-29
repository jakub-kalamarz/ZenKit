import SwiftUI

struct ZenNavigationToolbarContent<Leading: View, Principal: View, Trailing: View>: ToolbarContent {
    let hidesSharedBackground: Bool
    let leadingPlacement: ToolbarItemPlacement
    let trailingPlacement: ToolbarItemPlacement
    let customBackButton: ZenScreenBackButton?
    let navigationTitle: ZenScreenTitle?
    let shouldUseInlineTitleToolbarItem: Bool
    let toolbarLeading: (() -> Leading)?
    let toolbarPrincipal: (() -> Principal)?
    let toolbarTrailing: (() -> Trailing)?

    var body: some ToolbarContent {
        if let customBackButton {
            zenToolbarItem(
                placement: leadingPlacement,
                hidesSharedBackground: hidesSharedBackground
            ) {
                ZenNavigationBackButtonView(backButton: customBackButton)
            }
        }

        if let toolbarLeading {
            zenToolbarItem(
                placement: leadingPlacement,
                hidesSharedBackground: hidesSharedBackground
            ) {
                toolbarLeading()
            }
        }

        if let toolbarPrincipal {
            zenPrincipalToolbarItem(hidesSharedBackground: hidesSharedBackground) {
                toolbarPrincipal()
            }
        } else if shouldUseInlineTitleToolbarItem, let navigationTitle {
            zenPrincipalToolbarItem(hidesSharedBackground: hidesSharedBackground) {
                ZenNavigationInlineTitleView(title: navigationTitle)
            }
        }

        if let toolbarTrailing {
            zenToolbarItem(
                placement: trailingPlacement,
                hidesSharedBackground: hidesSharedBackground
            ) {
                toolbarTrailing()
            }
        }
    }
}

enum ZenNavigationChrome {
    static func resolvedDisplayMode(
        navigationTitle: ZenScreenTitle?,
        navigationBarTitleDisplayMode: ZenNavigationBarTitleDisplayMode
    ) -> ZenNavigationBarTitleDisplayMode {
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

    static func resolvedCustomBackButton(
        backButton: ZenScreenBackButton?,
        navigationContext: ZenScreenNavigationContext,
        dismiss: @escaping () -> Void
    ) -> ZenScreenBackButton? {
        let explicitBackButton = backButton ?? navigationContext.backButton
        guard let explicitBackButton else { return nil }

        let action = explicitBackButton.action ?? dismiss
        return ZenScreenBackButton(explicitBackButton.text, action: action)
    }

    static func shouldUseInlineTitleToolbarItem(
        navigationTitle: ZenScreenTitle?,
        resolvedDisplayMode: ZenNavigationBarTitleDisplayMode
    ) -> Bool {
        guard let navigationTitle else { return false }
        guard resolvedDisplayMode == .inline else { return false }
        return navigationTitle.leadingIconAsset != nil || navigationTitle.trailingIconAsset != nil
    }

    static var leadingToolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .navigation
        #else
        return .navigationBarLeading
        #endif
    }

    static var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #else
        return .navigationBarTrailing
        #endif
    }
}

struct ZenNavigationInlineTitleView: View {
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

struct ZenNavigationBackButtonView: View {
    let backButton: ZenScreenBackButton

    var body: some View {
        Button(action: backButton.action ?? {}) {
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

extension View {
    @ViewBuilder
    func applyZenNavigationTitle(
        _ title: ZenScreenTitle?,
        displayMode: ZenNavigationBarTitleDisplayMode
    ) -> some View {
        if let title {
            #if os(macOS)
            navigationTitle(title.text)
            #else
            navigationTitle(title.text)
                .navigationBarTitleDisplayMode(displayMode.zenSwiftUIValue)
            #endif
        } else {
            self
        }
    }
}

@ToolbarContentBuilder
func zenPrincipalToolbarItem<Content: View>(
    hidesSharedBackground: Bool,
    @ViewBuilder content: () -> Content
) -> some ToolbarContent {
    zenToolbarItem(
        placement: .principal,
        hidesSharedBackground: hidesSharedBackground,
        content: content
    )
}

@ToolbarContentBuilder
func zenToolbarItem<Content: View>(
    placement: ToolbarItemPlacement,
    hidesSharedBackground: Bool,
    @ViewBuilder content: () -> Content
) -> some ToolbarContent {
    #if os(iOS)
    if #available(iOS 26.0, *), hidesSharedBackground {
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
    var zenSwiftUIValue: NavigationBarItem.TitleDisplayMode {
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
