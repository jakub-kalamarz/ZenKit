import SwiftUI

public extension View {
    /// Czyta rozmiar widoku i przekazuje go do domknięcia (closure).
    func zenReadSize(onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(ZenSizeReader(onChange: onChange))
    }
}

private struct ZenSizeReader: ViewModifier {
    let onChange: (CGSize) -> Void

    @State private var lastSize: CGSize = .zero

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
                    .task(id: proxy.size) {
                        report(proxy.size)
                    }
            }
        }
    }

    private func report(_ size: CGSize) {
        guard size != .zero, size != lastSize else { return }

        lastSize = size
        onChange(size)
    }
}
