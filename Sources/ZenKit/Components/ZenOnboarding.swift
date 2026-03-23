import SwiftUI

public struct ZenOnboarding<Page, Content>: View where Page: Identifiable, Content: View {
    @Binding private var selection: Page.ID
    private let backgroundStyle: ZenOnboardingBackgroundStyle
    private let transitionStyle: ZenOnboardingTransitionStyle
    private let modelPages: [Page]?
    private let modelContent: ((Page) -> Content)?
    private let builderSteps: [ZenOnboardingStep<Page.ID, AnyView>]?

    public init(
        pages: [Page],
        selection: Binding<Page.ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        @ViewBuilder content: @escaping (Page) -> Content
    ) {
        _selection = selection
        self.backgroundStyle = backgroundStyle
        self.transitionStyle = transitionStyle
        self.modelPages = pages
        self.modelContent = content
        self.builderSteps = nil
    }

    public init<ID: Hashable>(
        selection: Binding<ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        @ZenOnboardingStepBuilder content: () -> [ZenOnboardingStep<ID, AnyView>]
    ) where Page == ZenOnboardingStep<ID, AnyView>, Content == AnyView {
        _selection = selection
        self.backgroundStyle = backgroundStyle
        self.transitionStyle = transitionStyle
        self.modelPages = nil
        self.modelContent = nil
        self.builderSteps = content()
    }

    public var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: ZenSpacing.large) {
                Spacer(minLength: ZenSpacing.large)

                selectedContent
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: ZenSpacing.large)

                if resolvedPageCount > 1 {
                    ZenPageIndicator(
                        pageCount: resolvedPageCount,
                        currentPage: pageIndicatorBinding
                    )
                    .padding(.bottom, ZenSpacing.medium)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, ZenSpacing.medium)
            .padding(.vertical, ZenSpacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    internal var resolvedPageCount: Int {
        modelPages?.count ?? builderSteps?.count ?? 0
    }

    internal var resolvedSelectedIndex: Int {
        if let modelPages {
            return modelPages.firstIndex(where: { $0.id == selection }) ?? 0
        }

        if let builderSteps {
            return builderSteps.firstIndex(where: { $0.id == selection }) ?? 0
        }

        return 0
    }

    internal var resolvedSelectedStepID: Page.ID? {
        if let modelPages, modelPages.indices.contains(resolvedSelectedIndex) {
            return modelPages[resolvedSelectedIndex].id
        }

        if let builderSteps, builderSteps.indices.contains(resolvedSelectedIndex) {
            return builderSteps[resolvedSelectedIndex].id
        }

        return nil
    }

    @ViewBuilder
    private var selectedContent: some View {
        if let modelPages, let modelContent, let page = modelPages.first(where: { $0.id == selection }) {
            modelContent(page)
                .transition(.opacity.combined(with: .scale(scale: 0.985)))
        } else if let builderSteps, let step = builderSteps.first(where: { $0.id == selection }) {
            step.content
                .transition(.opacity.combined(with: .scale(scale: 0.985)))
        } else {
            EmptyView()
        }
    }

    private var backgroundLayer: some View {
        ZenOnboardingBackgroundView(pageIndex: resolvedSelectedIndex, style: backgroundStyle)
    }

    private var pageIndicatorBinding: Binding<Int> {
        Binding(
            get: { resolvedSelectedIndex },
            set: { newIndex in
                guard let selectedID = pageID(at: newIndex) else { return }
                selection = selectedID
            }
        )
    }

    private func pageID(at index: Int) -> Page.ID? {
        if let modelPages, modelPages.indices.contains(index) {
            return modelPages[index].id
        }

        if let builderSteps, builderSteps.indices.contains(index) {
            return builderSteps[index].id
        }

        return nil
    }
}
