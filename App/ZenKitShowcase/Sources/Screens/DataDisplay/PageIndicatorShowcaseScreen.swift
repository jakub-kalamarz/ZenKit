import SwiftUI
import ZenKit

struct PageIndicatorShowcaseScreen: View {
    @State private var onboardingPage = 0
    @State private var carouselPage = 1

    var body: some View {
        ShowcaseScreen(title: "Page Indicator") {
            ZenCard(title: "Interactive", subtitle: "Tap dots or use controls") {
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
                }
            }

            ZenCard(title: "Display Only", subtitle: "Static page indicator") {
                VStack(spacing: ZenSpacing.small) {
                    ZenPageIndicator(pageCount: 3, currentPage: 0)
                    ZenPageIndicator(pageCount: 3, currentPage: 1)
                    ZenPageIndicator(pageCount: 3, currentPage: 2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            ZenCard(title: "6 Pages", subtitle: "Longer indicator") {
                ZenPageIndicator(pageCount: 6, currentPage: $carouselPage)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
