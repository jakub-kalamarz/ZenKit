import SwiftUI

public struct ZenClipboardText: View {
    private let text: String
    private let size: ZenClipboardTextSize
    @State private var copied = false

    public enum ZenClipboardTextSize: Sendable {
        case sm
        case base
        case lg
    }

    public init(_ text: String, size: ZenClipboardTextSize = .base) {
        self.text = text
        self.size = size
    }

    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        HStack(spacing: ZenSpacing.small) {
            Text(text)
                .font(resolvedFont)
                .foregroundStyle(Color.zenTextPrimary)
                .lineLimit(1)
                .truncationMode(.middle)

            Button {
                copyToClipboard()
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.zen(.group, weight: .medium))
                    .foregroundStyle(copied ? Color.zenSuccess : Color.zenTextMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, ZenSpacing.small)
        .padding(.vertical, ZenSpacing.xSmall)
        .background(Color.zenSurfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        withAnimation {
            copied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copied = false
            }
        }
    }

    private var resolvedFont: Font {
        switch size {
        case .sm: return .zenGroup.monospaced()
        case .base: return .zenBody2.monospaced()
        case .lg: return .zenBody.monospaced()
        }
    }

}

#Preview("ZenClipboardText") {
    VStack(spacing: ZenSpacing.medium) {
        ZenClipboardText("sk-1234567890abcdef", size: .sm)
        ZenClipboardText("npm install @cloudflare/kumo")
        ZenClipboardText("192.168.1.100", size: .lg)
    }
    .padding()
    .background(Color.zenBackground)
}
