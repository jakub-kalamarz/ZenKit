import SwiftUI

public enum ZenMenuItemVariant {
    case `default`
    case destructive
}

private extension View {
    @ViewBuilder
    func zenMenuAccessibilityIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}

public struct ZenMenu<Label: View, Content: View>: View {
    private let label: () -> Label
    private let content: () -> Content

    public init(
        @ViewBuilder trigger: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = trigger
        self.content = content
    }

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self.content = content
    }

    public var body: some View {
        Menu {
            content()
        } label: {
            label()
        }
    }
}

public struct ZenMenuTrigger<Label: View>: View {
    private let label: () -> Label

    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }

    public var body: some View {
        label()
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
    }
}

public struct ZenMenuContent<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
    }
}

public struct ZenMenuItem<Label: View>: View {
    private let variant: ZenMenuItemVariant
    private let accessibilityIdentifier: String?
    private let action: () -> Void
    private let label: () -> Label

    public init(
        variant: ZenMenuItemVariant = .default,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.variant = variant
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(role: role, action: action) {
            label()
        }
        .zenMenuAccessibilityIdentifier(accessibilityIdentifier)
    }

    private var role: ButtonRole? {
        switch variant {
        case .default:
            return nil
        case .destructive:
            return .destructive
        }
    }
}

public extension ZenMenuItem where Label == Text {
    init(
        _ title: LocalizedStringKey,
        variant: ZenMenuItemVariant = .default,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(variant: variant, accessibilityIdentifier: accessibilityIdentifier, action: action) {
            Text(title)
        }
    }
}

public struct ZenMenuSeparator: View {
    public init() {}

    public var body: some View {
        Divider()
    }
}

#Preview {
    ZStack {
        Color.zenBackground.ignoresSafeArea()

        ZenMenu {
            ZenMenuTrigger {
                ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 40)
            }
        } content: {
            ZenMenuContent {
                ZenMenuItem("Profile") {}
                ZenMenu {
                    ZenMenuItem("Team") {}
                    ZenMenuItem("Subscription") {}
                } label: {
                    Label {
                        Text("More")
                    } icon: {
                        ZenMenuIcon(assetName: "DotsThree", renderingMode: .template)
                    }
                }
                ZenMenuSeparator()
                ZenMenuItem("Delete workspace", variant: .destructive) {}
            }
        }
    }
}
