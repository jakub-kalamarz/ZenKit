import SwiftUI
import ZenKit

struct PaginationShowcaseScreen: View {
    @State private var currentPage = 5

    var body: some View {
        ShowcaseScreen(title: "Pagination") {
            ZenCard(title: "Full", subtitle: "With page numbers") {
                ZenPagination(currentPage: $currentPage, totalPages: 20, style: .full)
            }

            ZenCard(title: "Simple", subtitle: "Just prev/next with label") {
                ZenPagination(currentPage: $currentPage, totalPages: 20, style: .simple)
            }

            ZenCard(title: "Few Pages", subtitle: "All numbers visible") {
                ZenPagination(currentPage: .constant(3), totalPages: 5, style: .full)
            }
        }
    }
}
