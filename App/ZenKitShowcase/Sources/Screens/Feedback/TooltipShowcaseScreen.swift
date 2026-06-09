import SwiftUI
import ZenKit

struct TooltipShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Tooltip") {
            ZenCard(title: "Basic", subtitle: "Long-press to show tooltip") {
                HStack(spacing: ZenSpacing.large) {
                    ZenTooltip("This is a save button") {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.zenTextMuted)
                    }

                    ZenTooltip("Share this item") {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.zenTextMuted)
                    }

                    ZenTooltip("Delete permanently") {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.zenCritical)
                    }
                }
            }
        }
    }
}
