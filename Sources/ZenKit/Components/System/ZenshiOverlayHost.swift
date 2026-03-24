import SwiftUI

enum ZenOverlayPresentationStyle {
    case centeredOverlay
    case edgeStack
}

struct ZenOverlayScrim {
    let material: Material?
    let transition: AnyTransition

    static let none = ZenOverlayScrim(material: nil, transition: .identity)
}

struct ZenOverlayHostConfiguration {
    let presentationStyle: ZenOverlayPresentationStyle
    let alignment: Alignment
    let contentAlignment: Alignment
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let allowsHitTesting: Bool
    let scrim: ZenOverlayScrim
    let overlayTransition: AnyTransition
    let scrimPresentAnimation: Animation
    let scrimDismissAnimation: Animation
    let presentAnimation: Animation
    let dismissAnimation: Animation

    static func centeredModal(
        horizontalPadding: CGFloat = ZenSpacing.large,
        verticalPadding: CGFloat = ZenSpacing.large,
        scrimTransition: AnyTransition = .opacity,
        overlayTransition: AnyTransition,
        scrimPresentAnimation: Animation,
        scrimDismissAnimation: Animation,
        presentAnimation: Animation,
        dismissAnimation: Animation
    ) -> ZenOverlayHostConfiguration {
        ZenOverlayHostConfiguration(
            presentationStyle: .centeredOverlay,
            alignment: .center,
            contentAlignment: .center,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            allowsHitTesting: true,
            scrim: ZenOverlayScrim(material: .ultraThinMaterial, transition: scrimTransition),
            overlayTransition: overlayTransition,
            scrimPresentAnimation: scrimPresentAnimation,
            scrimDismissAnimation: scrimDismissAnimation,
            presentAnimation: presentAnimation,
            dismissAnimation: dismissAnimation
        )
    }

    static func edgeStack(
        alignment: Alignment,
        horizontalPadding: CGFloat = ZenSpacing.medium,
        verticalPadding: CGFloat = ZenSpacing.large,
        allowsHitTesting: Bool,
        overlayTransition: AnyTransition,
        animation: Animation
    ) -> ZenOverlayHostConfiguration {
        ZenOverlayHostConfiguration(
            presentationStyle: .edgeStack,
            alignment: alignment,
            contentAlignment: alignment,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            allowsHitTesting: allowsHitTesting,
            scrim: .none,
            overlayTransition: overlayTransition,
            scrimPresentAnimation: animation,
            scrimDismissAnimation: animation,
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
            if isOverlayMounted, configuration.scrim.material != nil {
                ZStack {
                    if let material = configuration.scrim.material {
                        Rectangle()
                            .fill(material)
                            .opacity(isOverlayVisible ? ZenConfirmationDialogMotion.backdropOpacity : 0)
                    }
                }
                .ignoresSafeArea()
                .transition(configuration.scrim.transition)
                .animation(
                    isOverlayVisible ? configuration.scrimPresentAnimation : configuration.scrimDismissAnimation,
                    value: isOverlayVisible
                )
            }

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
