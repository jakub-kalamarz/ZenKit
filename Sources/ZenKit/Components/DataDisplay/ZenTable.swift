import SwiftUI

public struct ZenTableColumn<Row> {
    public let id: String
    public let title: String
    public let width: ZenTableColumnWidth
    public let alignment: HorizontalAlignment
    public let content: (Row) -> AnyView

    public init<Content: View>(
        id: String,
        title: String,
        width: ZenTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Row) -> Content
    ) {
        self.id = id
        self.title = title
        self.width = width
        self.alignment = alignment
        self.content = { AnyView(content($0)) }
    }
}

public enum ZenTableColumnWidth {
    case flexible
    case fixed(CGFloat)
}

public struct ZenTable<Row: Identifiable>: View {
    private let rows: [Row]
    private let columns: [ZenTableColumn<Row>]
    private let selectable: Bool
    private let maxHeight: CGFloat?
    @Binding private var selection: Set<Row.ID>

    /// - Parameter maxHeight: When set, rows scroll internally above this height;
    ///   when `nil` (default) the table sizes to its content and the enclosing
    ///   scroll view handles overflow.
    public init(
        rows: [Row],
        columns: [ZenTableColumn<Row>],
        selectable: Bool = false,
        selection: Binding<Set<Row.ID>> = .constant([]),
        maxHeight: CGFloat? = nil
    ) {
        self.rows = rows
        self.columns = columns
        self.selectable = selectable
        self.maxHeight = maxHeight
        self._selection = selection
    }

    public var body: some View {
        let cornerRadius = ZenTheme.current.resolvedCornerRadius

        VStack(spacing: 0) {
            headerRow

            Divider()
                .foregroundStyle(Color.zenBorderSubtle)

            if maxHeight != nil {
                ScrollView { rowsStack }
                    .frame(maxHeight: maxHeight)
            } else {
                rowsStack
            }
        }
        .background(Color.zenSurface)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
        )
    }

    private var rowsStack: some View {
        LazyVStack(spacing: 0) {
            ForEach(rows) { row in
                VStack(spacing: 0) {
                    dataRow(row)

                    Divider()
                        .foregroundStyle(Color.zenBorderSubtle)
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            if selectable {
                selectAllCheckbox
                    .frame(width: 44)
            }

            ForEach(columns, id: \.id) { column in
                Text(column.title)
                    .font(.zen(.group, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
                    .frame(maxWidth: maxWidth(for: column), alignment: Alignment(horizontal: column.alignment, vertical: .center))
                    .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 10)
        .background(Color.zenSurfaceMuted)
    }

    private func dataRow(_ row: Row) -> some View {
        HStack(spacing: 0) {
            if selectable {
                rowCheckbox(row)
                    .frame(width: 44)
            }

            ForEach(columns, id: \.id) { column in
                column.content(row)
                    .frame(maxWidth: maxWidth(for: column), alignment: Alignment(horizontal: column.alignment, vertical: .center))
                    .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 10)
        .background(selection.contains(row.id) ? Color.zenPrimary.opacity(0.06) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            guard selectable else { return }
            toggleSelection(row.id)
        }
    }

    private var selectAllCheckbox: some View {
        Button {
            if selection.count == rows.count {
                selection.removeAll()
            } else {
                selection = Set(rows.map(\.id))
            }
        } label: {
            ZenIcon(
                systemName: allSelected ? "checkmark.square.fill" : (selection.isEmpty ? "square" : "minus.square.fill"),
                size: 16
            )
                .foregroundStyle(allSelected || !selection.isEmpty ? Color.zenPrimary : Color.zenTextMuted)
        }
        .buttonStyle(.plain)
    }

    private func rowCheckbox(_ row: Row) -> some View {
        Button {
            toggleSelection(row.id)
        } label: {
            ZenIcon(
                systemName: selection.contains(row.id) ? "checkmark.square.fill" : "square",
                size: 16
            )
                .foregroundStyle(selection.contains(row.id) ? Color.zenPrimary : Color.zenTextMuted)
        }
        .buttonStyle(.plain)
    }

    private var allSelected: Bool {
        !rows.isEmpty && selection.count == rows.count
    }

    private func toggleSelection(_ id: Row.ID) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }

    private func maxWidth(for column: ZenTableColumn<Row>) -> CGFloat? {
        switch column.width {
        case .flexible:
            return .infinity
        case .fixed(let w):
            return w
        }
    }
}

#Preview("ZenTable") {
    struct User: Identifiable {
        let id: Int
        let name: String
        let email: String
        let role: String
    }

    struct TablePreview: View {
        @State private var selection: Set<Int> = []

        let users = [
            User(id: 1, name: "Alice", email: "alice@example.com", role: "Admin"),
            User(id: 2, name: "Bob", email: "bob@example.com", role: "Editor"),
            User(id: 3, name: "Charlie", email: "charlie@example.com", role: "Viewer"),
        ]

        var body: some View {
            ZenTable(
                rows: users,
                columns: [
                    ZenTableColumn(id: "name", title: "Name") { user in
                        Text(user.name)
                            .font(.zenBody)
                            .foregroundStyle(Color.zenTextPrimary)
                    },
                    ZenTableColumn(id: "email", title: "Email") { user in
                        Text(user.email)
                            .font(.zenBody)
                            .foregroundStyle(Color.zenTextMuted)
                    },
                    ZenTableColumn(id: "role", title: "Role", width: .fixed(100)) { user in
                        ZenBadge(LocalizedStringKey(user.role))
                    },
                ],
                selectable: true,
                selection: $selection
            )
            .padding()
            .background(Color.zenBackground)
        }
    }

    return TablePreview()
}
