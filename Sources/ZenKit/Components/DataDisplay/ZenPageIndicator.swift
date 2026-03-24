import SwiftUI

public struct ZenPageIndicator: View {
    private let pageCount: Int
    @Binding private var currentPage: Int

    public init(pageCount: Int, currentPage: Binding<Int>) {
        self.pageCount = pageCount
        _currentPage = currentPage
    }

    public init(pageCount: Int, currentPage: Int) {
        self.pageCount = pageCount
        _currentPage = .constant(currentPage)
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(Color.zenPrimary)
                        .frame(width: 20, height: 8)
                } else {
                    Circle()
                        .fill(Color.zenBorder)
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                currentPage = index
                            }
                        }
                }
            }
        }
        .animation(.spring(duration: 0.3), value: currentPage)
    }
}

private struct ZenPageIndicatorPreview: View {
    @State private var page = 0

    var body: some View {
        VStack(spacing: ZenSpacing.large) {
            ZenPageIndicator(pageCount: 4, currentPage: $page)

            HStack(spacing: ZenSpacing.small) {
                Button("Prev") {
                    withAnimation { page = max(0, page - 1) }
                }
                .disabled(page == 0)

                Button("Next") {
                    withAnimation { page = min(3, page + 1) }
                }
                .disabled(page == 3)
            }
            .font(.zenCaption)
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenPageIndicatorPreview()
}
