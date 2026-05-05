import SwiftUI

public struct ZenSheetContainer<Content: View, Footer: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailingActionTitle: String?
    private let trailingAction: (() -> Void)?
    private let content: () -> Content
    private let footer: () -> Footer
    private let showsFooter: Bool

    public init(
        title: String,
        subtitle: String? = nil,
        trailingActionTitle: String? = nil,
        trailingAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) where Footer == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.trailingActionTitle = trailingActionTitle
        self.trailingAction = trailingAction
        self.content = content
        self.footer = { EmptyView() }
        self.showsFooter = false
    }

    public init(
        title: String,
        subtitle: String? = nil,
        trailingActionTitle: String? = nil,
        trailingAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingActionTitle = trailingActionTitle
        self.trailingAction = trailingAction
        self.content = content
        self.footer = footer
        self.showsFooter = true
    }

    public var body: some View {
        VStack(spacing: 0) {
            grabber
            header

            VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                content()
            }
            .padding(.horizontal, ZenSpacing.medium)
            .padding(.top, 8)
            .padding(.bottom, showsFooter ? ZenSpacing.medium : ZenSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsFooter {
                footerBlock
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.zenBackground)
        .ignoresSafeArea(.all, edges: .bottom)
    }

    private var grabber: some View {
        Capsule()
            .fill(Color.zenTextPrimary.opacity(0.18))
            .frame(width: 36, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: ZenSpacing.medium) {
            VStack(alignment: .leading, spacing: 2) {
                if let subtitle {
                    Text(subtitle)
                        .font(.zen(.eyebrow, weight: .bold))
                        .foregroundStyle(Color.zenPrimary)
                        .textCase(.uppercase)
                }

                Text(title)
                    .font(.zenStat)
                    .foregroundStyle(Color.zenTextPrimary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let trailingActionTitle, let trailingAction {
                Button(trailingActionTitle, action: trailingAction)
                    .font(.zen(.body2, weight: .semibold))
                    .foregroundStyle(Color.zenPrimary)
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, ZenSpacing.medium)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private var footerBlock: some View {
        VStack(spacing: 0) {
            footer()
                .padding(.horizontal, ZenSpacing.medium)
                .padding(.top, ZenSpacing.small)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.zenBackground)
    }
}

private struct ZenSheetContainerPreview: View {
    @State private var isPresented: Bool

    init(isPresented: Bool = false) {
        _isPresented = State(initialValue: isPresented)
    }

    var body: some View {
        ZStack {
            Color.zenBackground
                .ignoresSafeArea()

            ZenButton("Open sheet") {
                isPresented = true
            }
        }
        .zenAutoSizingSheet(isPresented: $isPresented) {
            ZenSheetContainer(
                title: "Share workspace",
                subtitle: "Invite collaborators by email"
            ) {
                ZenFieldGroup {
                    ZenField(label: "Email", message: "We’ll send them an invite") {
                        ZenTextInput(
                            text: .constant("new-teammate@example.com"),
                            prompt: "Email",
                            leadingIcon: .asset("Envelope")
                        )
                    }
                }
            } footer: {
                HStack(spacing: ZenSpacing.small) {
                    ZenButton("Cancel", variant: .secondary) {
                        isPresented = false
                    }
                    ZenButton("Send Invite", fullWidth: true) {}
                }
            }
        }
    }
}

#Preview {
    ZenSheetContainerPreview()
}

#Preview("Presented") {
    ZenSheetContainerPreview(isPresented: true)
}
