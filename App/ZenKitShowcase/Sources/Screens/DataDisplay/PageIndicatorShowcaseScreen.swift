import SwiftUI
import ZenKit

struct PageIndicatorShowcaseScreen: View {
    @State private var onboardingPage = 0
    @State private var galleryPage = 1
    @State private var onboardingScrollPage: Int? = 0
    @State private var customScrollPage: Int? = 0

    private let onboardingPages = Array(1...4)
    private let galleryPages = Array(1...6)

    var body: some View {
        ShowcaseScreen(title: "Page Indicator") {
            ZenCard(title: "Interactive", subtitle: "Tap or drag the indicator to scrub explicit page state") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenPageIndicator(pageCount: 4, currentPage: $onboardingPage)

                    HStack(spacing: ZenSpacing.small) {
                        ZenButton("← Prev", variant: .secondary, size: .sm) {
                            withAnimation { onboardingPage = max(0, onboardingPage - 1) }
                        }
                        .disabled(onboardingPage == 0)

                        Spacer()

                        Text("Step \(onboardingPage + 1) of 4")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)

                        Spacer()

                        ZenButton("Next →", size: .sm) {
                            withAnimation { onboardingPage = min(3, onboardingPage + 1) }
                        }
                        .disabled(onboardingPage == 3)
                    }

                    VStack(spacing: ZenSpacing.small) {
                        ZenPageIndicator(pageCount: 3, currentPage: 0)
                        ZenPageIndicator(pageCount: 3, currentPage: 1)
                        ZenPageIndicator(pageCount: 3, currentPage: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            ZenCard(title: "Paged Scroll", subtitle: "Swipe cards or drag the indicator to move the pager") {
                pagingDemo(
                    pages: onboardingPages,
                    currentPage: binding(for: $onboardingScrollPage),
                    scrollPage: $onboardingScrollPage,
                    activeTint: .zenPrimary,
                    inactiveTint: .zenBorder,
                    palette: [.zenPrimary, .zenAccent, .zenSuccess, .zenWarning]
                )
            }

            ZenCard(title: "Custom Tint", subtitle: "Same interaction model with a branded palette") {
                pagingDemo(
                    pages: galleryPages,
                    currentPage: binding(for: $customScrollPage),
                    scrollPage: $customScrollPage,
                    activeTint: .zenSuccess,
                    inactiveTint: .zenSuccess.opacity(0.25),
                    palette: [.zenSuccess, .zenAccent, .zenPrimary, .zenWarning, .zenCritical, .zenSurfaceMuted]
                )
            }

            ZenCard(title: "6 Pages", subtitle: "Manual indicator keeps the same draggable capsule styling") {
                ZenPageIndicator(pageCount: 6, currentPage: $galleryPage)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private func binding(for page: Binding<Int?>) -> Binding<Int> {
        Binding(
            get: { page.wrappedValue ?? 0 },
            set: { page.wrappedValue = $0 }
        )
    }

    @ViewBuilder
    private func pagingDemo(
        pages: [Int],
        currentPage: Binding<Int>,
        scrollPage: Binding<Int?>,
        activeTint: Color,
        inactiveTint: Color,
        palette: [Color]
    ) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(Array(pages.enumerated()), id: \.offset) { offset, page in
                    pageCard(
                        title: "Page \(page)",
                        subtitle: "Swipe horizontally or scrub the indicator below.",
                        color: palette[offset % palette.count]
                    )
                    .containerRelativeFrame(.horizontal)
                    .id(offset)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, ZenSpacing.medium)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: scrollPage)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ZenPageIndicator(
                pageCount: pages.count,
                currentPage: currentPage,
                behavior: .scrollTracking,
                activeTint: activeTint,
                inactiveTint: inactiveTint
            )
        }
    }

    private func pageCard(title: String, subtitle: String, color: Color) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: ZenRadius.large, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.95), color.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                Text(title)
                    .font(.zenLabel)
                    .foregroundStyle(Color.white)

                Text(subtitle)
                    .font(.zenCaption)
                    .foregroundStyle(Color.white.opacity(0.88))
            }
            .padding(ZenSpacing.large)
        }
        .frame(height: 180)
    }
}
