import SwiftUI

public struct ZenTOCItem: Identifiable {
    public let id: String
    public let label: String
    public let level: Int

    public init(id: String, label: String, level: Int = 0) {
        self.id = id
        self.label = label
        self.level = level
    }
}

public struct ZenTableOfContents: View {
    private let items: [ZenTOCItem]
    @Binding private var activeId: String?
    private let onSelect: ((String) -> Void)?

    public init(
        items: [ZenTOCItem],
        activeId: Binding<String?> = .constant(nil),
        onSelect: ((String) -> Void)? = nil
    ) {
        self.items = items
        self._activeId = activeId
        self.onSelect = onSelect
    }

    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                let isActive = item.id == activeId

                Button {
                    activeId = item.id
                    onSelect?(item.id)
                } label: {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(isActive ? Color.zenPrimary : Color.clear)
                            .frame(width: 2)

                        Text(item.label)
                            .font(.zenBody2)
                            .foregroundStyle(isActive ? Color.zenPrimary : Color.zenTextMuted)
                            .lineLimit(1)
                            .padding(.leading, 12 + CGFloat(item.level) * 12)
                            .padding(.vertical, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.zenBorderSubtle)
                .frame(width: 1)
        }
    }
}

#Preview("ZenTableOfContents") {
    struct TOCPreview: View {
        @State private var active: String? = "overview"

        var body: some View {
            ZenTableOfContents(
                items: [
                    .init(id: "overview", label: "Overview"),
                    .init(id: "installation", label: "Installation"),
                    .init(id: "npm", label: "npm", level: 1),
                    .init(id: "yarn", label: "yarn", level: 1),
                    .init(id: "usage", label: "Usage"),
                    .init(id: "api", label: "API Reference"),
                    .init(id: "faq", label: "FAQ"),
                ],
                activeId: $active
            )
            .frame(width: 200)
            .padding()
            .background(Color.zenBackground)
        }
    }

    return TOCPreview()
}
