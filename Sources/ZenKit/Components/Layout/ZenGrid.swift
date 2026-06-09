import SwiftUI

public enum ZenGridColumns {
    case fixed(Int)
    case adaptive(minimum: CGFloat)

    var gridItems: [GridItem] {
        switch self {
        case .fixed(let count):
            return Array(repeating: GridItem(.flexible(), spacing: ZenSpacing.medium), count: count)
        case .adaptive(let minimum):
            return [GridItem(.adaptive(minimum: minimum), spacing: ZenSpacing.medium)]
        }
    }
}

public struct ZenGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    private let data: Data
    private let columns: ZenGridColumns
    private let spacing: CGFloat
    private let content: (Data.Element) -> Content

    public init(
        _ data: Data,
        columns: ZenGridColumns = .adaptive(minimum: 160),
        spacing: CGFloat = ZenSpacing.medium,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        LazyVGrid(columns: columns.gridItems, spacing: spacing) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

#Preview("ZenGrid") {
    struct Item: Identifiable {
        let id: Int
        let title: String
    }

    let items = (1...8).map { Item(id: $0, title: "Item \($0)") }

    return ScrollView {
        ZenGrid(items, columns: .fixed(3)) { item in
            ZenCard {
                Text(item.title)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(ZenSpacing.medium)
            }
        }
        .padding()
    }
    .background(Color.zenBackground)
}
