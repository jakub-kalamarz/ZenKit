import SwiftUI

public struct ZenCard<Content: View, Footer: View, Background: ShapeStyle>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: LocalizedStringKey?
    private let subtitle: LocalizedStringKey?
    private let contentPadding: CGFloat?
    private let customCornerRadius: CGFloat?
    private let background: Background
    private let content: () -> Content
    private let footer: () -> Footer
    private let showsFooter: Bool

    public init(
        title: LocalizedStringKey? = nil,
        subtitle: LocalizedStringKey? = nil,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        background: Background,
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.contentPadding = padding
        self.customCornerRadius = cornerRadius
        self.background = background
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: LocalizedStringKey? = nil,
        subtitle: LocalizedStringKey? = nil,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        background: Background,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.contentPadding = padding
        self.customCornerRadius = cornerRadius
        self.background = background
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public init(
        title: LocalizedStringKey? = nil,
        subtitle: LocalizedStringKey? = nil,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == EmptyView, Background == Color {
        self.title = title
        self.subtitle = subtitle
        self.contentPadding = padding
        self.customCornerRadius = cornerRadius
        self.background = .zenSurface
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: LocalizedStringKey? = nil,
        subtitle: LocalizedStringKey? = nil,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Background == Color {
        self.title = title
        self.subtitle = subtitle
        self.contentPadding = padding
        self.customCornerRadius = cornerRadius
        self.background = .zenSurface
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = customCornerRadius ?? theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: parentCornerRadius)

        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.zenStat)
                            .foregroundStyle(Color.zenTextPrimary)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.zenGroup)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            content()

            if showsFooter {
                Divider()
                footer()
            }
        }
        .padding(contentPadding ?? theme.resolvedMetrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .zenContainerCornerRadius(cornerRadius)
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenCard(
            title: "Workspace",
            subtitle: "Connected project"
        ) {
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                Text("zen")
                    .font(.zen(.body2, weight: .medium))
                    .foregroundStyle(Color.zenTextPrimary)

                Text("Last synced 2 minutes ago")
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }

        ZenCard(
            title: "Billing",
            subtitle: "Renews on March 31"
        ) {
            ZenInfoCard(title: "Plan", value: "Pro")
        } footer: {
            ZenInlineAction("Manage subscription", action: {})
        }
    }
    .padding()
    .zenBackground()
}
