import SwiftUI

public struct ZenSheetContainer<Content: View, Footer: View>: View {
    private let title: String
    private let subtitle: String?
    private let content: () -> Content
    private let footer: () -> Footer
    private let showsFooter: Bool

    public init(
        title: String,
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
        title: String,
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
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zenTitle)
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            content()

            if showsFooter {
                Divider()
                footer()
            }
        }
        .padding(ZenSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
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
            .padding()
        }
    }
}

#Preview {
    ZenSheetContainerPreview()
}

#Preview("Presented") {
    ZenSheetContainerPreview(isPresented: true)
}
