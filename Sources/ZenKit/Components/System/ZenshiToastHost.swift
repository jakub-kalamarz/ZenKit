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
        let displayedToasts = Array(center.visibleToasts.reversed())
        let isExpanded = isStackExpanded
        let stackSize = displayedToasts.first.flatMap { naturalSizes[$0.id] } ?? Layout.estimatedCardSize

        ZStack(alignment: layout.stackAlignment) {
            ForEach(Array(displayedToasts.enumerated()), id: \.element.id) { depth, toast in
                let measuredSize = naturalSizes[toast.id]
                let cardHeight = measuredSize?.height ?? stackSize.height

                ZenToastCard(
                    toast: toast,
                    edge: edge,
                    isFrontmost: depth == 0,
                    isExpanded: isExpanded,
                    // Collapsed, every card is squashed to the frontmost card's
                    // height so the peeking slivers line up. Left unconstrained
                    // until it has been measured, so nothing snaps on insertion.
                    // Cards hug their own content, except behind a collapsed
                    // stack, where they borrow the frontmost card's width so the
                    // peeking slivers line up instead of reading as ragged edges.
                    displayWidth: (isExpanded || depth == 0) ? nil : stackSize.width,
                    displayHeight: measuredSize.map { isExpanded ? $0.height : stackSize.height },
                    isInteractive: isExpanded || depth == 0,
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
                .transition(layout.transition(cardHeight: cardHeight))
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
        static let peek: CGFloat = 12
        /// Spacing between cards once the stack is fanned out.
        static let gap: CGFloat = 12
        /// Each step back in the stack shrinks the card by this fraction.
        static let scaleStep: CGFloat = 0.1
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
        /// Enter/exit travel as a multiple of the card's own height.
        static let transitionTravelRatio: CGFloat = 1.5

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

        func transitionOffset(cardHeight: CGFloat) -> CGFloat {
            let travel = max(cardHeight, Self.estimatedCardHeight) * Self.transitionTravelRatio
            return -stackDirection * travel
        }

        /// Cards slide in from beyond the anchored edge and leave the same way,
        /// fading only on the way out.
        func transition(cardHeight: CGFloat) -> AnyTransition {
            let offset = transitionOffset(cardHeight: cardHeight)

            return .asymmetric(
                insertion: .offset(y: offset),
                removal: .offset(y: offset).combined(with: .opacity)
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

private struct ZenToastCard: View {
    let toast: ZenToastItem
    let edge: ZenToastHostEdge
    let isFrontmost: Bool
    let isExpanded: Bool
    let displayWidth: CGFloat?
    let displayHeight: CGFloat?
    let isInteractive: Bool
    let onAction: (ZenToastAction) -> Void
    let onDismiss: () -> Void

    @Environment(\.displayScale) private var displayScale

    @State private var dragOffset: CGSize = .zero
    @State private var previousTone: ZenToastTone?
    @State private var completionPulse = false

    private static let cornerRadiusFallback: CGFloat = 12
    private static let padding: CGFloat = 16
    private static let iconSize: CGFloat = 16

    var body: some View {
        let cornerRadius = ZenTheme.current.resolvedCornerRadius(for: .container)
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack(alignment: contentAlignment) {
            cardContent
                .background(sizeReader)
                // Pinned to its natural height so squashing the card below it
                // never feeds back into the measurement.
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: displayWidth, height: displayHeight, alignment: contentAlignment)
        .background(cardBackground)
        .clipShape(shape)
        .overlay(shape.strokeBorder(borderColor, lineWidth: borderWidth))
        .zenContainerCornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        .scaleEffect(completionPulse ? 1.02 : 1)
        .offset(dragOffset)
        .gesture(dismissGesture, including: isInteractive ? .all : .none)
        .animation(.spring(response: 0.24, dampingFraction: 0.82), value: dragOffset)
        .animation(ZenToastHost.Layout.heightAnimation, value: displayWidth)
        .animation(ZenToastHost.Layout.heightAnimation, value: displayHeight)
        .animation(.easeInOut(duration: 0.22), value: toast.tone)
        .onAppear {
            previousTone = toast.tone
        }
        .onChange(of: toast.tone) { tone in
            if previousTone == .loading, tone != .loading {
                animateCompletionPulse()
            }
            previousTone = tone
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ZenAccessibilityID.Toast.card)
    }

    /// Only the frontmost card shows its contents while the stack is collapsed;
    /// the ones behind read as blank tinted slivers.
    private var contentOpacity: Double {
        (isExpanded || isFrontmost) ? 1 : 0
    }

    private var contentAlignment: Alignment {
        switch edge {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            HStack(alignment: .top, spacing: ZenSpacing.small) {
                iconView

                VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                    Text(toast.title)
                        .font(.zen(.body, weight: .medium))
                        .foregroundStyle(titleColor)
                        .accessibilityIdentifier(ZenAccessibilityID.Toast.title)

                    if let message = toast.message {
                        Text(message)
                            .font(.zenBody)
                            .foregroundStyle(Color.zenTextPrimary.opacity(0.7))
                    }

                    if !toast.actions.isEmpty {
                        actionsRow
                    }

                    if let progress = toast.progress {
                        ZenToastProgressBar(
                            progress: progress,
                            tintColor: tintColor,
                            subtleColor: subtleColor
                        )
                            .padding(.top, ZenSpacing.xSmall)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: toast.title)
                .animation(.easeInOut(duration: 0.2), value: toast.message)
                .animation(.easeInOut(duration: 0.22), value: toast.progress)
            }
        }
        .padding(Self.padding)
        .opacity(contentOpacity)
        .allowsHitTesting(contentOpacity == 1)
        .animation(ZenToastHost.Layout.contentFadeAnimation, value: contentOpacity)
    }

    /// Actions read as text links rather than buttons: no chrome to compete
    /// with the tone tint, separated by a dot when there is more than one.
    private var actionsRow: some View {
        HStack(spacing: ZenSpacing.xSmall) {
            ForEach(Array(toast.actions.enumerated()), id: \.element.id) { index, action in
                if index > 0 {
                    Text(verbatim: "·")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                        .accessibilityHidden(true)
                }

                ZenToastActionLink(
                    label: action.label,
                    tint: actionColor(for: action.variant)
                ) {
                    onAction(action)
                }
            }
        }
        .padding(.top, ZenSpacing.xSmall)
    }

    /// The emphasised variants keep the tone tint; the quiet ones step back to
    /// muted text so a secondary action never outweighs the primary one.
    private func actionColor(for variant: ZenButtonVariant) -> Color {
        switch variant {
        case .default, .glassProminent:
            return tintColor
        case .destructive:
            return .zenCritical
        case .plain, .glass, .outline, .secondary, .ghost, .link:
            return .zenTextMuted
        }
    }

    private var sizeReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ZenToastCardSizePreferenceKey.self,
                    value: [toast.id: proxy.size]
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

    @ViewBuilder
    private var iconView: some View {
        switch toast.tone {
        case .loading:
            ZenSpinner(size: .custom(diameter: Self.iconSize), tint: tintColor, showsTrack: false)
                .padding(.top, 2)
                .transition(.scale(scale: 0.88).combined(with: .opacity))
        case .default:
            // The default tone carries no icon, so the text starts at the edge.
            EmptyView()
        case .success, .error, .warning, .info:
            ZenIcon(icon: icon, size: Self.iconSize)
                .font(.system(size: Self.iconSize, weight: .semibold))
                .foregroundStyle(tintColor)
                .frame(width: Self.iconSize, height: Self.iconSize)
                .padding(.top, 2)
                .transition(.scale(scale: 0.88).combined(with: .opacity))
        }
    }

    private var icon: HugeIcon {
        switch toast.tone {
        case .default:
            return .bellFill
        case .success:
            return .checkmarkCircleFill
        case .error:
            return .exclamationmarkTriangleFill
        case .warning:
            return .exclamationmarkTriangleFill
        case .info:
            return .infoCircleFill
        case .loading:
            return .arrowTriangle2Circlepath
        }
    }

    private var tintColor: Color {
        switch toast.tone {
        case .default, .loading, .info:
            return .zenPrimary
        case .success:
            return .zenSuccess
        case .warning:
            return .zenWarning
        case .error:
            return .zenCritical
        }
    }

    /// Tone-carrying toasts colour the title too; the neutral ones stay plain.
    private var titleColor: Color {
        switch toast.tone {
        case .default, .loading:
            return .zenTextPrimary
        case .success, .error, .warning, .info:
            return tintColor
        }
    }

    private var cardBackground: some View {
        ZStack {
            Color.zenSurface
            toneTint
        }
    }

    /// A wash of the tone over the surface, keyed to the reference's tint
    /// strengths — success sits back further than the rest.
    @ViewBuilder
    private var toneTint: some View {
        switch toast.tone {
        case .default, .loading:
            EmptyView()
        case .success:
            Color.zenSuccessTint.opacity(0.2)
        case .error:
            Color.zenCriticalTint.opacity(0.5)
        case .warning:
            Color.zenWarningTint.opacity(0.5)
        case .info:
            Color.zenInfoTint.opacity(0.5)
        }
    }

    /// Neutral toasts get a full hairline; tone-carrying ones get the reference's
    /// sub-pixel ring, which reads as a faint tinted edge.
    ///
    /// Both are rounded to a whole number of device pixels. A literal 0.5pt line
    /// is 1.5px at @3x, so the renderer has to split it across two pixel rows —
    /// unevenly along the straight edges, and differently again around the corner
    /// arcs, which is what made the ring look ragged rather than faint.
    private var borderWidth: CGFloat {
        let scale = displayScale > 0 ? displayScale : 1
        let requested: CGFloat
        switch toast.tone {
        case .default, .loading:
            requested = 1
        case .success, .error, .warning, .info:
            requested = 0.5
        }
        return max(1, (requested * scale).rounded()) / scale
    }

    private var borderColor: Color {
        let colors = ZenTheme.current.resolvedColors

        switch toast.tone {
        case .default, .loading:
            return colors.borderSubtle.color
        case .success:
            return colors.success.color
        case .warning:
            return colors.warning.color
        case .error:
            return colors.critical.color
        case .info:
            return colors.primary.color
        }
    }

    private var subtleColor: Color {
        let colors = ZenTheme.current.resolvedColors

        switch toast.tone {
        case .default, .loading, .info:
            return colors.primarySubtle.color
        case .success:
            return colors.successSubtle.color
        case .warning:
            return colors.warningSubtle.color
        case .error:
            return colors.criticalSubtle.color
        }
    }

    private func animateCompletionPulse() {
        completionPulse = false
        withAnimation(.spring(response: 0.24, dampingFraction: 0.62)) {
            completionPulse = true
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 180_000_000)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                completionPulse = false
            }
        }
    }
}

/// Square ghost control carrying the reference's tinted hover/press wash. Touch
/// platforms have no hover, so a press stands in for it there.
private struct ZenToastActionLink: View {
    let label: String
    let tint: Color
    let action: () -> Void

    @State private var isPointerOver = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.zen(.body, weight: .medium))
                .underline(isPointerOver)
                .foregroundStyle(tint)
                .contentShape(Rectangle())
        }
        .buttonStyle(ZenToastActionLinkStyle())
        .onHover { isInside in
            isPointerOver = isInside
        }
        .accessibilityIdentifier(ZenAccessibilityID.Toast.actionButton)
    }
}

private struct ZenToastActionLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct ZenToastProgressBar: View {
    let progress: Double
    let tintColor: Color
    let subtleColor: Color

    var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedFullyRoundedCornerRadius(for: 5)

        GeometryReader { proxy in
            let clamped = min(max(progress, 0), 1)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(subtleColor)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tintColor)
                    .frame(width: proxy.size.width * clamped)
            }
        }
        .frame(height: 5)
        .accessibilityValue(Text("\(Int((min(max(progress, 0), 1) * 100).rounded())) percent"))
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
