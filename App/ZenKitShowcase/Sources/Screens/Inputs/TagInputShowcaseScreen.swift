import SwiftUI
import ZenKit

struct TagInputShowcaseScreen: View {
    @State private var skillTags = ["Swift", "SwiftUI"]
    @State private var labelTags: [String] = []
    @State private var projectTags = ["ios", "design-system", "components"]

    var body: some View {
        ShowcaseScreen(title: "Tag Input") {
            ZenCard(title: "Basic", subtitle: "Add and remove tags") {
                ZenTagInput(tags: $skillTags, prompt: "Add skill…")
            }

            ZenCard(title: "Empty", subtitle: "Starts with no tags") {
                ZenTagInput(tags: $labelTags, prompt: "Add label…")
            }

            ZenCard(title: "Pre-populated", subtitle: "Project tags") {
                ZenTagInput(tags: $projectTags, prompt: "Add tag…")
            }
        }
    }
}
