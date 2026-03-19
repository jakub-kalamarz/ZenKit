import SwiftUI

public struct ZenSection<Content: View, Header: View, Footer: View>: View {
    private let content: () -> Content
    private let header: () -> Header
    private let footer: () -> Footer

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.content = content
        self.header = header
        self.footer = footer
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            header()

            ZenSectionBody(content: content)

            footer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(
            EdgeInsets(
                top: ZenSpacing.xSmall,
                leading: ZenSpacing.medium,
                bottom: ZenSpacing.xSmall,
                trailing: ZenSpacing.medium
            )
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

public extension ZenSection where Header == EmptyView, Footer == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.init(
            content: content,
            header: { EmptyView() },
            footer: { EmptyView() }
        )
    }
}

public extension ZenSection where Footer == EmptyView {
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.init(
            content: content,
            header: header,
            footer: { EmptyView() }
        )
    }
}

public extension ZenSection where Header == EmptyView {
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            content: content,
            header: { EmptyView() },
            footer: footer
        )
    }
}

private struct ZenSectionBody<Content: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: parentCornerRadius)

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            content()
        }
        .padding(.vertical, ZenSpacing.xSmall)
        .padding(.horizontal, ZenSpacing.small)
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
    List {
        ZenSection {
            ZenNavigationRow(title: "Members", subtitle: "Manage access", leadingIconAsset: "UsersThree")
            ZenNavigationRow(title: "Billing", subtitle: "Invoices and seats", leadingIconAsset: "CreditCard")
        } header: {
            ZenSectionHeader {
                Text("Workspace")
            } subtitle: {
                Text("Shared settings")
            }
        } footer: {
            ZenSectionFooter {
                Text("Admins can update access.")
            }
        }
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(Color.zenBackground)
}
