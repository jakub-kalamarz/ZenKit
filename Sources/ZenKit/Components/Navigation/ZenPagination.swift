import SwiftUI

public enum ZenPaginationStyle {
    case simple
    case full
}

public struct ZenPagination: View {
    @Binding private var currentPage: Int
    private let totalPages: Int
    private let style: ZenPaginationStyle
    private let onPageChange: ((Int) -> Void)?

    @Namespace private var selectionNamespace

    public init(
        currentPage: Binding<Int>,
        totalPages: Int,
        style: ZenPaginationStyle = .full,
        onPageChange: ((Int) -> Void)? = nil
    ) {
        self._currentPage = currentPage
        self.totalPages = max(totalPages, 1)
        self.style = style
        self.onPageChange = onPageChange
    }

    public var body: some View {
        #if DEBUG
        #endif
        HStack(spacing: ZenSpacing.small) {
            navButton(systemName: "chevron.left", enabled: currentPage > 1) {
                setPage(currentPage - 1)
            }

            if style == .full {
                pageNumbers
            } else {
                Text("Page \(currentPage) of \(totalPages)")
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextMuted)
                    .contentTransition(.numericText())
            }

            navButton(systemName: "chevron.right", enabled: currentPage < totalPages) {
                setPage(currentPage + 1)
            }
        }
    }

    @ViewBuilder
    private var pageNumbers: some View {
        let pages = visiblePages()
        ForEach(pages, id: \.self) { page in
            if page == -1 {
                Text("\u{2026}")
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextMuted)
                    .frame(width: 32, height: 32)
            } else {
                Button {
                    setPage(page)
                } label: {
                    Text("\(page)")
                        .font(.zenBody2)
                        .fontWeight(page == currentPage ? .semibold : .regular)
                        .foregroundStyle(page == currentPage ? Color.zenPrimary : Color.zenTextPrimary)
                        .contentTransition(.numericText())
                        .frame(width: 32, height: 32)
                        .background {
                            if page == currentPage {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.zenPrimary.opacity(0.1))
                                    .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func navButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.zen(.group, weight: .semibold))
                .foregroundStyle(enabled ? Color.zenTextPrimary : Color.zenTextMuted.opacity(0.5))
                .frame(width: 32, height: 32)
                .background(Color.zenSurface)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func setPage(_ page: Int) {
        let clamped = min(max(page, 1), totalPages)
        withAnimation(.easeInOut(duration: 0.25)) {
            currentPage = clamped
        }
        onPageChange?(clamped)
    }

    private func visiblePages() -> [Int] {
        if totalPages <= 7 {
            return Array(1...totalPages)
        }

        var pages: [Int] = [1]

        if currentPage > 3 {
            pages.append(-1)
        }

        let start = max(2, currentPage - 1)
        let end = min(totalPages - 1, currentPage + 1)
        for p in start...end {
            pages.append(p)
        }

        if currentPage < totalPages - 2 {
            pages.append(-1)
        }

        pages.append(totalPages)
        return pages
    }
}

#Preview("ZenPagination") {
    struct PaginationPreview: View {
        @State private var page = 5

        var body: some View {
            VStack(spacing: ZenSpacing.large) {
                ZenPagination(currentPage: $page, totalPages: 20, style: .full)
                ZenPagination(currentPage: $page, totalPages: 20, style: .simple)

                Text("Current page: \(page)")
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextMuted)
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return PaginationPreview()
}
