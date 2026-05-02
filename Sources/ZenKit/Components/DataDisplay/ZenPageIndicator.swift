import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum ZenPageIndicatorBehavior: Sendable {
    case manual
    case scrollTracking
}

public struct ZenPageIndicator: View {
    private let activeWidth: CGFloat = 18
    private let inactiveWidth: CGFloat = 10
    private let indicatorHeight: CGFloat = 6
    private let indicatorSpacing: CGFloat = 6
    private let hitAreaHeight: CGFloat = 30

    private enum Mode {
        case manual(pageCount: Int, currentPage: Binding<Int>)
        case scrollTracking(pageCount: Int, currentPage: Binding<Int>)
        case legacyScrollTracking
    }

    private let mode: Mode
    private let activeTint: Color
    private let inactiveTint: Color

    public init(
        pageCount: Int,
        currentPage: Binding<Int>,
        behavior: ZenPageIndicatorBehavior = .manual,
        activeTint: Color = .zenPrimary,
        inactiveTint: Color = .zenBorder
    ) {
        self.mode = behavior == .manual
            ? .manual(pageCount: pageCount, currentPage: currentPage)
            : .scrollTracking(pageCount: pageCount, currentPage: currentPage)
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
    }

    public init(
        pageCount: Int,
        currentPage: Int,
        activeTint: Color = .zenPrimary,
        inactiveTint: Color = .zenBorder
    ) {
        self.mode = .manual(pageCount: pageCount, currentPage: .constant(currentPage))
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
    }

    @available(iOS 17.0, macOS 14.0, *)
    @available(*, deprecated, message: "Use ZenPageIndicator(pageCount:currentPage:behavior:.scrollTracking,...) with a bound page selection.")
    public init(
        activeTint: Color = .zenPrimary,
        inactiveTint: Color = .zenBorder
    ) {
        self.mode = .legacyScrollTracking
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
    }

    public var body: some View {
        switch mode {
        case let .manual(pageCount, currentPage):
            interactiveIndicator(
                pageCount: pageCount,
                progress: CGFloat(currentPage.wrappedValue),
                currentPage: currentPage
            )
            .onChange(of: currentPage.wrappedValue) { page in
                triggerSelectionHaptic(for: page)
            }
        case let .scrollTracking(pageCount, currentPage):
            if #available(iOS 17.0, macOS 14.0, *) {
                scrollTrackingIndicator(pageCount: pageCount, currentPage: currentPage)
                    .onChange(of: currentPage.wrappedValue) { page in
                        triggerSelectionHaptic(for: page)
                    }
            } else {
                EmptyView()
            }
        case .legacyScrollTracking:
            if #available(iOS 17.0, macOS 14.0, *) {
                legacyScrollTrackingIndicator()
            } else {
                EmptyView()
            }
        }
    }

    private func interactiveIndicator(
        pageCount: Int,
        progress: CGFloat,
        currentPage: Binding<Int>?
    ) -> some View {
        GeometryReader { geometry in
            let trackWidth = indicatorWidth(pageCount: pageCount)
            let trackOriginX = max((geometry.size.width - trackWidth) / 2, 0)

            HStack(spacing: indicatorSpacing) {
                ForEach(0..<max(pageCount, 0), id: \.self) { index in
                    let emphasis = max(0, 1 - abs(progress - CGFloat(index)))

                    indicatorMark(emphasis: emphasis)
                }
            }
            .frame(width: trackWidth, height: indicatorHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(scrubGesture(pageCount: pageCount, currentPage: currentPage, trackWidth: trackWidth, trackOriginX: trackOriginX))
        }
        .frame(height: hitAreaHeight)
    }

    @available(iOS 17.0, macOS 14.0, *)
    private func scrollTrackingIndicator(
        pageCount: Int,
        currentPage: Binding<Int>
    ) -> some View {
        GeometryReader { geometry in
            if let scrollViewWidth = geometry.bounds(of: .scrollView(axis: .horizontal))?.width,
               scrollViewWidth > 0 {
                let minX = geometry.frame(in: .scrollView(axis: .horizontal)).minX
                let maxProgress = CGFloat(max(pageCount - 1, 0))
                let progress = min(max(-minX / scrollViewWidth, 0), maxProgress)

                interactiveIndicator(pageCount: pageCount, progress: progress, currentPage: currentPage)
                    .frame(width: scrollViewWidth)
                    .offset(x: -minX)
            }
        }
        .frame(height: hitAreaHeight)
    }

    @available(iOS 17.0, macOS 14.0, *)
    private func legacyScrollTrackingIndicator() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            if let scrollViewWidth = geometry.bounds(of: .scrollView(axis: .horizontal))?.width,
               scrollViewWidth > 0 {
                let minX = geometry.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = max(Int(width / scrollViewWidth), 0)
                let maxProgress = CGFloat(max(totalPages - 1, 0))
                let progress = min(max(-minX / scrollViewWidth, 0), maxProgress)

                interactiveIndicator(pageCount: totalPages, progress: progress, currentPage: nil)
                    .frame(width: scrollViewWidth)
                    .offset(x: -minX)
            }
        }
        .frame(height: hitAreaHeight)
    }

    private func indicatorMark(emphasis: CGFloat) -> some View {
        let clampedEmphasis = min(max(emphasis, 0), 1)
        let width = inactiveWidth + ((activeWidth - inactiveWidth) * clampedEmphasis)

        return Capsule(style: .continuous)
            .fill(inactiveTint)
            .overlay {
                Capsule(style: .continuous)
                    .fill(activeTint)
                    .opacity(clampedEmphasis)
            }
            .frame(width: width, height: indicatorHeight)
    }

    private func scrubGesture(
        pageCount: Int,
        currentPage: Binding<Int>?,
        trackWidth: CGFloat,
        trackOriginX: CGFloat
    ) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let currentPage, pageCount > 0 else { return }

                let index = resolvedPageIndex(
                    for: value.location.x - trackOriginX,
                    trackWidth: trackWidth,
                    pageCount: pageCount
                )

                if currentPage.wrappedValue != index {
                    withAnimation(.spring(duration: 0.22)) {
                        currentPage.wrappedValue = index
                    }
                }
            }
    }

    private func indicatorWidth(pageCount: Int) -> CGFloat {
        guard pageCount > 0 else { return 0 }
        return (CGFloat(pageCount) * activeWidth) + (CGFloat(max(pageCount - 1, 0)) * indicatorSpacing)
    }

    private func resolvedPageIndex(for locationX: CGFloat, trackWidth: CGFloat, pageCount: Int) -> Int {
        guard pageCount > 1, trackWidth > 0 else { return 0 }

        let clampedX = min(max(locationX, 0), trackWidth)
        let progress = clampedX / trackWidth
        let index = Int((progress * CGFloat(pageCount - 1)).rounded())

        return min(max(index, 0), pageCount - 1)
    }

    private func triggerSelectionHaptic(for page: Int) {
#if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
#else
        _ = page
#endif
    }
}

@available(iOS 17.0, macOS 14.0, *)
private struct ZenPageIndicatorPreview: View {
    @State private var manualPage = 0
    @State private var scrollPage: Int? = 0
    private let cards = Array(0..<4)

    private var scrollPageBinding: Binding<Int> {
        Binding(
            get: { scrollPage ?? 0 },
            set: { scrollPage = $0 }
        )
    }

    var body: some View {
        VStack(spacing: ZenSpacing.large) {
            ZenPageIndicator(pageCount: cards.count, currentPage: $manualPage)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(cards, id: \.self) { index in
                        RoundedRectangle(cornerRadius: ZenRadius.large, style: .continuous)
                            .fill(Color.zenSurface)
                            .overlay {
                                Text("Page \(index + 1)")
                                    .font(.zenIntro)
                                    .foregroundStyle(Color.zenTextPrimary)
                            }
                            .containerRelativeFrame(.horizontal)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, ZenSpacing.large)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPage)
            .safeAreaInset(edge: .bottom, spacing: ZenSpacing.medium) {
                ZenPageIndicator(
                    pageCount: cards.count,
                    currentPage: scrollPageBinding,
                    behavior: .scrollTracking
                )
            }
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    if #available(iOS 17.0, macOS 14.0, *) {
        ZenPageIndicatorPreview()
    }
}
