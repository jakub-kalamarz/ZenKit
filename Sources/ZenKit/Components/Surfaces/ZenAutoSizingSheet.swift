import SwiftUI

public extension View {
    /// Prezentuje arkusz (sheet), który automatycznie dostosowuje swoją wysokość do zawartości.
    func zenAutoSizingSheet<Content: View>(
        isPresented: Binding<Bool>,
        backgroundColor: Color = Color.zenBackground,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(ZenAutoSizingSheetModifier(
            isPresented: isPresented,
            backgroundColor: backgroundColor,
            onDismiss: onDismiss,
            sheetContent: content
        ))
    }
}

private struct ZenAutoSizingSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let backgroundColor: Color
    let onDismiss: (() -> Void)?
    let sheetContent: () -> SheetContent

    @State private var detents: Set<PresentationDetent> = [.height(200)]
    @State private var selectedDetent: PresentationDetent = .height(200)
    @State private var lastHeight: CGFloat = 200
    @State private var isScrollable = false

    func body(content host: Content) -> some View {
        host.sheet(
            isPresented: $isPresented,
            onDismiss: {
                isScrollable = false
                detents = [.height(200)]
                selectedDetent = .height(200)
                lastHeight = 200
                onDismiss?()
            }
        ) {
            #if os(iOS)
            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()

                if isScrollable {
                    sheetContent()
                } else {
                    sheetContent()
                        .zenReadSize { size in
                            let screenHeight = UIScreen.main.bounds.height
                            let maxHeight = screenHeight * 0.92
                            if size.height > maxHeight {
                                isScrollable = true
                                updateDetents(newHeight: maxHeight)
                            } else {
                                updateDetents(newHeight: size.height)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .presentationDetents(detents, selection: $selectedDetent)
            .presentationDragIndicator(.visible)
            #else
            sheetContent()
                .background(backgroundColor)
            #endif
        }
    }

    private func updateDetents(newHeight: CGFloat) {
        guard newHeight > 10, abs(newHeight - lastHeight) > 1 else { return }

        let newDetent = PresentationDetent.height(newHeight)
        lastHeight = newHeight

        var newSet = detents
        newSet.insert(newDetent)
        detents = newSet

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
            selectedDetent = newDetent
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            detents = [newDetent]
        }
    }
}
