import SwiftUI

public struct ZenMenubarItem: Identifiable {
    public let id: String
    public let icon: String
    public let label: String?
    public let action: () -> Void

    public init(id: String = UUID().uuidString, icon: String, label: String? = nil, action: @escaping () -> Void) {
        self.id = id
        self.icon = icon
        self.label = label
        self.action = action
    }
}

public struct ZenMenubar: View {
    private let items: [ZenMenubarItem]
    private let selectedId: String?

    public init(items: [ZenMenubarItem], selectedId: String? = nil) {
        self.items = items
        self.selectedId = selectedId
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(items) { item in
                Button(action: item.action) {
                    VStack(spacing: 2) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16, weight: .medium))

                        if let label = item.label {
                            Text(label)
                                .font(.system(size: 10, weight: .medium))
                        }
                    }
                    .foregroundStyle(item.id == selectedId ? Color.zenPrimary : Color.zenTextMuted)
                    .frame(width: 40, height: 40)
                    .background(
                        item.id == selectedId
                            ? Color.zenPrimary.opacity(0.1)
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.label ?? item.icon)
            }
        }
        .padding(4)
        .background(Color.zenSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
        )
    }
}

#Preview("ZenMenubar") {
    ZenMenubar(
        items: [
            .init(id: "bold", icon: "bold", action: {}),
            .init(id: "italic", icon: "italic", action: {}),
            .init(id: "underline", icon: "underline", action: {}),
            .init(id: "strikethrough", icon: "strikethrough", action: {}),
            .init(id: "link", icon: "link", action: {}),
        ],
        selectedId: "bold"
    )
    .padding()
    .background(Color.zenBackground)
}
