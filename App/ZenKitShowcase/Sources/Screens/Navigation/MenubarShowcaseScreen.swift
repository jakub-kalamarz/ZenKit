import SwiftUI
import ZenKit

struct MenubarShowcaseScreen: View {
    @State private var selected = "bold"

    var body: some View {
        ShowcaseScreen(title: "Menubar") {
            ZenCard(title: "Toolbar", subtitle: "Horizontal icon buttons") {
                ZenMenubar(
                    items: [
                        .init(id: "bold", icon: "bold", action: { selected = "bold" }),
                        .init(id: "italic", icon: "italic", action: { selected = "italic" }),
                        .init(id: "underline", icon: "underline", action: { selected = "underline" }),
                        .init(id: "strikethrough", icon: "strikethrough", action: { selected = "strikethrough" }),
                        .init(id: "link", icon: "link", action: { selected = "link" }),
                    ],
                    selectedId: selected
                )
            }

            ZenCard(title: "With Labels", subtitle: "Icon + text items") {
                ZenMenubar(
                    items: [
                        .init(id: "home", icon: "house", label: "Home", action: {}),
                        .init(id: "search", icon: "magnifyingglass", label: "Search", action: {}),
                        .init(id: "settings", icon: "gearshape", label: "Settings", action: {}),
                    ]
                )
            }
        }
    }
}
