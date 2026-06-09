import SwiftUI
import ZenKit

struct TextShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Text") {
            ZenCard(title: "Variants", subtitle: "Semantic text styles") {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenText("Heading 1", variant: .heading1)
                    ZenText("Heading 2", variant: .heading2)
                    ZenText("Heading 3", variant: .heading3)
                    ZenText("Body text", variant: .body)
                    ZenText("Secondary text", variant: .secondary)
                }
            }

            ZenCard(title: "Status Variants", subtitle: "Success, danger, and mono") {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenText("Success message", variant: .success)
                    ZenText("Danger message", variant: .danger)
                    ZenText("Monospaced code", variant: .mono)
                }
            }

            ZenCard(title: "Sizes", subtitle: "xs, sm, base, lg") {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenText("Extra small text", size: .xs)
                    ZenText("Small text", size: .sm)
                    ZenText("Base text", size: .base)
                    ZenText("Large text", size: .lg)
                }
            }
        }
    }
}
