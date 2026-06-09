import SwiftUI
import ZenKit

private struct GridItem: Identifiable {
    let id: Int
    let title: String
    let color: Color
}

struct GridShowcaseScreen: View {
    private let items = (1...6).map {
        GridItem(id: $0, title: "Item \($0)", color: [Color.zenPrimary, .zenSuccess, .zenWarning, .zenCritical, .zenPrimary, .zenSuccess][$0 - 1])
    }

    var body: some View {
        ShowcaseScreen(title: "Grid") {
            ZenCard(title: "Fixed Columns", subtitle: "3-column grid") {
                ZenGrid(items, columns: .fixed(3)) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.color.opacity(0.2))
                            .frame(height: 60)
                        Text(item.title)
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextPrimary)
                    }
                }
            }

            ZenCard(title: "Adaptive", subtitle: "Minimum 120pt width") {
                ZenGrid(items, columns: .adaptive(minimum: 120)) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.color.opacity(0.2))
                            .frame(height: 60)
                        Text(item.title)
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextPrimary)
                    }
                }
            }
        }
    }
}
