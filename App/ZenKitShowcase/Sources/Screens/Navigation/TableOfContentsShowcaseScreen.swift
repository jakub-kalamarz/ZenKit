import SwiftUI
import ZenKit

struct TableOfContentsShowcaseScreen: View {
    @State private var activeId: String? = "overview"

    var body: some View {
        ShowcaseScreen(title: "Table of Contents") {
            ZenCard(title: "Basic", subtitle: "Section navigation with active indicator") {
                ZenTableOfContents(
                    items: [
                        .init(id: "overview", label: "Overview"),
                        .init(id: "installation", label: "Installation"),
                        .init(id: "npm", label: "npm", level: 1),
                        .init(id: "yarn", label: "yarn", level: 1),
                        .init(id: "usage", label: "Usage"),
                        .init(id: "api", label: "API Reference"),
                        .init(id: "faq", label: "FAQ"),
                    ],
                    activeId: $activeId
                )
            }
        }
    }
}
