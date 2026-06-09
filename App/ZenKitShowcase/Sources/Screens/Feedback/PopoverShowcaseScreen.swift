import SwiftUI
import ZenKit

struct PopoverShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Popover") {
            ZenCard(title: "Basic", subtitle: "Floating panel from trigger") {
                ZenPopover {
                    Text("Tap me")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenPrimary)
                } content: {
                    VStack(alignment: .leading, spacing: ZenSpacing.small) {
                        Text("Popover Content")
                            .font(.zenBody)
                            .foregroundStyle(Color.zenTextPrimary)
                        Text("This is a floating panel.")
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            ZenCard(title: "Icon Trigger", subtitle: "Info icon popover") {
                ZenPopover {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.zenPrimary)
                } content: {
                    Text("Helpful information goes here.")
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextPrimary)
                }
            }
        }
    }
}
