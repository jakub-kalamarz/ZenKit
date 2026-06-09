import SwiftUI
import ZenKit

struct AutocompleteShowcaseScreen: View {
    @State private var query = ""

    private let countries: [ZenAutocompleteItem] = [
        .init(id: "us", label: "United States"),
        .init(id: "uk", label: "United Kingdom"),
        .init(id: "de", label: "Germany"),
        .init(id: "fr", label: "France"),
        .init(id: "jp", label: "Japan"),
        .init(id: "au", label: "Australia"),
    ]

    var body: some View {
        ShowcaseScreen(title: "Autocomplete") {
            ZenCard(title: "Basic", subtitle: "Type to filter suggestions") {
                ZenAutocomplete(
                    text: $query,
                    placeholder: "Search countries...",
                    label: "Country",
                    items: countries
                )
            }
        }
    }
}
