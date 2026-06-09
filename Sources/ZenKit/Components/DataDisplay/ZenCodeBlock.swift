import SwiftUI

public struct ZenCodeBlock: View {
    private let code: String
    private let language: String?
    private let showLineNumbers: Bool
    @State private var copied = false

    public init(_ code: String, language: String? = nil, showLineNumbers: Bool = false) {
        self.code = code
        self.language = language
        self.showLineNumbers = showLineNumbers
    }

    public var body: some View {
        let cornerRadius = ZenTheme.current.resolvedCornerRadius

        VStack(alignment: .leading, spacing: 0) {
            if language != nil || true {
                header
                Divider().foregroundStyle(Color.zenBorderSubtle)
            }

            HStack(alignment: .top, spacing: 0) {
                if showLineNumbers {
                    lineNumbers
                        .padding(.leading, 12)
                        .padding(.vertical, 12)

                    Rectangle()
                        .fill(Color.zenBorderSubtle)
                        .frame(width: 1)
                        .padding(.vertical, 12)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    codeLines
                        .padding(12)
                }
            }
        }
        .background(Color.zenSurfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            if let language {
                Text(language)
                    .font(.zen(.group, weight: .medium))
                    .foregroundStyle(Color.zenTextMuted)
            }

            Spacer()

            Button {
                copyToClipboard()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11, weight: .medium))
                        .frame(width: 16, height: 16)
                    Text(copied ? "Copied" : "Copy")
                        .font(.zen(.group, weight: .medium))
                }
                .foregroundStyle(copied ? Color.zenSuccess : Color.zenTextMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var lines: [String] {
        code.components(separatedBy: "\n")
    }

    private var lineNumbers: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, _ in
                Text("\(index + 1)")
                    .font(.zenGroup.monospaced())
                    .foregroundStyle(Color.zenTextMuted.opacity(0.5))
                    .frame(minWidth: 12, alignment: .trailing)
            }
        }
        .padding(.trailing, 12)
    }

    private var codeLines: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line.isEmpty ? " " : line)
                    .font(.zenBody2.monospaced())
                    .foregroundStyle(Color.zenTextPrimary)
            }
        }
    }

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = code
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #endif

        withAnimation { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { copied = false }
        }
    }
}

#Preview("ZenCodeBlock") {
    VStack(spacing: ZenSpacing.medium) {
        ZenCodeBlock("""
        let greeting = "Hello, World!"
        print(greeting)
        """, language: "Swift")

        ZenCodeBlock("""
        func fibonacci(_ n: Int) -> Int {
            guard n > 1 else { return n }
            return fibonacci(n - 1) + fibonacci(n - 2)
        }
        """, language: "Swift", showLineNumbers: true)
    }
    .padding()
    .background(Color.zenBackground)
}
