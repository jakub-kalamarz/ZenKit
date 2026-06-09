import SwiftUI
import ZenKit

struct SearchBarShowcaseScreen: View {
    @State private var globalQuery = ""
    @State private var memberQuery = ""
    @State private var commandQuery = ""

    var body: some View {
        ShowcaseScreen(title: "Search Bar") {
            ZenCard(title: "Basic", subtitle: "Default search input") {
                ZenSearchBar(text: $globalQuery)
            }

            ZenCard(title: "Custom Prompt", subtitle: "Contextual placeholder text") {
                VStack(spacing: ZenSpacing.small) {
                    ZenSearchBar(text: $memberQuery, prompt: "Search members…")
                    ZenSearchBar(text: $commandQuery, prompt: "Search commands and settings")
                }
            }

            if !globalQuery.isEmpty {
                ZenCard(title: "Live Result", subtitle: "Reflects the first search field") {
                    Text("Query: \(globalQuery)")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
    }
}
