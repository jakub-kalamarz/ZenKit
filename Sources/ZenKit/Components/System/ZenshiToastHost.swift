import SwiftUI

public enum ZenToastHostEdge: Sendable {
    case top
    case bottom
}

public struct ZenToastHost: View {
    @ObservedObject private var center: ZenToastCenter
    private let edge: ZenToastHostEdge

    @Environment(\.displayScale) private var displayScale

    @GestureState private var isPressingStack = false
    @State private var isPointerOverStack = false
    @State private var naturalSizes: [ZenToastID: CGSize] = [:]
    /// Toasts the center already dropped, kept on screen for Ding's closing beat: the pill
    /// folds back into its circle before the removal transition carries it off.
    @State private var closingToasts: [ZenToastItem] = []
    @State private var lastVisibleToasts: [ZenToastItem] = []

    static let closingDuration: Duration = .milliseconds(340)

    public init(center: ZenToastCenter, edge: ZenToastHostEdge = .bottom) {
        self.center = center
        self.edge = edge
    }

    @MainActor
    public init(edge: ZenToastHostEdge = .bottom) {
        self.center = .shared
        self.edge = edge
    }

    public var body: some View {
        #if DEBUG
        #endif
        GeometryReader { proxy in
            let layout = Layout(edge: edge, size: proxy.size)

            ZenOverlayHost(
                configuration: .edgeStack(
                    alignment: layout.hostAlignment,
                    horizontalPadding: layout.viewportInset,
                    verticalPadding: layout.viewportInset,
                    allowsHitTesting: !center.visibleToasts.isEmpty,
                    overlayTransition: .identity,
                    animation: Layout.transformAnimation
                )
            ) {
                Color.clear
            } overlay: {
                overlayContent(layout: layout)
            }
                .accessibilityIdentifier(ZenAccessibilityID.Toast.host)
        }
    }

    @ViewBuilder
    private func overlayContent(layout: Layout) -> some View {
        // Depth 0 is the newest toast: it sits frontmost and owns the collapsed
        // stack's height, exactly like the reference viewport.
        let closingIDs = Set(closingToasts.map(\.id))
        let displayedToasts = (center.visibleToasts + closingToasts)
            .sorted { $0.createdAt > $1.createdAt }
        let isExpanded = isStackExpanded
        // Behind cards are clipped to the front card only once it has measured itself.
        let isFrontMeasured = displayedToasts.first.map { naturalSizes[$0.id] != nil } ?? false
        // Until a new front card has measured itself it is a bare circle.
        let stackSize = displayedToasts.first.flatMap { naturalSizes[$0.id] } ?? CGSize(width: ZenToastCard.side, height: ZenToastCard.side)

        ZStack(alignment: layout.stackAlignment) {
            ForEach(Array(displayedToasts.enumerated()), id: \.element.id) { depth, toast in
                let measuredSize = naturalSizes[toast.id]

                ZenToastCard(
                    toast: toast,
                    edge: edge,
                    isFrontmost: depth == 0,
                    isClosing: closingIDs.contains(toast.id),
                    isExpanded: isExpanded,
                    // Collapsed, every card is squashed to the frontmost card's
                    // height so the peeking slivers line up. Left unconstrained
                    // until it has been measured, so nothing snaps on insertion.
                    // Cards hug their own content, except behind a collapsed
                    // stack, where they borrow the frontmost card's width so the
                    // peeking slivers line up instead of reading as ragged edges.
                    // Never wider than the card itself: a front card's first measurement can overshoot.
                    displayWidth: (isExpanded || depth == 0 || !isFrontMeasured) ? nil : measuredSize.map { min($0.width, stackSize.width) },
                    naturalWidth: measuredSize?.width,
                    isInteractive: (isExpanded || depth == 0) && !closingIDs.contains(toast.id),
                    onAction: { handleAction($0, on: toast) },
                    onDismiss: { dismissToast(toast) }
                )
                // Registered on the card itself, *before* the max-width frame:
                // cards hug their content, so measuring the frame instead would
                // publish the full-width row it centres them in and swallow every
                // touch alongside the toast.
                .zenToastHitRegion(id: toast.id)
                .frame(maxWidth: layout.cardMaxWidth, alignment: layout.cardAlignment)
                // Scale first, then offset: the offset must not be scaled down
                // for cards deeper in the stack.
                .scaleEffect(isExpanded ? 1 : Layout.scale(for: depth), anchor: layout.cardAnchor)
                .offset(
                    y: isExpanded
                        ? layout.expandedOffset(
                            for: depth,
                            precedingHeight: precedingHeight(before: depth, in: displayedToasts)
                        )
                        : layout.collapsedOffset(for: depth, stackHeight: stackSize.height)
                )
                .zIndex(Double(Layout.baseZIndex - depth))
                .transition(layout.transition)
                .accessibilityHidden(!isExpanded && depth > 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: layout.hostAlignment)
        .onPreferenceChange(ZenToastCardSizePreferenceKey.self) { sizes in
            // Snap to whole device pixels before the size is fed back into
            // `.frame(width:height:)`. A raw measured size is nearly always
            // fractional (61.666…), which lands the card's bottom/trailing
            // hairline midway across a pixel: that edge antialiases to a
            // fraction of the colour the pixel-aligned top/leading edges get,
            // and the border reads as uneven.
            naturalSizes = sizes.mapValues { snappedToPixelGrid($0) }
        }
        .onChange(of: center.visibleToasts.map(\.id)) { _, ids in
            beginClosing(droppedFrom: ids)
        }
        .simultaneousGesture(stackReviewGesture)
        .onHover { isInside in
            isPointerOverStack = isInside
        }
        .onChange(of: isExpanded) { isExpanded in
            if isExpanded {
                center.pauseAutoDismiss()
            } else {
                center.resumeAutoDismiss()
            }
        }
        .animation(Layout.transformAnimation, value: stackAnimationSignature)
        .animation(Layout.transformAnimation, value: isExpanded)
    }

    private func beginClosing(droppedFrom ids: [ZenToastID]) {
        let current = Set(ids)
        let dropped = lastVisibleToasts.filter { !current.contains($0.id) }
        lastVisibleToasts = center.visibleToasts
        guard !dropped.isEmpty else { return }

        closingToasts += dropped
        Task { @MainActor in
            try? await Task.sleep(for: Self.closingDuration)
            let droppedIDs = Set(dropped.map(\.id))
            withAnimation(.easeOut(duration: 0.15)) {
                closingToasts.removeAll { droppedIDs.contains($0.id) }
            }
        }
    }

    /// Rounds a measured size up to the next whole device pixel.
    private func snappedToPixelGrid(_ size: CGSize) -> CGSize {
        let scale = displayScale > 0 ? displayScale : 1
        return CGSize(
            width: (size.width * scale).rounded(.up) / scale,
            height: (size.height * scale).rounded(.up) / scale
        )
    }

    /// The stack fans out on hover, matching the reference. Touch platforms have
    /// no hover, so a press on the stack stands in for it.
    private var isStackExpanded: Bool {
        (isPressingStack || isPointerOverStack) && center.visibleToasts.count > 1
    }

    private var stackReviewGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isPressingStack) { _, state, _ in
                state = center.visibleToasts.count > 1
            }
    }

    private var stackAnimationSignature: [ToastAnimationSignature] {
        center.visibleToasts.map {
            ToastAnimationSignature(
                id: $0.id,
                title: $0.title,
                message: $0.message,
                tone: $0.tone,
                progress: $0.progress
            )
        }
    }

    private func precedingHeight(before depth: Int, in toasts: [ZenToastItem]) -> CGFloat {
        toasts.prefix(depth).reduce(into: CGFloat.zero) { total, toast in
            total += naturalSizes[toast.id]?.height ?? Layout.estimatedCardHeight
        }
    }

    @MainActor
    private func handleAction(_ action: ZenToastAction, on toast: ZenToastItem) {
        action.handler()

        if action.dismissesToast {
            center.dismiss(toast.id)
        }
    }

    @MainActor
    private func dismissToast(_ toast: ZenToastItem) {
        center.dismiss(toast.id)
    }
}

extension ZenToastHost {
    struct Layout {
        /// Vertical sliver of each card left visible behind the frontmost one.
        static let peek: CGFloat = 10
        /// Spacing between cards once the stack is fanned out.
        static let gap: CGFloat = 12
        /// Each step back in the stack shrinks the card by this fraction.
        static let scaleStep: CGFloat = 0.05
        /// Stand-in height used before a card has reported its measured size.
        static let estimatedCardHeight: CGFloat = 88
        /// Stand-in width used before a card has reported its measured size.
        static let estimatedCardWidth: CGFloat = 320
        /// Ceiling on a card's self-sized width; past this, text wraps instead.
        static let maxCardWidth: CGFloat = 420
        static let wideViewportBreakpoint: CGFloat = 640
        static let compactViewportInset: CGFloat = 16
        static let wideViewportInset: CGFloat = 32
        static let swipeDismissThreshold: CGFloat = 96
        static let baseZIndex = 1000

        static var estimatedCardSize: CGSize {
            CGSize(width: estimatedCardWidth, height: estimatedCardHeight)
        }

        static let transformAnimation: Animation = .timingCurve(0.22, 1, 0.36, 1, duration: 0.5)
        static let heightAnimation: Animation = .easeOut(duration: 0.15)
        static let contentFadeAnimation: Animation = .easeInOut(duration: 0.25)

        let edge: ZenToastHostEdge
        let size: CGSize

        static func scale(for depth: Int) -> CGFloat {
            max(0, 1 - (CGFloat(depth) * scaleStep))
        }

        /// Toasts stay centred on their edge at every width; only the inset
        /// changes once the viewport is wide.
        var hostAlignment: Alignment {
            switch edge {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }

        var stackAlignment: Alignment {
            hostAlignment
        }

        var cardAlignment: Alignment {
            .center
        }

        var cardAnchor: UnitPoint {
            switch edge {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }

        /// Cards size to their content, so this is only the ceiling they wrap at.
        var cardMaxWidth: CGFloat {
            min(Self.maxCardWidth, max(0, size.width - (viewportInset * 2)))
        }

        var viewportInset: CGFloat {
            isWide ? Self.wideViewportInset : Self.compactViewportInset
        }

        /// `+1` when the stack grows downwards from the top edge, `-1` upwards
        /// from the bottom edge.
        var stackDirection: CGFloat {
            switch edge {
            case .top:
                return 1
            case .bottom:
                return -1
            }
        }

        /// Collapsed, cards are scaled about the anchored edge. The extra
        /// `shrink * stackHeight` term cancels the scale so the *outer* edges
        /// end up exactly `peek` apart instead of converging.
        func collapsedOffset(for depth: Int, stackHeight: CGFloat) -> CGFloat {
            let shrink = 1 - Self.scale(for: depth)
            return stackDirection * ((CGFloat(depth) * Self.peek) + (shrink * stackHeight))
        }

        /// Expanded, each card clears the full height of every card in front of
        /// it plus one gap per step.
        func expandedOffset(for depth: Int, precedingHeight: CGFloat) -> CGFloat {
            stackDirection * (precedingHeight + (CGFloat(depth) * Self.gap))
        }

        /// The card animates its own arrival (circle drops in, then opens); by removal time the
        /// host's closing beat has folded it into its circle, so all that is left is the drop.
        var transition: AnyTransition {
            .asymmetric(
                insertion: .identity,
                removal: AnyTransition(ZenToastLeaveTransition(direction: -stackDirection))
            )
        }

        private var isWide: Bool {
            size.width >= Self.wideViewportBreakpoint
        }

        func shouldDismiss(
            for translation: CGSize,
            threshold: CGFloat = Layout.swipeDismissThreshold
        ) -> Bool {
            if abs(translation.width) > threshold {
                return true
            }

            switch edge {
            case .top:
                return translation.height < -threshold
            case .bottom:
                return translation.height > threshold
            }
        }
    }
}

private struct ZenToastCardSizePreferenceKey: PreferenceKey {
    static var defaultValue: [ZenToastID: CGSize] { [:] }

    static func reduce(value: inout [ZenToastID: CGSize], nextValue: () -> [ZenToastID: CGSize]) {
        value.merge(nextValue()) { _, latest in latest }
    }
}

/// Ding's toast (template's `@yusufceng1z/ding-react`): a 44pt icon circle that lands first,
/// then springs open into a pill carrying the copy, and folds back into the circle before it leaves.
private struct ZenToastCard: View {
    let toast: ZenToastItem
    let edge: ZenToastHostEdge
    let isFrontmost: Bool
    let isClosing: Bool
    let isExpanded: Bool
    let displayWidth: CGFloat?
    /// The card's own open width, so a card clipped behind the stack keeps its layout.
    let naturalWidth: CGFloat?
    let isInteractive: Bool
    let onAction: (ZenToastAction) -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.zenHapticsOverride) private var hapticsOverride

    @State private var dragOffset: CGSize = .zero
    @State private var hasEntered = false
    @State private var isOpen = false
    /// Past Ding's 900ms "ready" mark, a tone swap redraws its glyph without the arrival delay.
    @State private var isSettled = false
    @State private var kickTrigger = 0

    static let side: CGFloat = 44
    static let maxRadius: CGFloat = 22
    // Ding's spring constants (enter / morph / stack).
    static let enterSpring = Animation.interpolatingSpring(stiffness: 320, damping: 26)
    static let morphSpring = Animation.interpolatingSpring(stiffness: 340, damping: 27)
    static let stackSpring = Animation.interpolatingSpring(stiffness: 400, damping: 36)

    /// 0 = icon circle, 1 = full pill.
    private var morph: CGFloat { isOpen ? 1 : 0 }
    static let closingSpring = Animation.interpolatingSpring(stiffness: 380, damping: 36)

    var body: some View {
        let shape = ZenToastPillShape()

        ZStack(alignment: contentAlignment) {
            ZenToastMorphLayout(progress: morph) {
                iconSlot
                content
                    .opacity(Double(min(max(morph * 1.5 - 0.25, 0), 1)))
                    .blur(radius: max(0, 1 - morph) * 10)
                    .offset(x: max(0, 1 - morph) * -12)
                    .background(sizeReader)
            }
            .overlay(alignment: .bottom) { progressBar }
            // Pinned to its natural height so squashing the card below it never feeds back into
            // the measurement. A card behind the stack keeps its own width too: it is clipped
            // to the front card's width instead of re-wrapping its (fading) text.
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: displayWidth == nil ? nil : naturalWidth)
        }
        // Width only: pinning a behind card's height bottom-aligned made it hang below the
        // edge for a beat while the frame and its content animated out of step.
        .frame(width: displayWidth, alignment: contentAlignment)
        // Snaps, never animates: SwiftUI tweens a width that switches between natural and fixed
        // from the wrong size, flashing the card full-row wide.
        .animation(nil, value: displayWidth)
        .background(Color.zenSurface)
        .clipShape(shape)
        .overlay(shape.stroke(ringColor, lineWidth: 1))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.14), radius: 6, x: 0, y: 4)
        .keyframeAnimator(initialValue: CGSize.zero, trigger: kickTrigger) { view, kick in
            view.offset(kick)
        } keyframes: { _ in
            // Ding's reactions: error wobbles sideways, warning bumps away from the edge.
            let shake: CGFloat = toast.tone == .error ? 1 : 0
            let bump: CGFloat = toast.tone == .warning ? enterTravel / -21 : 0
            KeyframeTrack(\.width) {
                CubicKeyframe(6 * shake, duration: 0.07)
                CubicKeyframe(-4 * shake, duration: 0.1)
                CubicKeyframe(2 * shake, duration: 0.1)
                CubicKeyframe(0, duration: 0.15)
            }
            KeyframeTrack(\.height) {
                CubicKeyframe(bump, duration: 0.1)
                SpringKeyframe(0, duration: 0.35)
            }
        }
        .scaleEffect(hasEntered ? 1 : 0.5)
        .offset(y: hasEntered ? 0 : enterTravel)
        .opacity(hasEntered ? 1 : 0)
        .offset(dragOffset)
        .gesture(dismissGesture, including: isInteractive ? .all : .none)
        .animation(.spring(response: 0.24, dampingFraction: 0.82), value: dragOffset)
        .animation(Self.stackSpring, value: toast.tone)
        .task { await arrive() }
        .onChange(of: isClosing) { _, closing in
            guard closing else { return }
            withAnimation(Self.closingSpring) { isOpen = false }
        }
        .onChange(of: toast.tone) { _, tone in
            if isOpen, tone == .error || tone == .warning { kickTrigger += 1 }
            if isOpen, isFrontmost { playHaptic(tone.arrivalHaptic) }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ZenAccessibilityID.Toast.card)
    }

    private func arrive() async {
        guard !reduceMotion else {
            hasEntered = true
            isOpen = true
            isSettled = true
            if isFrontmost { playHaptic(arrivalHaptic) }
            return
        }
        withAnimation(Self.enterSpring) { hasEntered = true }
        try? await Task.sleep(for: .milliseconds(450))
        withAnimation(Self.morphSpring) { isOpen = true }
        if isFrontmost { playHaptic(arrivalHaptic) }
        try? await Task.sleep(for: .milliseconds(200))
        if toast.tone == .error || toast.tone == .warning { kickTrigger += 1 }
        try? await Task.sleep(for: .milliseconds(250))
        isSettled = true
    }

    /// Someone else's activity (an avatar toast) arrives silently: a household checking off a
    /// list would otherwise buzz the phone on every realtime burst.
    private var arrivalHaptic: ZenHapticFeedback {
        toast.avatar == nil ? toast.tone.arrivalHaptic : .none
    }

    private func playHaptic(_ feedback: ZenHapticFeedback) {
#if os(iOS)
        guard (hapticsOverride ?? ZenTheme.current.haptics).enabled else { return }
        ZenHapticEngine.perform(feedback)
#endif
    }

    /// Starts beyond the anchored edge: one circle plus the viewport inset and a margin, like Ding.
    private var enterTravel: CGFloat {
        let travel = Self.side + 16 + 24
        return edge == .top ? -travel : travel
    }

    /// Only the frontmost card shows its contents while the stack is collapsed;
    /// the ones behind read as blank slivers.
    private var contentOpacity: Double {
        (isExpanded || isFrontmost) ? 1 : 0
    }

    private var contentAlignment: Alignment {
        edge == .top ? .top : .bottom
    }

    private var isSingleLine: Bool {
        toast.avatar != nil && toast.message == nil && toast.actions.isEmpty && toast.progress == nil
    }

    /// Ding shows a close button only on toasts that never time out on their own.
    private var showsClose: Bool {
        toast.duration == nil && toast.tone != .loading && toast.actions.count < 2
    }

    @ViewBuilder
    private var iconSlot: some View {
        Group {
            if let avatar = toast.avatar {
                ZenAvatar(name: avatar.name, imageURL: avatar.imageURL, size: 28)
                    .overlay(alignment: .bottomTrailing) {
                        if let badge = avatar.badge {
                            ZenToastAvatarBadgeView(badge: badge, diameter: 16, isRevealed: isOpen)
                                .offset(x: 3, y: 3)
                        }
                    }
            } else {
                if let icon = toast.icon {
                    ZenIcon(icon: icon, size: 20)
                        .foregroundStyle(tintColor)
                        .transition(.scale(scale: 0.25).combined(with: .opacity))
                } else {
                    ZenToastGlyph(tone: toast.tone, tint: tintColor, isSwap: isSettled)
                        .id(toast.tone)
                        .transition(.scale(scale: 0.25).combined(with: .opacity))
                }
            }
        }
        .frame(width: Self.side, height: Self.side)
        .opacity(contentOpacity)
    }

    private var content: some View {
        Group {
            if toast.actions.isEmpty && !showsClose {
                copy
            } else {
                // Ding wraps the buttons under the copy once they no longer fit beside it.
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        copy
                        controls
                    }
                    VStack(alignment: .trailing, spacing: 0) {
                        copy.frame(maxWidth: .infinity, alignment: .leading)
                        controls
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .padding(.trailing, 8)
        .frame(minHeight: Self.side)
        .opacity(contentOpacity)
        .allowsHitTesting(contentOpacity == 1)
        .animation(ZenToastHost.Layout.contentFadeAnimation, value: contentOpacity)
    }

    private var copy: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 3) {
                Text(toast.title)
                    .font(.zen(.body, weight: .semibold))
                    .foregroundStyle(Color.zenTextPrimary)
                    .lineLimit(isSingleLine ? 1 : nil)
                    .truncationMode(.tail)
                    .accessibilityIdentifier(ZenAccessibilityID.Toast.title)

                if let message = toast.message {
                    Text(message)
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextPrimary.opacity(0.65))
                }
            }
            .id(CopyKey(title: toast.title, message: toast.message))
            // Ding rolls the old copy up and out while the new one rises in.
            .transition(.asymmetric(
                insertion: .offset(y: 12).combined(with: .opacity),
                removal: .offset(y: -12).combined(with: .opacity)
            ))
        }
        .padding(.vertical, 12)
        .padding(.trailing, 6)
        .frame(maxWidth: 340, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.38), value: CopyKey(title: toast.title, message: toast.message))
    }

    private var controls: some View {
        HStack(spacing: 8) {
            ForEach(Array(toast.actions.enumerated()), id: \.element.id) { index, action in
                ZenToastActionButton(
                    label: action.label,
                    // The last action is Ding's filled primary; any before it are quiet text buttons.
                    isPrimary: index == toast.actions.count - 1,
                    fill: action.variant == .destructive ? .zenCritical : .zenTextPrimary
                ) {
                    playHaptic(.impact(.light))
                    onAction(action)
                }
            }

            if showsClose {
                ZenToastCloseButton {
                    playHaptic(.impact(.light))
                    onDismiss()
                }
            }
        }
        .fixedSize()
    }

    @ViewBuilder
    private var progressBar: some View {
        if let progress = toast.progress {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Color.zenTextPrimary.opacity(0.14)
                    tintColor.frame(width: proxy.size.width * min(max(progress, 0), 1))
                }
            }
            .frame(height: 3)
            .opacity(Double(morph))
            .animation(.timingCurve(0.2, 0, 0, 1, duration: 0.3), value: progress)
            .accessibilityValue(Text("\(Int((min(max(progress, 0), 1) * 100).rounded())) percent"))
        }
    }

    /// Reports the *open* pill size (icon slot + copy), measured off the copy, which keeps its
    /// size through the morph. Cards behind borrow it, so they never squash down to a front
    /// card that is still a 44pt circle.
    private var sizeReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ZenToastCardSizePreferenceKey.self,
                    value: [toast.id: CGSize(
                        width: Self.side + proxy.size.width,
                        height: max(Self.side, proxy.size.height)
                    )]
                )
        }
    }

    private var dismissGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let layout = ZenToastHost.Layout(edge: edge, size: .zero)

                if layout.shouldDismiss(for: value.translation) {
                    onDismiss()
                } else {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private var tintColor: Color {
        switch toast.tone {
        case .default, .loading:
            return .zenTextPrimary
        case .info:
            return .zenPrimary
        case .success:
            return .zenSuccess
        case .warning:
            return .zenWarning
        case .error:
            return .zenCritical
        }
    }

    private var ringColor: Color {
        Color.zenTextPrimary.opacity(colorScheme == .dark ? 0.1 : 0.08)
    }
}

extension ZenToastTone {
    /// Played once when a toast opens or swaps to this tone; loading stays silent until it resolves.
    var arrivalHaptic: ZenHapticFeedback {
        switch self {
        case .success: .notification(.success)
        case .error: .notification(.error)
        case .warning: .notification(.warning)
        case .default, .info: .impact(.light)
        case .loading: .none
        }
    }
}

private struct CopyKey: Hashable {
    let title: String
    let message: String?
}

/// Capsule while one line tall, a 22pt rounded rect once the copy wraps.
private struct ZenToastPillShape: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: min(rect.height / 2, ZenToastCard.side / 2), style: .continuous)
            .path(in: rect)
    }
}

/// Lays the 44pt icon slot and the copy side by side, and reports a size between the bare
/// circle (`progress` 0) and the full pill (1). Spring overshoot past 1 is kept: it is the
/// liquid stretch Ding's pill has when it opens.
private struct ZenToastMorphLayout: Layout {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    private let side = ZenToastCard.side

    private func bodySize(_ proposal: ProposedViewSize, _ subviews: Subviews) -> CGSize {
        guard subviews.count > 1 else { return .zero }
        return subviews[1].sizeThatFits(bodyProposal(proposal, subviews))
    }

    /// The copy's ideal (one-line) width, capped by what the host offers: the pill hugs its text
    /// instead of filling the row, and only wraps once it would overflow.
    private func bodyProposal(_ proposal: ProposedViewSize, _ subviews: Subviews) -> ProposedViewSize {
        let ideal = subviews[1].sizeThatFits(.unspecified).width
        let available = proposal.width.map { max(0, $0 - side) } ?? ideal
        return ProposedViewSize(width: min(ideal, available), height: nil)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let body = bodySize(proposal, subviews)
        let t = max(progress, 0)
        return CGSize(
            width: side + body.width * t,
            height: side + max(0, body.height - side) * t
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: side, height: side)
        )
        guard subviews.count > 1 else { return }
        subviews[1].place(
            at: CGPoint(x: bounds.minX + side, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(bodySize(proposal, subviews))
        )
    }
}

/// Ding's exit, after the host's closing beat has folded the pill into its circle: it drops
/// toward its edge, shrinking, blurring and fading.
struct ZenToastLeaveTransition: Transition {
    /// Points along y toward the anchored edge.
    let direction: CGFloat

    func body(content: Content, phase: TransitionPhase) -> some View {
        let isGone = !phase.isIdentity

        content
            .scaleEffect(isGone ? 0.92 : 1)
            .offset(y: isGone ? direction * 12 : 0)
            .blur(radius: isGone ? 4 : 0)
            .opacity(isGone ? 0 : 1)
            .animation(.easeOut(duration: 0.15), value: isGone)
    }
}

/// Ding's status glyphs: a ring plus a mark, drawn on with stroke trims, each tone finishing
/// with its own small gesture (success pulses and ripples, error shakes, warning and info
/// drop their dot in). Loading is a quarter ring spinning.
private struct ZenToastGlyph: View {
    let tone: ZenToastTone
    let tint: Color
    /// Swapped in on a toast that is already open: skip the arrival delay.
    let isSwap: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var ringDrawn = false
    @State private var markDrawn = false
    @State private var dotShown = false
    @State private var spin = false
    @State private var flourish = 0

    private static let size: CGFloat = 22
    private var unit: CGFloat { Self.size / 24 }

    var body: some View {
        ZStack {
            if tone == .default {
                ZenIcon(icon: .bellFill, size: 18)
                    .foregroundStyle(tint)
            } else {
                ring
                mark
            }
        }
        .frame(width: Self.size, height: Self.size)
        .keyframeAnimator(initialValue: Flourish(), trigger: flourish) { view, value in
            view
                .background(
                    Circle()
                        .stroke(tint, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                        .scaleEffect(value.rippleScale)
                        .opacity(value.rippleOpacity)
                )
                .scaleEffect(value.scale)
                .offset(x: value.x)
        } keyframes: { _ in
            let success: CGFloat = tone == .success ? 1 : 0
            let error: CGFloat = tone == .error ? 1 : 0
            KeyframeTrack(\.scale) {
                CubicKeyframe(1 + 0.14 * success, duration: 0.18)
                CubicKeyframe(1, duration: 0.27)
            }
            KeyframeTrack(\.rippleOpacity) {
                LinearKeyframe(0.55 * success, duration: 0.01)
                CubicKeyframe(0, duration: 0.7)
            }
            KeyframeTrack(\.rippleScale) {
                LinearKeyframe(1, duration: 0.01)
                CubicKeyframe(1.9, duration: 0.7)
            }
            KeyframeTrack(\.x) {
                CubicKeyframe(-2.5 * error, duration: 0.09)
                CubicKeyframe(2.5 * error, duration: 0.1)
                CubicKeyframe(-1.5 * error, duration: 0.1)
                CubicKeyframe(0, duration: 0.13)
            }
        }
        .task { await draw() }
        .accessibilityHidden(true)
    }

    private var stroke: StrokeStyle {
        StrokeStyle(lineWidth: 2.2 * unit, lineCap: .round, lineJoin: .round)
    }

    private var ring: some View {
        Circle()
            .inset(by: 3 * unit)
            .trim(from: 0, to: tone == .loading ? 0.28 : (ringDrawn ? 1 : 0))
            .stroke(tint, style: stroke)
            .rotationEffect(.degrees(-90 + (spin ? 360 : 0)))
    }

    @ViewBuilder
    private var mark: some View {
        switch tone {
        case .success:
            ZenToastGlyphPath(points: [[(7.9, 12.4), (10.9, 15.4), (16.2, 9.4)]])
                .trim(from: 0, to: markDrawn ? 1 : 0)
                .stroke(tint, style: stroke)
        case .error:
            ZenToastGlyphPath(points: [[(9.3, 9.3), (14.7, 14.7)], [(14.7, 9.3), (9.3, 14.7)]])
                .trim(from: 0, to: markDrawn ? 1 : 0)
                .stroke(tint, style: stroke)
        case .warning:
            ZenToastGlyphPath(points: [[(12, 7.6), (12, 12.8)]])
                .stroke(tint, style: stroke)
                .offset(y: markDrawn ? 0 : -5 * unit)
                .opacity(markDrawn ? 1 : 0)
            dot(at: 16.3)
        case .info:
            ZenToastGlyphPath(points: [[(12, 11), (12, 16.2)]])
                .trim(from: 0, to: markDrawn ? 1 : 0)
                .stroke(tint, style: stroke)
            dot(at: 7.8)
        case .default, .loading:
            EmptyView()
        }
    }

    private func dot(at y: CGFloat) -> some View {
        Circle()
            .fill(tint)
            .frame(width: 2.2 * unit, height: 2.2 * unit)
            .position(x: 12 * unit, y: y * unit)
            .scaleEffect(dotShown ? 1 : 0.01, anchor: UnitPoint(x: 0.5, y: y / 24))
            .opacity(dotShown ? 1 : 0)
    }

    private func draw() async {
        if tone == .loading {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) { spin = true }
            return
        }
        guard !reduceMotion else {
            ringDrawn = true
            markDrawn = true
            dotShown = true
            return
        }

        let markDelay = isSwap ? 0.05 : 0.55
        if isSwap {
            ringDrawn = true
        } else {
            withAnimation(.timingCurve(0.4, 0, 0.2, 1, duration: 0.5).delay(0.15)) { ringDrawn = true }
        }
        withAnimation(tone == .warning
            ? .interpolatingSpring(stiffness: 320, damping: 26).delay(markDelay)
            : .timingCurve(0.4, 0, 0.2, 1, duration: 0.32).delay(markDelay)) {
            markDrawn = true
        }
        withAnimation(.interpolatingSpring(stiffness: 320, damping: 26).delay(markDelay + (tone == .warning ? 0.16 : 0))) {
            dotShown = true
        }
        try? await Task.sleep(for: .seconds(markDelay + 0.25))
        flourish += 1
    }

    private struct Flourish {
        var scale: CGFloat = 1
        var x: CGFloat = 0
        var rippleScale: CGFloat = 1
        var rippleOpacity: CGFloat = 0
    }
}

/// Polylines in Ding's 24pt icon grid, scaled to the frame.
private struct ZenToastGlyphPath: Shape {
    let points: [[(CGFloat, CGFloat)]]

    func path(in rect: CGRect) -> Path {
        let unit = rect.width / 24
        var path = Path()
        for line in points {
            guard let first = line.first else { continue }
            path.move(to: CGPoint(x: rect.minX + first.0 * unit, y: rect.minY + first.1 * unit))
            for point in line.dropFirst() {
                path.addLine(to: CGPoint(x: rect.minX + point.0 * unit, y: rect.minY + point.1 * unit))
            }
        }
        return path
    }
}

/// Ding's buttons: the primary is a filled 30pt capsule in the text colour, a secondary is
/// the same capsule left bare with dimmed text.
private struct ZenToastActionButton: View {
    let label: String
    let isPrimary: Bool
    let fill: Color
    let action: () -> Void

    @State private var isPointerOver = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.zen(.body2, weight: .semibold))
                .foregroundStyle(isPrimary ? Color.zenSurface : Color.zenTextPrimary.opacity(isPointerOver ? 1 : 0.65))
                .padding(.horizontal, isPrimary ? 14 : 10)
                .frame(height: 30)
                .background(Capsule().fill(background))
                .contentShape(Capsule())
        }
        .buttonStyle(ZenToastPressStyle())
        .onHover { isPointerOver = $0 }
        .accessibilityIdentifier(ZenAccessibilityID.Toast.actionButton)
    }

    private var background: Color {
        if isPrimary {
            return isPointerOver ? fill.opacity(0.82) : fill
        }
        return isPointerOver ? Color.zenTextPrimary.opacity(0.1) : .clear
    }
}

private struct ZenToastCloseButton: View {
    let action: () -> Void

    @State private var isPointerOver = false

    var body: some View {
        Button(action: action) {
            ZenToastGlyphPath(points: [[(6, 6), (18, 18)], [(18, 6), (6, 18)]])
                .stroke(Color.zenTextPrimary, style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                .frame(width: 12, height: 12)
                .frame(width: 30, height: 30)
                .background(Circle().fill(isPointerOver ? Color.zenTextPrimary.opacity(0.1) : .clear))
                .contentShape(Circle())
        }
        .buttonStyle(ZenToastPressStyle())
        .onHover { isPointerOver = $0 }
        .accessibilityLabel(Text("Dismiss notification"))
    }
}

private struct ZenToastPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct ToastAnimationSignature: Equatable {
    let id: ZenToastID
    let title: String
    let message: String?
    let tone: ZenToastTone
    let progress: Double?
}

@MainActor
private func zenToastPreviewCenter(
    maxVisibleToasts: Int = 3,
    _ seed: (ZenToastCenter) -> Void
) -> ZenToastCenter {
    let center = ZenToastCenter(maxVisibleToasts: maxVisibleToasts)
    seed(center)
    return center
}

private struct ZenToastPreviewStage<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Color.zenBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                Text(title)
                    .font(.zenTitle)
                    .foregroundStyle(Color.zenTextPrimary)

                Text(subtitle)
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(ZenSpacing.large)

            content()
        }
    }
}

#Preview("Tones") {
    ZenToastPreviewStage(
        title: "Tones",
        subtitle: "Every tone side by side, expanded so each card renders its own icon and colors."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter(maxVisibleToasts: 6) { center in
                _ = center.show("Invite sent", message: "Maya can join from her inbox.", duration: nil)
                _ = center.info("New release available", message: "Version 2.4 is ready to install.", duration: nil)
                _ = center.success("Deployed successfully", message: "Your Worker is now live.", duration: nil)
                _ = center.warning("Rate limit warning", message: "You're approaching your API quota.", duration: nil)
                _ = center.error("Sync failed", message: "Check your connection and try again.", duration: nil)
                _ = center.loading("Exporting previews", message: "Compressing assets")
            },
            edge: .top
        )
    }
}

/// The action glyph on an attributed toast's avatar. A checkbox badge appears
/// in the state the item was in *before* the change and flips a beat later, so
/// the reader watches the toggle happen instead of being told about it.
private struct ZenToastAvatarBadgeView: View {
    let badge: ZenToastAvatarBadge
    let diameter: CGFloat
    /// The card has opened: flip only then, so the toggle plays where it can be read.
    let isRevealed: Bool

    @State private var hasSettled = false

    private var icon: HugeIcon {
        switch badge {
        case .checkbox(let isChecked):
            let settledState = hasSettled ? isChecked : !isChecked
            return settledState ? .checkmarkCircleFill : .circle
        case .icon(let icon):
            return icon
        }
    }

    private var tint: Color {
        switch badge.tone {
        case .success: ZenTheme.current.resolvedColors.success.color
        default: Color.zenTextMuted
        }
    }

    var body: some View {
        ZenIcon(icon: icon, size: diameter * 0.72)
            .font(.system(size: diameter * 0.72, weight: .bold))
            .foregroundStyle(isSettledCheckbox ? tint : Color.zenTextMuted)
            .frame(width: diameter, height: diameter)
            .background(Color.zenSurface, in: Circle())
            .overlay(Circle().strokeBorder(Color.zenBorder, lineWidth: 1))
            .scaleEffect(isSettledCheckbox ? 1 : 0.86)
            .animation(.spring(response: 0.34, dampingFraction: 0.6), value: hasSettled)
            .task(id: isRevealed) {
                guard case .checkbox = badge, isRevealed, !hasSettled else { return }
                try? await Task.sleep(for: .milliseconds(180))
                hasSettled = true
            }
            .accessibilityHidden(true)
    }

    private var isSettledCheckbox: Bool {
        if case .checkbox = badge { return hasSettled }
        return true
    }
}

#Preview("Attributed") {
    ZenToastPreviewStage(
        title: "Attributed",
        subtitle: "Toasts raised on someone else's behalf lead with their avatar instead of a tone icon."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter(maxVisibleToasts: 3) { center in
                _ = center.activity(
                    "Diana · Checked off 3 items",
                    avatar: ZenToastAvatar(name: "Diana", badge: .checkbox(isChecked: true)),
                    duration: nil
                )
                _ = center.activity(
                    "Marek · Added milk",
                    avatar: ZenToastAvatar(name: "Marek", badge: .icon(.plus)),
                    duration: nil
                )
                _ = center.activity(
                    "Kasia · Unchecked bread",
                    avatar: ZenToastAvatar(name: "Kasia", badge: .checkbox(isChecked: false)),
                    duration: nil
                )
            },
            edge: .top
        )
    }
}

#Preview("Title only") {
    ZenToastPreviewStage(
        title: "Title only",
        subtitle: "No message body — the card collapses to a single line."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter { center in
                _ = center.success("Copied to clipboard", duration: nil)
                _ = center.show("Draft saved", duration: nil)
            },
            edge: .top
        )
    }
}

#Preview("Actions") {
    ZenToastPreviewStage(
        title: "Actions",
        subtitle: "Emphasised and quiet action links, a dot-separated pair, and a non-dismissing action."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter { center in
                _ = center.error(
                    "Upload failed",
                    message: "The file exceeded the 25 MB limit.",
                    duration: nil,
                    actions: [ZenToastAction("Retry", handler: {})]
                )
                _ = center.success(
                    "Deployed successfully",
                    message: "Your Worker is now live.",
                    duration: nil,
                    actions: [
                        ZenToastAction("Support", handler: {}),
                        ZenToastAction("Ask AI", variant: .default, handler: {}),
                    ]
                )
                _ = center.info(
                    "Background job running",
                    message: "Keep this open to follow along.",
                    duration: nil,
                    actions: [ZenToastAction("View log", dismissesToast: false, handler: {})]
                )
            },
            edge: .top
        )
    }
}

#Preview("Progress") {
    ZenToastPreviewStage(
        title: "Progress",
        subtitle: "Determinate progress at the start, middle, and end of a run."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter { center in
                _ = center.loading("Uploading assets", message: "1 of 12 files", progress: 0.08)
                _ = center.loading(
                    "Exporting previews",
                    message: "Compressing assets",
                    progress: 0.58,
                    actions: [ZenToastAction("View queue", handler: {})]
                )
                _ = center.success("Export complete", message: "12 files written.", duration: nil, progress: 1)
            },
            edge: .top
        )
    }
}

#Preview("Loading") {
    ZenToastPreviewStage(
        title: "Loading",
        subtitle: "Indeterminate spinner with no timeout — the toast lives until the work resolves."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter { center in
                _ = center.loading("Connecting to workspace")
                _ = center.loading("Rebuilding index", message: "This can take a minute.")
            },
            edge: .top
        )
    }
}

#Preview("Long content") {
    ZenToastPreviewStage(
        title: "Long content",
        subtitle: "Wrapping title and multi-line message next to the close button."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter { center in
                _ = center.error(
                    "Deployment rolled back after a failed health check",
                    message: """
                    Three of five instances failed readiness probes within the grace period, so the                     previous revision was restored automatically. No traffic was served by the new build.
                    """,
                    duration: nil,
                    actions: [ZenToastAction("View logs", handler: {})]
                )
            },
            edge: .top
        )
    }
}

#Preview("Stack – bottom") {
    ZenToastPreviewStage(
        title: "Collapsed stack",
        subtitle: "Bottom edge. Hover or press the stack to expand it."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter { center in
                _ = center.show("Invite sent", message: "Maya can join from her inbox.", duration: nil)
                _ = center.warning("Rate limit warning", message: "You're approaching your API quota.", duration: nil)
                _ = center.success("Deployed successfully", message: "Your Worker is now live.", duration: nil)
            },
            edge: .bottom
        )
    }
}

#Preview("Queue overflow") {
    ZenToastPreviewStage(
        title: "Queue overflow",
        subtitle: "Two visible slots with three more waiting; each dismissal promotes the next."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter(maxVisibleToasts: 2) { center in
                _ = center.info("Queued 1", message: "Waiting its turn.", duration: nil)
                _ = center.info("Queued 2", message: "Waiting its turn.", duration: nil)
                _ = center.info("Queued 3", message: "Waiting its turn.", duration: nil)
                _ = center.info("Queued 4", message: "Waiting its turn.", duration: nil)
                _ = center.info("Queued 5", message: "Waiting its turn.", duration: nil)
            },
            edge: .top
        )
    }
}

#Preview("Dark") {
    ZenToastPreviewStage(
        title: "Dark",
        subtitle: "The same tone set rendered in the dark color scheme."
    ) {
        ZenToastHost(
            center: zenToastPreviewCenter(maxVisibleToasts: 4) { center in
                _ = center.success("Deployed successfully", message: "Your Worker is now live.", duration: nil)
                _ = center.warning("Rate limit warning", message: "You're approaching your API quota.", duration: nil)
                _ = center.error("Sync failed", message: "Check your connection and try again.", duration: nil)
                _ = center.loading("Exporting previews", message: "Compressing assets", progress: 0.42)
            },
            edge: .top
        )
    }
    .preferredColorScheme(.dark)
}
