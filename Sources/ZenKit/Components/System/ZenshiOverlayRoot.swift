import SwiftUI

private struct ZenOverlayPresenterKey: EnvironmentKey {
    static let defaultValue: ZenOverlayPresenter? = nil
}

extension EnvironmentValues {
    var zenOverlayPresenter: ZenOverlayPresenter? {
        get { self[ZenOverlayPresenterKey.self] }
        set { self[ZenOverlayPresenterKey.self] = newValue }
    }
}

@MainActor
final class ZenOverlayPresenter: ObservableObject {
    @Published private(set) var confirmationDialog: ConfirmationDialogState?

    struct ConfirmationDialogState: Equatable, Identifiable {
        let id: UUID
        let title: String
        let message: String?
        let actions: [ConfirmationDialogActionState]
    }

    struct ConfirmationDialogActionState: Equatable, Identifiable {
        let id: UUID
        let title: LocalizedStringKey
        let role: ButtonRole?
        let action: @MainActor () -> Void

        static func == (lhs: ConfirmationDialogActionState, rhs: ConfirmationDialogActionState) -> Bool {
            lhs.id == rhs.id && lhs.role == rhs.role
        }
    }

    func presentConfirmationDialog(
        id: UUID,
        title: String,
        message: String?,
        actions: [ZenConfirmationDialogAction]
    ) {
        confirmationDialog = ConfirmationDialogState(
            id: id,
            title: title,
            message: message,
            actions: actions.map {
                ConfirmationDialogActionState(
                    id: UUID(),
                    title: $0.title,
                    role: $0.role,
                    action: $0.action
                )
            }
        )
    }

    func dismissConfirmationDialog(id: UUID? = nil) {
        guard let id else {
            confirmationDialog = nil
            return
        }

        if confirmationDialog?.id == id {
            confirmationDialog = nil
        }
    }
}

public struct ZenOverlayRoot<Content: View>: View {
    @StateObject private var presenter = ZenOverlayPresenter()
    @State private var dialogRenderState = ZenConfirmationDialogRenderState()
    @State private var dismissalTask: Task<Void, Never>?
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZenOverlayHost(
            configuration: .centeredModal(
                scrimTransition: ZenConfirmationDialogMotion.backdropTransition,
                overlayTransition: .identity,
                scrimPresentAnimation: .easeOut(duration: 0.16),
                scrimDismissAnimation: .easeOut(duration: 0.12),
                presentAnimation: ZenConfirmationDialogMotion.presentAnimation,
                dismissAnimation: ZenConfirmationDialogMotion.dismissAnimation
            ),
            isOverlayPresented: dialogRenderState.renderedDialog != nil,
            isOverlayVisible: dialogRenderState.isPresented
        ) {
            content
                .environment(\.zenOverlayPresenter, presenter)
        } overlay: {
            if let dialog = dialogRenderState.renderedDialog {
                ZenRootConfirmationDialogPresentation(
                    state: dialog,
                    isPresented: dialogRenderState.isPresented,
                    dismiss: { presenter.dismissConfirmationDialog(id: dialog.id) }
                )
            }
        }
        .task(id: presenter.confirmationDialog) {
            syncDialogRenderState(with: presenter.confirmationDialog)
        }
    }

    private func syncDialogRenderState(with dialog: ZenOverlayPresenter.ConfirmationDialogState?) {
        dismissalTask?.cancel()
        dismissalTask = nil

        dialogRenderState.sync(with: dialog)

        guard dialog == nil else {
            return
        }

        dismissalTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(ZenConfirmationDialogMotion.dismissCompletionDelay))
            guard !Task.isCancelled else {
                return
            }
            dialogRenderState.finishDismissalIfNeeded()
            dismissalTask = nil
        }
    }
}

private struct ZenRootConfirmationDialogPresentation: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    let state: ZenOverlayPresenter.ConfirmationDialogState
    let isPresented: Bool
    let dismiss: () -> Void
    @State private var hasAnimatedIn = false
    @State private var isShellVisible = false

    var body: some View {
        let cornerRadius = parentCornerRadius.map {
            min(ZenTheme.current.resolvedCornerRadius(for: ZenRadius.large), ZenTheme.current.resolvedCornerRadius(for: .nestedContainer, parentRadius: $0))
        } ?? ZenTheme.current.resolvedCornerRadius(for: ZenRadius.large)

        VStack(spacing: 0) {
            VStack(spacing: ZenSpacing.small) {
                Text(state.title)
                    .font(.zenDisplayXS)
                    .foregroundStyle(Color.zenTextPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(ZenAccessibilityID.ConfirmationDialog.title)
                    .modifier(
                        ZenConfirmationDialogContentStage(
                            isVisible: hasAnimatedIn,
                            delay: 0,
                            reduceMotion: usesReducedMotion
                        )
                    )

                if let message = state.message {
                    Text(message)
                        .font(.zenTextBase)
                        .foregroundStyle(Color.zenTextMuted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .modifier(
                            ZenConfirmationDialogContentStage(
                                isVisible: hasAnimatedIn,
                                delay: ZenConfirmationDialogMotion.contentMessageDelay,
                                reduceMotion: usesReducedMotion
                            )
                        )
                }
            }
            .padding(.horizontal, ZenSpacing.large)
            .padding(.top, ZenSpacing.large)
            .padding(.bottom, ZenSpacing.medium)

            Rectangle()
                .fill(Color.zenBorder.opacity(0.8))
                .frame(height: 1)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: ZenSpacing.small) {
                    ForEach(Array(state.actions.enumerated()), id: \.element.id) { index, action in
                        dialogActionButton(action, index: index)
                    }
                }
                .padding(ZenSpacing.medium)

                VStack(spacing: ZenSpacing.small) {
                    ForEach(Array(state.actions.enumerated()), id: \.element.id) { index, action in
                        dialogActionButton(action, index: index, fullWidth: true)
                    }
                }
                .padding(ZenSpacing.medium)
            }
            .modifier(
                ZenConfirmationDialogContentStage(
                    isVisible: hasAnimatedIn,
                    delay: ZenConfirmationDialogMotion.contentActionsDelay,
                    reduceMotion: usesReducedMotion
                )
            )
            .background(Color.zenSurfaceMuted.opacity(0.55))
        }
        .frame(maxWidth: 360)
        .background(Color.zenSurface)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.zenBorder.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 16)
        .zenContainerCornerRadius(cornerRadius)
        .opacity(isShellVisible ? 1 : 0)
        .scaleEffect(shellScale)
        .offset(y: shellOffsetY)
        .animation(shellAnimation, value: isShellVisible)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ZenAccessibilityID.ConfirmationDialog.container)
        .onAppear {
            isShellVisible = false
            hasAnimatedIn = false
            withAnimation(ZenConfirmationDialogMotion.presentAnimation) {
                isShellVisible = true
            }
            withAnimation(ZenConfirmationDialogMotion.presentAnimation) {
                hasAnimatedIn = true
            }
        }
        .onChange(of: isPresented) { newValue in
            withAnimation(newValue ? ZenConfirmationDialogMotion.presentAnimation : ZenConfirmationDialogMotion.dismissAnimation) {
                isShellVisible = newValue
            }
        }
    }

    @ViewBuilder
    private func dialogActionButton(
        _ action: ZenOverlayPresenter.ConfirmationDialogActionState,
        index: Int,
        fullWidth: Bool = false
    ) -> some View {
        ZenButton(
            variant: variant(for: action.role),
            fullWidth: fullWidth || state.actions.count > 1,
            action: {
                dismiss()
                action.action()
            },
            label: {
                Text(action.title)
            }
        )
        .accessibilityIdentifier(accessibilityID(for: action.role, index: index))
    }

    private func variant(for role: ButtonRole?) -> ZenButtonVariant {
        switch role {
        case .destructive:
            return .destructive
        case .cancel:
            return .secondary
        default:
            return .default
        }
    }

    private func accessibilityID(for role: ButtonRole?, index: Int) -> String {
        switch role {
        case .cancel:
            return ZenAccessibilityID.ConfirmationDialog.cancelButton
        default:
            return index == state.actions.count - 1
                ? ZenAccessibilityID.ConfirmationDialog.confirmButton
                : "confirmation-dialog.action.\(index)"
        }
    }

    private var usesReducedMotion: Bool {
        reduceMotion || ZenTheme.current.motion == .reduced
    }

    private var shellScale: CGFloat {
        if usesReducedMotion {
            return 1
        }

        return isShellVisible ? 1 : (isPresented ? ZenConfirmationDialogMotion.enterScale : ZenConfirmationDialogMotion.exitScale)
    }

    private var shellOffsetY: CGFloat {
        if usesReducedMotion {
            return 0
        }

        return isShellVisible ? 0 : (isPresented ? ZenConfirmationDialogMotion.enterOffsetY : ZenConfirmationDialogMotion.exitOffsetY)
    }

    private var shellAnimation: Animation {
        isPresented ? ZenConfirmationDialogMotion.presentAnimation : ZenConfirmationDialogMotion.dismissAnimation
    }
}

private struct ZenConfirmationDialogContentStage: ViewModifier {
    let isVisible: Bool
    let delay: Double
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : ZenConfirmationDialogMotion.contentEnterOffsetY)
            .scaleEffect(reduceMotion ? 1 : (isVisible ? 1 : 0.985))
            .animation(animation, value: isVisible)
    }

    private var animation: Animation {
        if reduceMotion {
            return .easeOut(duration: 0.12)
        }

        return .spring(response: 0.3, dampingFraction: 0.84).delay(delay)
    }
}

struct ZenConfirmationDialogRenderState {
    private(set) var renderedDialog: ZenOverlayPresenter.ConfirmationDialogState?
    private(set) var isPresented = false

    mutating func sync(with dialog: ZenOverlayPresenter.ConfirmationDialogState?) {
        if let dialog {
            renderedDialog = dialog
            isPresented = true
        } else {
            isPresented = false
        }
    }

    mutating func finishDismissalIfNeeded() {
        guard !isPresented else {
            return
        }

        renderedDialog = nil
    }
}
