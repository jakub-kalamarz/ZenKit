import SwiftUI

public struct ZenInlineAction: View {
    private let title: LocalizedStringKey
    private let action: () -> Void

    public init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        let style = ZenInlineActionResolvedStyle()

        Button(title, action: action)
            .buttonStyle(.plain)
            .font(style.font)
            .foregroundStyle(style.foregroundColor)
    }
}

enum ZenInlineActionForegroundStyle {
    case accent
}

struct ZenInlineActionResolvedStyle {
    let fontSpec: ZenResolvedFontSpec
    let font: Font
    let foregroundColor: Color
    let foregroundStyle: ZenInlineActionForegroundStyle

    init(theme: ZenTheme = .current) {
        let caption = theme.resolvedTypography.fontSpec(for: .group)

        fontSpec = caption.with(size: caption.size, weight: .semibold)
        font = fontSpec.font
        foregroundColor = .zenPrimary
        foregroundStyle = .accent
    }
}

#Preview {
    HStack(spacing: ZenSpacing.medium) {
        ZenInlineAction("Manage") {}
        ZenInlineAction("Retry") {}
    }
    .padding()
    .background(Color.zenBackground)
}
