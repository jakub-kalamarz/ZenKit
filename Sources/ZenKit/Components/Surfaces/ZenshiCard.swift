import SwiftUI

public struct ZenCard<Content: View, Footer: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String?
    private let subtitle: String?
    private let content: () -> Content
    private let footer: () -> Footer
    private let showsFooter: Bool

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: parentCornerRadius)

        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.zenDisplayXS)
                            .foregroundStyle(Color.zenTextPrimary)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.zenTextXS)
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
        .padding(theme.resolvedMetrics.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.zenSurface)
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
                    .font(.zenTextSM.weight(.medium))
                    .foregroundStyle(Color.zenTextPrimary)

                Text("Last synced 2 minutes ago")
                    .font(.zenTextXS)
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
