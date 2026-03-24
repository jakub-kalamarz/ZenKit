import SwiftUI

public struct ZenOnboarding<Page, Content>: View where Page: Identifiable, Content: View {
    @Binding private var selection: Page.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let backgroundStyle: ZenOnboardingBackgroundStyle
    private let transitionStyle: ZenOnboardingTransitionStyle
    private let reduceMotionOverride: Bool?
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
        self.init(
            pages: pages,
            selection: selection,
            backgroundStyle: backgroundStyle,
            transitionStyle: transitionStyle,
            reduceMotionOverride: nil,
            content: content
        )
    }

    internal init(
        pages: [Page],
        selection: Binding<Page.ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        reduceMotionOverride: Bool?,
        @ViewBuilder content: @escaping (Page) -> Content
    ) {
        _selection = selection
        self.backgroundStyle = backgroundStyle
        self.transitionStyle = transitionStyle
        self.reduceMotionOverride = reduceMotionOverride
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
        self.init(
            selection: selection,
            backgroundStyle: backgroundStyle,
            transitionStyle: transitionStyle,
            reduceMotionOverride: nil,
            content: content
        )
    }

    internal init<ID: Hashable>(
        selection: Binding<ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        reduceMotionOverride: Bool?,
        @ZenOnboardingStepBuilder content: () -> [ZenOnboardingStep<ID, AnyView>]
    ) where Page == ZenOnboardingStep<ID, AnyView>, Content == AnyView {
        _selection = selection
        self.backgroundStyle = backgroundStyle
        self.transitionStyle = transitionStyle
        self.reduceMotionOverride = reduceMotionOverride
        self.modelPages = nil
        self.modelContent = nil
        self.builderSteps = content()
    }

    public var body: some View {
        let transitionConfiguration = self.transitionConfiguration
        let layoutConfiguration = self.layoutConfiguration

        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                Spacer(minLength: layoutConfiguration.topPadding)

                selectedContent
                    .id(resolvedSelectedStepID)
                    .transition(transitionConfiguration.transition)
                    .animation(transitionConfiguration.animation, value: resolvedSelectedStepID)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: layoutConfiguration.bottomPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, layoutConfiguration.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if layoutConfiguration.showPageIndicator {
                    ZenPageIndicator(
                        pageCount: resolvedPageCount,
                        currentPage: pageIndicatorBinding
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, layoutConfiguration.horizontalPadding)
                    .padding(.bottom, layoutConfiguration.footerPadding)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    internal var transitionConfiguration: ZenOnboardingTransitionConfiguration {
        transitionStyle.resolvedConfiguration(reduceMotion: reduceMotionOverride ?? reduceMotion)
    }

    internal var resolvedPageCount: Int {
        modelPages?.count ?? builderSteps?.count ?? 0
    }

    internal var layoutConfiguration: ZenOnboardingLayoutConfiguration {
        ZenOnboardingLayoutConfiguration(pageCount: resolvedPageCount)
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
        } else if let builderSteps, let step = builderSteps.first(where: { $0.id == selection }) {
            step.content
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

internal struct ZenOnboardingLayoutConfiguration: Equatable, Sendable {
    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let footerPadding: CGFloat
    let showPageIndicator: Bool

    init(pageCount: Int) {
        self.horizontalPadding = ZenSpacing.large
        self.topPadding = ZenSpacing.xLarge
        self.bottomPadding = ZenSpacing.large
        self.footerPadding = ZenSpacing.medium
        self.showPageIndicator = pageCount > 1
    }
}
