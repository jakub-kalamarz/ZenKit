import SwiftUI
import ZenKit

struct ClipboardTextShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Clipboard Text") {
            ZenCard(title: "Basic", subtitle: "Tap copy button to copy text") {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    ZenClipboardText("sk-proj-abc123def456")
                    ZenClipboardText("192.168.1.100")
                    ZenClipboardText("npm install zenkit")
                }
            }
        }
    }
}
