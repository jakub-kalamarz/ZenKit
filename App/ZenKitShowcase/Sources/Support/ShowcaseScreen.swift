import SwiftUI
import ZenKit

struct ShowcaseScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ZenScreen(navigationTitle: title) {
            content
                .padding(.horizontal, ZenSpacing.large)
        }
    }
}
