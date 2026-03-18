import SwiftUI

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

    @State private var measuredHeight: CGFloat = 320

    func body(content host: Content) -> some View {
        host.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            ZenAutoSizingSheetContent(
                measuredHeight: $measuredHeight,
                content: self.content
            )
        }
    }
}

private struct ZenAutoSizingSheetContent<SheetContent: View>: View {
    @Binding var measuredHeight: CGFloat

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
                guard abs(nextHeight - measuredHeight) > 0.5 else { return }

                withAnimation(.easeInOut(duration: 0.2)) {
                    measuredHeight = nextHeight
                }
            }
            .presentationDetents([.height(measuredHeight)])
    }
}

private struct ZenAutoSizingSheetHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
