import SwiftUI
import ZenKit

struct ShowcaseScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZenSpacing.large) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ZenSpacing.large)
        }
        .background(Color.zenBackground)
        .navigationTitle(title)
    }
}
