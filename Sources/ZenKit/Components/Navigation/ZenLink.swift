import SwiftUI

public enum ZenLinkVariant: Sendable {
    case inline
    case current
    case plain
}

public struct ZenLink<Label: View>: View {
    private let variant: ZenLinkVariant
    private let action: () -> Void
    private let label: Label

    public init(
        variant: ZenLinkVariant = .inline,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: action) {
            label
                .font(.zenBody)
                .foregroundStyle(resolvedColor)
                .underline(variant == .inline)
        }
        .buttonStyle(.plain)
    }

    private var resolvedColor: Color {
        switch variant {
        case .inline:
            return .zenPrimary
        case .current:
            return .zenTextPrimary
        case .plain:
            return .zenTextPrimary
        }
    }
}

extension ZenLink where Label == Text {
    public init(_ title: String, variant: ZenLinkVariant = .inline, action: @escaping () -> Void) {
        self.variant = variant
        self.action = action
        self.label = Text(title)
    }
}

#if canImport(UIKit)
extension ZenLink where Label == Text {
    public init(_ title: String, url: URL, variant: ZenLinkVariant = .inline) {
        self.variant = variant
        self.label = Text(title)
        self.action = {
            UIApplication.shared.open(url)
        }
    }
}
#endif

#Preview("ZenLink") {
    VStack(alignment: .leading, spacing: ZenSpacing.medium) {
        ZenLink("Inline link", variant: .inline) {}
        ZenLink("Current color link", variant: .current) {}
        ZenLink("Plain link", variant: .plain) {}
    }
    .padding()
    .background(Color.zenBackground)
}
