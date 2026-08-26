import SwiftUI
import ZenKit

struct TooltipShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Tooltip") {
            ZenCard(title: "Basic", subtitle: "Long-press to show tooltip") {
                HStack(spacing: ZenSpacing.large) {
                    ZenTooltip("This is a save button") {
                        ZenIcon(icon: .squareAndArrowDown)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.zenTextMuted)
                    }

                    ZenTooltip("Share this item") {
                        ZenIcon(icon: .squareAndArrowUp)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.zenTextMuted)
                    }

                    ZenTooltip("Delete permanently") {
                        ZenIcon(icon: .trash)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.zenCritical)
                    }
                }
            }
        }
    }
}
