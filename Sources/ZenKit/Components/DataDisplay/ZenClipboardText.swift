import SwiftUI

public struct ZenClipboardText: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    private let text: String
    private let size: ZenClipboardTextSize
    @State private var copied = false

    public enum ZenClipboardTextSize: Sendable {
        case sm
        case base
        case lg
        /// Full-width control-height surface that lines up with `ZenTextInput`
        /// when placed in the same form (e.g. a read-only value next to inputs).
        case field
    }

    public init(_ text: String, size: ZenClipboardTextSize = .base) {
        self.text = text
        self.size = size
    }

    public var body: some View {
        #if DEBUG
        #endif
        switch size {
        case .sm, .base, .lg:
            inlineBody
        case .field:
            fieldBody
        }
    }

    private var inlineBody: some View {
        HStack(spacing: ZenSpacing.small) {
            label

            copyButton
        }
        .padding(.horizontal, ZenSpacing.small)
        .padding(.vertical, ZenSpacing.xSmall)
        .background(Color.zenSurfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var fieldBody: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let controlStyle = ZenControlSurfaceStyle.field(theme: theme)

        return HStack(spacing: ZenSpacing.small) {
            label
                .frame(maxWidth: .infinity, alignment: .leading)

            copyButton
        }
        .padding(.horizontal, 12)
        .frame(
            maxWidth: .infinity,
            minHeight: theme.resolvedMetrics.controlHeight,
            maxHeight: theme.resolvedMetrics.controlHeight,
            alignment: .leading
        )
        .background(controlStyle.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(controlStyle.borderColor, lineWidth: controlStyle.borderWidth)
        )
        .zenControlSurfaceShadow()
    }

    private var label: some View {
        Text(text)
            .font(resolvedFont)
            .foregroundStyle(Color.zenTextPrimary)
            .lineLimit(1)
            .truncationMode(.middle)
    }

    private var copyButton: some View {
        Button {
            copyToClipboard()
        } label: {
            ZenIcon(icon: copied ? .checkmark : .docOnDoc, size: 16)
                .font(.zen(.group, weight: .medium))
                .foregroundStyle(copied ? Color.zenSuccess : Color.zenTextMuted)
        }
        .buttonStyle(.plain)
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
        case .sm: return .zenGroup.monospaced().width(.condensed)
        case .base, .field: return .zenBody2.monospaced().width(.condensed)
        case .lg: return .zenBody.monospaced().width(.condensed)
        }
    }

}

#Preview("ZenClipboardText") {
    VStack(spacing: ZenSpacing.medium) {
        ZenClipboardText("sk-1234567890abcdef", size: .sm)
        ZenClipboardText("npm install @cloudflare/kumo")
        ZenClipboardText("192.168.1.100", size: .lg)
        ZenClipboardText("https://geteggo.com/join/282aa6326c4fa037", size: .field)
        ZenTextInput(text: .constant(""), prompt: "Compare with input")
    }
    .padding()
    .background(Color.zenBackground)
}
