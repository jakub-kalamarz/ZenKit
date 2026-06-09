import SwiftUI

public struct ZenCommandItem: Identifiable {
    public let id: String
    public let label: String
    public let icon: String?
    public let group: String?
    public let shortcut: String?
    public let action: () -> Void

    public init(
        id: String = UUID().uuidString,
        label: String,
        icon: String? = nil,
        group: String? = nil,
        shortcut: String? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.group = group
        self.shortcut = shortcut
        self.action = action
    }
}

public struct ZenCommandPalette: View {
    @Binding private var isPresented: Bool
    private let items: [ZenCommandItem]
    private let placeholder: String
    @State private var query = ""
    @State private var highlightedIndex = 0

    public init(
        isPresented: Binding<Bool>,
        items: [ZenCommandItem],
        placeholder: String = "Search commands..."
    ) {
        self._isPresented = isPresented
        self.items = items
        self.placeholder = placeholder
    }

    private var filteredItems: [ZenCommandItem] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.label.localizedCaseInsensitiveContains(query) }
    }

    private var groupedItems: [(String?, [ZenCommandItem])] {
        let filtered = filteredItems
        var groups: [(String?, [ZenCommandItem])] = []
        var seen: Set<String> = []

        for item in filtered {
            let key = item.group ?? ""
            if !seen.contains(key) {
                seen.insert(key)
                let groupItems = filtered.filter { ($0.group ?? "") == key }
                groups.append((item.group, groupItems))
            }
        }
        return groups
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                searchField

                Divider().foregroundStyle(Color.zenBorderSubtle)

                resultsList
            }
            .frame(maxWidth: 560)
            .background(Color.zenSurface)
            .clipShape(RoundedRectangle(cornerRadius: ZenRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ZenRadius.medium, style: .continuous)
                    .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
            )
            .shadow(
                color: ZenShadow.md.color,
                radius: ZenShadow.md.radius,
                x: ZenShadow.md.x,
                y: ZenShadow.md.y
            )
            .padding(.horizontal, 24)
            .padding(.top, 80)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var searchField: some View {
        HStack(spacing: ZenSpacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.zenTextMuted)

            TextField(placeholder, text: $query)
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
                .textFieldStyle(.plain)
                .onChange(of: query) { _ in
                    highlightedIndex = 0
                }

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if filteredItems.isEmpty {
                    Text("No results found")
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(groupedItems, id: \.0) { group, groupItems in
                        if let group {
                            Text(group)
                                .font(.zen(.group, weight: .semibold))
                                .foregroundStyle(Color.zenTextMuted)
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                                .padding(.bottom, 4)
                        }

                        ForEach(groupItems) { item in
                            commandRow(item)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
        .frame(maxHeight: 340)
    }

    private func commandRow(_ item: ZenCommandItem) -> some View {
        Button {
            item.action()
            dismiss()
        } label: {
            HStack(spacing: ZenSpacing.small) {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(width: 20)
                }

                Text(item.label)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextPrimary)

                Spacer()

                if let shortcut = item.shortcut {
                    Text(shortcut)
                        .font(.zen(.group, weight: .medium))
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.zenSurfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func dismiss() {
        query = ""
        isPresented = false
    }
}

#Preview("ZenCommandPalette") {
    struct CommandPalettePreview: View {
        @State private var isPresented = true

        var body: some View {
            ZStack {
                Color.zenBackground.ignoresSafeArea()

                Button("Open Command Palette") {
                    isPresented = true
                }

                if isPresented {
                    ZenCommandPalette(
                        isPresented: $isPresented,
                        items: [
                            .init(label: "New File", icon: "doc.badge.plus", group: "File", shortcut: "⌘N", action: {}),
                            .init(label: "Open File", icon: "folder", group: "File", shortcut: "⌘O", action: {}),
                            .init(label: "Save", icon: "square.and.arrow.down", group: "File", shortcut: "⌘S", action: {}),
                            .init(label: "Find", icon: "magnifyingglass", group: "Edit", shortcut: "⌘F", action: {}),
                            .init(label: "Replace", icon: "arrow.left.arrow.right", group: "Edit", shortcut: "⌘H", action: {}),
                            .init(label: "Toggle Sidebar", icon: "sidebar.left", group: "View", shortcut: "⌘\\", action: {}),
                        ]
                    )
                }
            }
        }
    }

    return CommandPalettePreview()
}
