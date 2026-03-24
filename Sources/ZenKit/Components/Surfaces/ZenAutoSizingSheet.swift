import SwiftUI

private let zenAutoSizingSheetDefaultHeight: CGFloat = 320

public extension View {
    func zenAutoSizingSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(
            ZenAutoSizingSheetModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}

private struct ZenAutoSizingSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool

    let onDismiss: (() -> Void)?
    let content: () -> SheetContent

    @State private var presentationDetents: Set<PresentationDetent> = [.height(zenAutoSizingSheetDefaultHeight)]
    @State private var selectedPresentationDetent: PresentationDetent = .height(zenAutoSizingSheetDefaultHeight)
    @State private var detentCleanupToken = 0

    func body(content host: Content) -> some View {
        host.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            ZenAutoSizingSheetContent(
                presentationDetents: $presentationDetents,
                selectedPresentationDetent: $selectedPresentationDetent,
                detentCleanupToken: $detentCleanupToken,
                content: self.content
            )
        }
    }
}

private struct ZenAutoSizingSheetContent<SheetContent: View>: View {
    @Binding var presentationDetents: Set<PresentationDetent>
    @Binding var selectedPresentationDetent: PresentationDetent
    @Binding var detentCleanupToken: Int

    let content: () -> SheetContent

    var body: some View {
        content()
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ZenAutoSizingSheetHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                }
            )
            .onPreferenceChange(ZenAutoSizingSheetHeightPreferenceKey.self) { height in
                let nextHeight = max(height, 1)
                let nextDetent = PresentationDetent.height(nextHeight)
                guard nextDetent != selectedPresentationDetent else { return }

                presentationDetents.insert(nextDetent)

                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedPresentationDetent = nextDetent
                }

                detentCleanupToken += 1
                let cleanupToken = detentCleanupToken

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard cleanupToken == detentCleanupToken else { return }
                    presentationDetents = [selectedPresentationDetent]
                }
            }
            .presentationDetents(presentationDetents, selection: $selectedPresentationDetent)
    }
}

private struct ZenAutoSizingSheetHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
