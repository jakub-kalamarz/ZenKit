import SwiftUI

enum ZenConfirmationDialogMotion {
    static let presentationStyle: ZenOverlayPresentationStyle = .centeredOverlay
    static let backdropOpacity: Double = 0.18
    static let enterOffsetY: CGFloat = 12
    static let exitOffsetY: CGFloat = 6
    static let enterScale: CGFloat = 0.945
    static let exitScale: CGFloat = 0.985
    static let contentEnterOffsetY: CGFloat = 10
    static let contentMessageDelay: Double = 0.03
    static let contentActionsDelay: Double = 0.08
    static let presentAnimation: Animation = .spring(response: 0.34, dampingFraction: 0.78)
    static let dismissAnimation: Animation = .easeOut(duration: 0.18)
    static let dismissDuration: Double = 0.18
    static let dismissCompletionDelay: Double = 0.26
    static let backdropTransition: AnyTransition = .asymmetric(
        insertion: .opacity.animation(.easeOut(duration: 0.16)),
        removal: .opacity.animation(.easeOut(duration: 0.12))
    )
    static let cardTransition: AnyTransition = .asymmetric(
        insertion: .offset(y: enterOffsetY)
            .combined(with: .scale(scale: enterScale))
            .combined(with: .opacity)
            .animation(presentAnimation),
        removal: .offset(y: exitOffsetY)
            .combined(with: .scale(scale: exitScale))
            .combined(with: .opacity)
            .animation(dismissAnimation)
    )
}

public struct ZenConfirmationDialogAction {
    public let title: LocalizedStringKey
    public let role: ButtonRole?
    public let action: () -> Void

    public init(_ title: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
}

public struct ZenConfirmationDialog<Content: View>: View {
    private let title: String
    private let message: String?
    @Binding private var isPresented: Bool
    private let actions: [ZenConfirmationDialogAction]
    private let content: () -> Content
    @Environment(\.zenOverlayPresenter) private var overlayPresenter
    @State private var dialogID = UUID()

    public init(
        title: String,
        message: String? = nil,
        isPresented: Binding<Bool>,
        actions: [ZenConfirmationDialogAction],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.message = message
        _isPresented = isPresented
        self.actions = actions
        self.content = content
    }

    public var body: some View {
        content()
            .task(id: isPresented) {
                syncPresentation(isPresented)
            }
            .onDisappear {
                overlayPresenter?.dismissConfirmationDialog(id: dialogID)
            }
    }

    private func syncPresentation(_ isPresented: Bool) {
        guard let overlayPresenter else {
            return
        }

        if isPresented {
            overlayPresenter.presentConfirmationDialog(
                id: dialogID,
                title: title,
                message: message,
                actions: wrappedActions
            )
        } else {
            overlayPresenter.dismissConfirmationDialog(id: dialogID)
        }
    }

    private var wrappedActions: [ZenConfirmationDialogAction] {
        actions.map { action in
            ZenConfirmationDialogAction(action.title, role: action.role) {
                isPresented = false
                action.action()
            }
        }
    }
}

private struct ZenConfirmationDialogPreview: View {
    @State private var isPresented: Bool

    init(isPresented: Bool = false) {
        _isPresented = State(initialValue: isPresented)
    }

    var body: some View {
        ZenOverlayRoot {
            ZStack {
                Color.zenBackground
                    .ignoresSafeArea()

                ZenConfirmationDialog(
                    title: "Discard draft?",
                    message: "Your unsaved changes will be lost.",
                    isPresented: $isPresented,
                    actions: [
                        ZenConfirmationDialogAction("Keep Editing", action: {}),
                        ZenConfirmationDialogAction("Discard", role: .destructive, action: {})
                    ]
                ) {
                    ZenButton("Open dialog") {
                        isPresented = true
                    }
                }
            }
        }
    }
}

#Preview {
    ZenConfirmationDialogPreview()
}

#Preview("Presented") {
    ZenConfirmationDialogPreview(isPresented: true)
}
