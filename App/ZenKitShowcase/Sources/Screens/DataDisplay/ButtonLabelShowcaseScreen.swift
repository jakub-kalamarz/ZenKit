import SwiftUI
import ZenKit

struct ButtonLabelShowcaseScreen: View {
    var body: some View {
        ZenScreen(
            containerStyle: .list,
            navigationTitle: ZenScreenTitle("Button Label")
        ) {
            ZenSection(header: { ZenSectionHeader { Text("Variants") } }) {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenButtonLabel("Default")
                    ZenButtonLabel("Outline", variant: .outline)
                    ZenButtonLabel("Secondary", variant: .secondary)
                    ZenButtonLabel("Ghost", variant: .ghost)
                    ZenButtonLabel("Destructive", variant: .destructive)
                    ZenButtonLabel("Link", variant: .link)
                }
            }

            ZenSection(header: { ZenSectionHeader { Text("Sizes") } }) {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenButtonLabel("Large", size: .lg)
                    ZenButtonLabel("Default", size: .default)
                    ZenButtonLabel("Small", size: .sm)
                    ZenButtonLabel("Extra Small", size: .xs)
                }
            }

            ZenSection(header: { ZenSectionHeader { Text("Icons") } }) {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenButtonLabel(
                        "Leading Icon",
                        leadingIcon: .init(systemName: "plus")
                    )
                    ZenButtonLabel(
                        "Trailing Icon",
                        trailingIcon: .init(systemName: "arrow.right")
                    )
                    ZenButtonLabel(
                        variant: .secondary,
                        size: .icon
                    ) {
                        ZenIcon(systemName: "plus")
                    }
                }
            }

            ZenSection(header: { ZenSectionHeader { Text("Full Width") } }) {
                ZenButtonLabel("Full Width Label", fullWidth: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ButtonLabelShowcaseScreen()
    }
}
