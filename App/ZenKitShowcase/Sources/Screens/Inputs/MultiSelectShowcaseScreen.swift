import SwiftUI
import ZenKit

struct MultiSelectShowcaseScreen: View {
    private enum Column: String, CaseIterable, Hashable, Sendable {
        case name = "Name"
        case owner = "Owner"
        case status = "Status"
        case updated = "Updated"
    }

    private enum Filter: String, CaseIterable, Hashable, Sendable {
        case mine = "Mine"
        case active = "Active"
        case archived = "Archived"
        case flagged = "Flagged"
    }

    @State private var selectedColumns: Set<Column> = [.name, .status]
    @State private var selectedFilters: Set<Filter> = [.mine]
    @State private var selectedCompactFilters: Set<Filter> = [.mine, .active, .flagged]

    var body: some View {
        ShowcaseScreen(title: "Multi Select") {
            ZenCard(title: "Immediate Mode", subtitle: "Best for lightweight filters and visible columns") {
                VStack(spacing: ZenSpacing.small) {
                    ZenMultiSelect(
                        title: "Columns",
                        selection: $selectedColumns,
                        options: Column.allCases
                    ) { option in
                        Text(option.rawValue)
                    }

                    Text("Selected: \(selectedColumns.map(\.rawValue).sorted().joined(separator: ", "))")
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            ZenCard(title: "Deferred Mode", subtitle: "Useful when the user should review changes before applying") {
                VStack(spacing: ZenSpacing.small) {
                    ZenMultiSelect(
                        title: "Filters",
                        selection: $selectedFilters,
                        options: Filter.allCases,
                        mode: .deferred
                    ) { option in
                        Text(option.rawValue)
                    }

                    Text("Applied: \(selectedFilters.map(\.rawValue).sorted().joined(separator: ", "))")
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }

            ZenCard(title: "Custom Summary", subtitle: "Override the default trigger summary when a numeric badge reads better") {
                ZenMultiSelect(
                    title: "Compact filters",
                    selection: $selectedCompactFilters,
                    options: Filter.allCases
                ) { option in
                    Text(option.rawValue)
                } summaryLabel: { selected in
                    Text("\(selected.count) selected")
                }
            }
        }
    }
}
