import SwiftUI

public enum ZenToastHostEdge: Sendable {
    case top
    case bottom
}

public struct ZenToastHost: View {
    @ObservedObject private var center: ZenToastCenter
    private let edge: ZenToastHostEdge

    @GestureState private var isReviewingStack = false

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
        GeometryReader { proxy in
            let layout = Layout(edge: edge, size: proxy.size)

            ZenOverlayHost(
                configuration: .edgeStack(
                    alignment: layout.hostAlignment,
                    allowsHitTesting: !center.visibleToasts.isEmpty,
                    overlayTransition: layout.transition,
                    animation: .spring(response: 0.38, dampingFraction: 0.84)
                )
            ) {
                Color.clear
            } overlay: {
                overlayContent(for: proxy.size, layout: layout)
            }
                .accessibilityIdentifier(ZenAccessibilityID.Toast.host)
        }
    }

    @ViewBuilder
    private func overlayContent(for size: CGSize, layout: Layout) -> some View {
        let displayedToasts = Array(center.visibleToasts.reversed())

        ZStack(alignment: layout.stackAlignment) {
            ForEach(Array(displayedToasts.enumerated()), id: \.element.id) { depth, toast in
                ZenToastCard(
                    toast: toast,
                    edge: edge,
                    depth: depth,
                    isExpanded: isReviewingStack,
                    onAction: { handleAction(for: toast) },
                    onDismiss: { dismissToast(toast) }
                )
                .frame(maxWidth: maxWidth(for: size), alignment: layout.cardAlignment)
                .offset(y: layout.verticalOffset(for: depth, expanded: isReviewingStack))
                .scaleEffect(scale(for: depth, expanded: isReviewingStack), anchor: layout.cardAnchor)
                .zIndex(Double(displayedToasts.count - depth))
                .transition(layout.transition)
                .accessibilityHidden(!isReviewingStack && depth > 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: layout.hostAlignment)
        .simultaneousGesture(stackReviewGesture)
        .onChange(of: isReviewingStack) { isReviewingStack in
            if isReviewingStack {
                center.pauseAutoDismiss()
            } else {
                center.resumeAutoDismiss()
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.84), value: stackAnimationSignature)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isReviewingStack)
    }

    private var stackReviewGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isReviewingStack) { _, state, _ in
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

    private func maxWidth(for size: CGSize) -> CGFloat {
        size.width >= 700 ? 360 : min(size.width - (ZenSpacing.medium * 2), 520)
    }

    private func scale(for depth: Int, expanded: Bool) -> CGFloat {
        expanded ? 1 : max(0.9, 1 - (CGFloat(depth) * 0.04))
    }

    @MainActor
    private func handleAction(for toast: ZenToastItem) {
        toast.action?.handler()
        center.dismiss(toast.id)
    }

    @MainActor
    private func dismissToast(_ toast: ZenToastItem) {
        center.dismiss(toast.id)
    }
}

extension ZenToastHost {
    struct Layout {
        let edge: ZenToastHostEdge
        let size: CGSize

        var hostAlignment: Alignment {
            switch (edge, isWide) {
            case (.top, true):
                return .topTrailing
            case (.top, false):
                return .top
            case (.bottom, true):
                return .bottomTrailing
            case (.bottom, false):
                return .bottom
            }
        }

        var stackAlignment: Alignment {
            hostAlignment
        }

        var cardAlignment: Alignment {
            .trailing
        }

        var cardAnchor: UnitPoint {
            switch edge {
            case .top:
                return .topTrailing
            case .bottom:
                return .bottomTrailing
            }
        }

        var insertionOffsetY: CGFloat {
            switch edge {
            case .top:
                return -88
            case .bottom:
                return 88
            }
        }

        var removalOffsetY: CGFloat {
            insertionOffsetY
        }

        var transition: AnyTransition {
            .asymmetric(
                insertion: .offset(y: insertionOffsetY).combined(with: .opacity),
                removal: .offset(y: removalOffsetY).combined(with: .opacity)
            )
        }

        func verticalOffset(for depth: Int, expanded: Bool) -> CGFloat {
            let base = expanded ? CGFloat(depth) * 72 : CGFloat(depth) * 12

            switch edge {
            case .top:
                return base
            case .bottom:
                return -base
            }
        }

        private var isWide: Bool {
            size.width >= 700
        }

        func shouldDismiss(for translation: CGSize, threshold: CGFloat = 96) -> Bool {
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

private struct ZenToastCard: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    let toast: ZenToastItem
    let edge: ZenToastHostEdge
    let depth: Int
    let isExpanded: Bool
    let onAction: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var previousTone: ZenToastTone?
    @State private var completionPulse = false

    var body: some View {
        let theme = ZenTheme.current
        let cardCornerRadius = theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: parentCornerRadius)

        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            HStack(alignment: .center, spacing: ZenSpacing.small) {
                iconView

                VStack(alignment: .leading, spacing: 4) {
                    Text(toast.title)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(Color.zenTextPrimary)

                    if let message = toast.message {
                        Text(message)
                            .font(.zenGroup)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.2), value: toast.title)
                .animation(.easeInOut(duration: 0.2), value: toast.message)

                Button {
                    onDismiss()
                } label: {
                    ZenIcon(systemName: "xmark", size: 10)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(ZenAccessibilityID.Toast.closeButton)
            }

            if let action = toast.action {
                Button(action: onAction) {
                    Text(action.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(tintColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(ZenAccessibilityID.Toast.actionButton)
            }

            if let progress = toast.progress {
                ZenToastProgressBar(
                    progress: progress,
                    tintColor: tintColor,
                    subtleColor: subtleColor
                )
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .zenContainerCornerRadius(cardCornerRadius)
        .shadow(color: Color.black.opacity(depth == 0 ? 0.14 : 0.08), radius: 16, x: 0, y: 8)
        .scaleEffect(completionPulse ? 1.02 : 1)
        .offset(dragOffset)
        .gesture(dismissGesture)
        .animation(.spring(response: 0.24, dampingFraction: 0.82), value: dragOffset)
        .animation(.easeInOut(duration: 0.22), value: toast.progress)
        .animation(.easeInOut(duration: 0.22), value: toast.tone)
        .animation(.easeInOut(duration: 0.22), value: isExpanded)
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
        if toast.tone == .loading {
            ZenSpinner(size: .medium, tint: tintColor, showsTrack: false)
                .frame(width: 18, height: 18)
                .transition(.scale(scale: 0.88).combined(with: .opacity))
        } else {
            ZenIcon(systemName: iconSystemName, size: 18)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tintColor)
                .frame(width: 18, height: 18)
                .transition(.scale(scale: 0.88).combined(with: .opacity))
        }
    }

    private var iconSystemName: String {
        switch toast.tone {
        case .default:
            return "bell.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.octagon.fill"
        case .loading:
            return "arrow.triangle.2.circlepath"
        }
    }

    private var tintColor: Color {
        switch toast.tone {
        case .default, .loading:
            return .zenPrimary
        case .success:
            return .zenSuccess
        case .error:
            return .zenCritical
        }
    }

    private var borderColor: Color {
        let colors = ZenTheme.current.resolvedColors

        switch toast.tone {
        case .default, .loading:
            return colors.focusRing.color
        case .success:
            return colors.successBorder.color
        case .error:
            return colors.criticalBorder.color
        }
    }

    private var subtleColor: Color {
        let colors = ZenTheme.current.resolvedColors

        switch toast.tone {
        case .default, .loading:
            return colors.primarySubtle.color
        case .success:
            return colors.successSubtle.color
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
private func zenToastHostPreviewCenter() -> ZenToastCenter {
    let center = ZenToastCenter(maxVisibleToasts: 3)
    _ = center.show(
        "Invite sent",
        message: "Maya can join the workspace from her inbox."
    )
    _ = center.loading(
        "Processing images",
        message: "Generating optimized previews",
        progress: 0.42,
        action: ZenToastAction("Open uploads", handler: {})
    )
    _ = center.error(
        "Publish failed",
        message: "There was a problem reaching the server."
    )
    return center
}

#Preview {
    ZStack {
        Color.zenBackground
            .ignoresSafeArea()

        ZenToastHost(center: zenToastHostPreviewCenter())
    }
}
