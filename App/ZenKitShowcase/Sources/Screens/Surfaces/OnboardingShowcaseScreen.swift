import SwiftUI
import ZenKit

struct OnboardingShowcaseScreen: View {
    @State private var subtleSelection = "welcome"
    @State private var expressiveSelection = "welcome"

    var body: some View {
        ShowcaseScreen(title: "Onboarding") {
            Text("A full-screen onboarding flow with animated mesh background, grain, and motion-aware transitions.")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextMuted)

            ZenCard(title: "Subtle", subtitle: "Default motion, calm background, and light page changes") {
                OnboardingDemoCard(
                    selection: $subtleSelection,
                    backgroundStyle: .animatedMesh(),
                    transitionStyle: .default
                )
            }

            ZenCard(title: "Expressive", subtitle: "Stronger motion and a more vivid background profile") {
                OnboardingDemoCard(
                    selection: $expressiveSelection,
                    backgroundStyle: .animatedMesh(intensity: .expressive),
                    transitionStyle: .expressive
                )
            }
        }
    }
}

private struct OnboardingDemoCard: View {
    @Binding var selection: String
    let backgroundStyle: ZenOnboardingBackgroundStyle
    let transitionStyle: ZenOnboardingTransitionStyle

    private let pages = [
        DemoPage(
            id: "welcome",
            title: "Welcome",
            subtitle: "Set up the workspace in a few steps."
        ),
        DemoPage(
            id: "focus",
            title: "Focus",
            subtitle: "Surface only the parts that matter right now."
        ),
        DemoPage(
            id: "sync",
            title: "Sync",
            subtitle: "Keep every device aligned automatically."
        )
    ]

    var body: some View {
        VStack(spacing: ZenSpacing.small) {
            ZenOnboarding(
                pages: pages,
                selection: $selection,
                backgroundStyle: backgroundStyle,
                transitionStyle: transitionStyle
            ) { page in
                onboardingPage(page)
            }
            .frame(height: 420)
            .clipShape(RoundedRectangle(cornerRadius: ZenRadius.large, style: .continuous))

            HStack(spacing: ZenSpacing.small) {
                ForEach(pages) { page in
                    ZenButton(variant: selection == page.id ? .default : .secondary, size: .xs) {
                        selection = page.id
                    } label: {
                        Text(page.title)
                    }
                }
            }

            Text("Current step: \(currentTitle)")
                .font(.zenCaption)
                .foregroundStyle(Color.zenTextMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var currentTitle: String {
        pages.first(where: { $0.id == selection })?.title ?? pages[0].title
    }

    @ViewBuilder
    private func onboardingPage(_ page: DemoPage) -> some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            ZenBadge(LocalizedStringKey(page.title.uppercased()))

            Text(page.title)
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            Text(page.subtitle)
                .font(.zenBody)
                .foregroundStyle(Color.zenTextMuted)

            HStack(spacing: ZenSpacing.small) {
                ZenButton("Back", variant: .secondary, size: .sm) {
                    selection = previousPage(before: page.id)
                }

                ZenButton("Next", size: .sm) {
                    selection = nextPage(after: page.id)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func previousPage(before pageID: String) -> String {
        guard let index = pages.firstIndex(where: { $0.id == pageID }) else {
            return pages[0].id
        }
        let previousIndex = (index - 1 + pages.count) % pages.count
        return pages[previousIndex].id
    }

    private func nextPage(after pageID: String) -> String {
        guard let index = pages.firstIndex(where: { $0.id == pageID }) else {
            return pages[0].id
        }
        let nextIndex = (index + 1) % pages.count
        return pages[nextIndex].id
    }
}

private struct DemoPage: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
}
