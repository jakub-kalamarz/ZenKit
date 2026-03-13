import SwiftUI

public struct ZenListSection<Content: View>: View {
    private let title: String?
    private let subtitle: String?
    private let content: () -> Content

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.zenTitle)
                            .foregroundStyle(Color.zenTextPrimary)
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            VStack(spacing: ZenSpacing.small) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ZenListSection(title: "Workspace", subtitle: "Shared settings") {
        ZenNavigationRow(title: "Members", subtitle: "Manage access", leadingIconAsset: "UsersThree")
        ZenNavigationRow(title: "Billing", subtitle: "Invoices and seats", leadingIconAsset: "CreditCard")
    }
    .padding()
    .background(Color.zenBackground)
}
