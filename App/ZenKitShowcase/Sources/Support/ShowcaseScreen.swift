import SwiftUI

struct ShowcaseScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title)
    }
}
