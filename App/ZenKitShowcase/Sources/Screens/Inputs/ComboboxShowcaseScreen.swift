import SwiftUI
import ZenKit

struct ComboboxShowcaseScreen: View {
    @State private var selection: Set<String> = ["swift"]

    private let languages: [ZenComboboxOption] = [
        .init(id: "swift", label: "Swift", icon: "swift"),
        .init(id: "python", label: "Python"),
        .init(id: "rust", label: "Rust"),
        .init(id: "typescript", label: "TypeScript"),
        .init(id: "go", label: "Go"),
        .init(id: "kotlin", label: "Kotlin"),
    ]

    var body: some View {
        ShowcaseScreen(title: "Combobox") {
            ZenCard(title: "Multi-Select", subtitle: "Search and select multiple items") {
                ZenCombobox(
                    selection: $selection,
                    options: languages,
                    placeholder: "Select languages...",
                    label: "Languages"
                )
            }

            ZenCard(title: "Selected", subtitle: "Current selection") {
                Text(selection.sorted().joined(separator: ", "))
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }
}
