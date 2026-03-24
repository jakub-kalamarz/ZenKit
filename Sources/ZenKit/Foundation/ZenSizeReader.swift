import SwiftUI

public extension View {
    /// Czyta rozmiar widoku i przekazuje go do domknięcia (closure).
    func zenReadSize(onChange: @escaping (CGSize) -> Void) -> some View {
        overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ZenSizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(ZenSizePreferenceKey.self) { size in
            if size != .zero {
                onChange(size)
            }
        }
    }
}

private struct ZenSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
