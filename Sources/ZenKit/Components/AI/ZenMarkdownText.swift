import SwiftUI

/// Renders a Markdown string as a stack of native SwiftUI blocks.
///
/// `Text` on its own only understands inline Markdown (bold, italic, links,
/// inline code) and flattens everything else into one paragraph. Agent replies
/// lean heavily on headings, lists and code blocks, so this view parses the
/// full syntax and lays each block out with the ZenKit type scale.
public struct ZenMarkdownText: View {
    private let blocks: [Block]

    public init(_ markdown: String) {
        blocks = Self.parse(markdown)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        switch block {
        case .paragraph(let text):
            Text(text)
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        case .heading(let level, let text):
            Text(text)
                .font(level <= 2 ? .zenTitle : .zen(.body, weight: .semibold))
                .foregroundStyle(Color.zenTextPrimary)
                .padding(.top, ZenSpacing.xSmall)
        case .listItem(let marker, let depth, let text):
            HStack(alignment: .firstTextBaseline, spacing: ZenSpacing.xSmall) {
                Text(marker)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextMuted)
                    .frame(minWidth: 16, alignment: .trailing)
                Text(text)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextPrimary)
            }
            .padding(.leading, CGFloat(depth) * ZenSpacing.medium)
        case .codeBlock(let code):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(Color.zenTextPrimary)
                    .padding(ZenSpacing.small)
            }
            .background(Color.zenSurfaceMuted, in: RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous))
        case .quote(let text):
            HStack(alignment: .top, spacing: ZenSpacing.small) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.zenBorder)
                    .frame(width: 3)
                Text(text)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextMuted)
            }
        case .divider:
            Divider()
        }
    }

    // MARK: - Parsing

    enum Block: Equatable {
        case paragraph(AttributedString)
        case heading(level: Int, AttributedString)
        case listItem(marker: String, depth: Int, AttributedString)
        case codeBlock(String)
        case quote(AttributedString)
        case divider
    }

    static func parse(_ markdown: String) -> [Block] {
        guard let attributed = try? AttributedString(
            markdown: markdown,
            options: .init(
                allowsExtendedAttributes: false,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        ) else {
            return [.paragraph(AttributedString(markdown))]
        }

        var blocks: [Block] = []
        var currentIntent: PresentationIntent?
        var currentText = AttributedString()

        func flush() {
            defer { currentText = AttributedString(); currentIntent = nil }
            guard let intent = currentIntent else {
                if !currentText.characters.isEmpty { blocks.append(.paragraph(currentText)) }
                return
            }
            currentText.presentationIntent = nil
            var listItems: [(ordinal: Int, isOrdered: Bool)] = []
            var isQuote = false
            var kind: Block?

            // Components run innermost → outermost, so the first block-level hit wins
            // and every list item is followed by the list that contains it.
            let components = intent.components
            for (index, component) in components.enumerated() {
                switch component.kind {
                case .header(let level):
                    kind = kind ?? .heading(level: level, currentText)
                case .codeBlock:
                    kind = kind ?? .codeBlock(String(currentText.characters).trimmingCharacters(in: .newlines))
                case .thematicBreak:
                    kind = kind ?? .divider
                case .listItem(let ordinal):
                    let isOrdered: Bool
                    if index + 1 < components.count, case .orderedList = components[index + 1].kind {
                        isOrdered = true
                    } else {
                        isOrdered = false
                    }
                    listItems.append((ordinal, isOrdered))
                case .blockQuote:
                    isQuote = true
                default:
                    break
                }
            }

            let marker = listItems.first.map { $0.isOrdered ? "\($0.ordinal)." : "•" }
            let depth = max(listItems.count - 1, 0)

            if let kind {
                blocks.append(kind)
            } else if let marker {
                blocks.append(.listItem(marker: marker, depth: depth, currentText))
            } else if isQuote {
                blocks.append(.quote(currentText))
            } else if !currentText.characters.isEmpty {
                blocks.append(.paragraph(currentText))
            }
        }

        for run in attributed.runs {
            let intent = run.presentationIntent
            if intent != currentIntent, !(currentText.characters.isEmpty && currentIntent == nil) {
                flush()
            }
            currentIntent = intent
            currentText.append(attributed[run.range])
        }
        flush()
        return blocks
    }
}
