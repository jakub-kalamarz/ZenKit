import SwiftUI
import ZenKit

struct LinkShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Link") {
            ZenCard(title: "Variants", subtitle: "Inline, current, and plain") {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenLink("Inline link", variant: .inline, action: {})
                    ZenLink("Current page", variant: .current, action: {})
                    ZenLink("Plain link", variant: .plain, action: {})
                }
            }

            ZenCard(title: "With URL", subtitle: "Opens in Safari") {
                ZenLink("Visit Example", url: URL(string: "https://example.com")!)
            }
        }
    }
}
