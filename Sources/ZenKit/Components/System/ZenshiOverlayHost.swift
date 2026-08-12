import SwiftUI

struct ZenOverlayHostConfiguration {
    let alignment: Alignment
    let contentAlignment: Alignment
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let allowsHitTesting: Bool
    let overlayTransition: AnyTransition
    let presentAnimation: Animation
    let dismissAnimation: Animation

    static func edgeStack(
        alignment: Alignment,
        horizontalPadding: CGFloat = ZenSpacing.medium,
        verticalPadding: CGFloat = ZenSpacing.large,
        allowsHitTesting: Bool,
        overlayTransition: AnyTransition,
        animation: Animation
    ) -> ZenOverlayHostConfiguration {
        ZenOverlayHostConfiguration(
            alignment: alignment,
            contentAlignment: alignment,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            allowsHitTesting: allowsHitTesting,
            overlayTransition: overlayTransition,
            presentAnimation: animation,
            dismissAnimation: animation
        )
    }
}

struct ZenOverlayHost<Content: View, Overlay: View>: View {
    private let configuration: ZenOverlayHostConfiguration
    private let isOverlayMounted: Bool
    private let isOverlayVisible: Bool
    private let content: Content
    private let overlay: Overlay

    init(
        configuration: ZenOverlayHostConfiguration,
        isOverlayPresented: Bool = true,
        isOverlayVisible: Bool? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder overlay: () -> Overlay
    ) {
        self.configuration = configuration
        self.isOverlayMounted = isOverlayPresented
        self.isOverlayVisible = isOverlayVisible ?? isOverlayPresented
        self.content = content()
        self.overlay = overlay()
    }

    var body: some View {
        ZStack(alignment: configuration.alignment) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            overlayLayer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var overlayLayer: some View {
        ZStack(alignment: configuration.contentAlignment) {
            if isOverlayMounted {
                overlay
                    .padding(.horizontal, configuration.horizontalPadding)
                    .padding(.vertical, configuration.verticalPadding)
                    .transition(configuration.overlayTransition)
                    .animation(
                        isOverlayVisible ? configuration.presentAnimation : configuration.dismissAnimation,
                        value: isOverlayVisible
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.contentAlignment)
        .allowsHitTesting(isOverlayVisible && configuration.allowsHitTesting)
    }
}
