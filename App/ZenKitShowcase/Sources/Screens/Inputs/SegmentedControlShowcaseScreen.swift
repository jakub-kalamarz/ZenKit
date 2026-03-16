import SwiftUI
import ZenKit

struct SegmentedControlShowcaseScreen: View {
    private enum Range: String, CaseIterable {
        case week = "7D"
        case month = "28D"
        case quarter = "3M"
        case year = "1Y"
    }

    @State private var rangeSelection: Range = .quarter
    @State private var viewSelection = "List"

    var body: some View {
        ShowcaseScreen(title: "Segmented Control") {
            ZenCard(title: "String Segments", subtitle: "Text-only segments") {
                ZenSegmentedControl(
                    title: "View",
                    selection: $viewSelection,
                    segments: ["List", "Grid", "Board"]
                )
            }

            ZenCard(title: "Enum Segments", subtitle: "RawValue enum segments") {
                ZenSegmentedControl(
                    title: "Range",
                    selection: $rangeSelection,
                    segments: Range.allCases
                )
            }

            ZenCard(title: "With Disabled", subtitle: "Some segments disabled") {
                ZenSegmentedControl(
                    title: "Range",
                    selection: $rangeSelection,
                    segments: Range.allCases,
                    disabledSegments: [.year]
                )
            }
        }
    }
}
