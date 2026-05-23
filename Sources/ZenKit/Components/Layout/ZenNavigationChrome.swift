import SwiftUI

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

struct ZenNavigationBackButtonView: View {
    let backButton: ZenScreenBackButton

    var body: some View {
        Button(action: backButton.action ?? {}) {
            HStack(spacing: ZenSpacing.xSmall) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))

                if let text = backButton.text {
                    Text(text)
                        .lineLimit(1)
                }
            }
            .font(.zen(.body2, weight: .medium))
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
                .applyZenNavigationSubtitle(title)
            #else
            navigationTitle(title.text)
                .navigationBarTitleDisplayMode(displayMode.zenSwiftUIValue)
                .applyZenNavigationSubtitle(title)
            #endif
        } else {
            self
        }
    }
}

private extension View {
    @ViewBuilder
    func applyZenNavigationSubtitle(_ title: ZenScreenTitle) -> some View {
        if let subheadline = title.subheadline {
            #if os(iOS)
            if #available(iOS 26.0, *) {
                navigationSubtitle(Text(subheadline))
            } else {
                self
            }
            #elseif os(macOS)
            navigationSubtitle(Text(subheadline))
            #else
            self
            #endif
        } else {
            self
        }
    }
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
