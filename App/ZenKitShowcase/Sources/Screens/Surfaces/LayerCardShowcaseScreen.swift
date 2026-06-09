import SwiftUI
import ZenKit

struct LayerCardShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Layer Card") {
            ZenCard(title: "With Secondary", subtitle: "Header + content sections") {
                ZenLayerCard {
                    VStack(alignment: .leading, spacing: ZenSpacing.small) {
                        Text("Primary Content")
                            .font(.zenBody)
                            .foregroundStyle(Color.zenTextPrimary)
                        Text("This is the main content area of the card.")
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                } secondary: {
                    Text("Secondary Header")
                        .font(.zen(.group, weight: .semibold))
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            ZenCard(title: "Primary Only", subtitle: "Without secondary section") {
                ZenLayerCard {
                    Text("Simple card content")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                }
            }
        }
    }
}
