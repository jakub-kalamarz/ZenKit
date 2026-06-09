import SwiftUI
import ZenKit

struct CommandPaletteShowcaseScreen: View {
    @State private var isPresented = false

    var body: some View {
        ShowcaseScreen(title: "Command Palette") {
            ZenCard(title: "Cmd+K Style", subtitle: "Searchable command list") {
                Button("Open Command Palette") {
                    isPresented = true
                }
                .font(.zenBody)
            }
        }
        .overlay {
            if isPresented {
                ZenCommandPalette(
                    isPresented: $isPresented,
                    items: [
                        .init(label: "New File", icon: "doc.badge.plus", group: "File", shortcut: "⌘N", action: {}),
                        .init(label: "Open File", icon: "folder", group: "File", shortcut: "⌘O", action: {}),
                        .init(label: "Save", icon: "square.and.arrow.down", group: "File", shortcut: "⌘S", action: {}),
                        .init(label: "Find", icon: "magnifyingglass", group: "Edit", shortcut: "⌘F", action: {}),
                        .init(label: "Replace", icon: "arrow.left.arrow.right", group: "Edit", shortcut: "⌘H", action: {}),
                        .init(label: "Toggle Sidebar", icon: "sidebar.left", group: "View", shortcut: "⌘\\", action: {}),
                    ]
                )
            }
        }
    }
}
