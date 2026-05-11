import SwiftUI

private struct ZenSheetSizingCallbackKey: EnvironmentKey {
    static let defaultValue: ((CGSize) -> Void)? = nil
}

extension EnvironmentValues {
    var zenSheetSizingCallback: ((CGSize) -> Void)? {
        get { self[ZenSheetSizingCallbackKey.self] }
        set { self[ZenSheetSizingCallbackKey.self] = newValue }
    }
}

extension View {
    /// Reports the content size to the enclosing `zenAutoSizingSheet`.
    /// Apply this to the scroll content inside a sheet to enable proper auto-sizing.
    public func zenSheetContentSize() -> some View {
        modifier(ZenSheetContentSizeModifier())
    }
}

private struct ZenSheetContentSizeModifier: ViewModifier {
    @Environment(\.zenSheetSizingCallback) private var sizingCallback

    func body(content: Content) -> some View {
        content.zenReadSize { size in
            sizingCallback?(size)
        }
    }
}

extension View {
    /// Prezentuje arkusz (sheet), który automatycznie dostosowuje swoją wysokość do zawartości.
    public func zenAutoSizingSheet<Content: View>(
        isPresented: Binding<Bool>,
        backgroundColor: Color = Color.zenBackground,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            ZenAutoSizingSheetModifier(
                isPresented: isPresented,
                backgroundColor: backgroundColor,
                onDismiss: onDismiss,
                sheetContent: content
            ))
    }
}

private struct ZenAutoSizingSheetModifier<SheetContent: View>: ViewModifier {
    private static var initialHeight: CGFloat { 200 }
    private static var minimumHeight: CGFloat { 44 }
    private static var heightChangeThreshold: CGFloat { 8 }
    private static var detentPruneDelay: Duration { .milliseconds(450) }

    @Binding var isPresented: Bool
    let backgroundColor: Color
    let onDismiss: (() -> Void)?
    let sheetContent: () -> SheetContent

    @State private var detents: Set<PresentationDetent> = [.height(Self.initialHeight)]
    @State private var selectedDetent: PresentationDetent = .height(Self.initialHeight)
    @State private var lastHeight: CGFloat = Self.initialHeight
    @State private var pendingHeight: CGFloat?
    @State private var isScrollable = false
    @State private var updateTask: Task<Void, Never>?
    @State private var pruneTask: Task<Void, Never>?
    @State private var hasInnerSizing = false

    func body(content host: Content) -> some View {
        host.sheet(
            isPresented: $isPresented,
            onDismiss: {
                resetSizingState()
                onDismiss?()
            }
        ) {
            #if os(iOS)
                sheetBody
                    .environment(\.zenSheetSizingCallback) { size in
                        hasInnerSizing = true
                        scheduleDetentUpdate(for: size)
                    }
                    .zenReadSize { size in
                        guard !hasInnerSizing else { return }
                        scheduleDetentUpdate(for: size)
                    }
                    .presentationDetents(detents, selection: $selectedDetent)
                    .presentationBackground(backgroundColor)
            #else
                sheetContent()
                    .background(backgroundColor)
            #endif
        }
    }

    #if os(iOS)
    private var sheetBody: some View {
        sheetContent()
            .frame(maxHeight: isScrollable ? maxSheetHeight : nil, alignment: .top)
            .background(backgroundColor.ignoresSafeArea())
            .frame(maxWidth: .infinity, alignment: .top)
    }

    private var maxSheetHeight: CGFloat {
        UIScreen.main.bounds.height * 0.92
    }

    private func scheduleDetentUpdate(for size: CGSize) {
        guard size.height > Self.minimumHeight else { return }

        let cappedHeight = min(size.height, maxSheetHeight)
        let shouldScroll = size.height > maxSheetHeight
        guard abs(cappedHeight - lastHeight) >= Self.heightChangeThreshold || shouldScroll != isScrollable else {
            return
        }

        pendingHeight = cappedHeight
        updateTask?.cancel()
        updateTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled, let pendingHeight else { return }
            updateDetents(newHeight: pendingHeight, isScrollable: shouldScroll)
            self.pendingHeight = nil
        }
    }

    private func updateDetents(newHeight: CGFloat, isScrollable: Bool) {
        guard newHeight > Self.minimumHeight else { return }
        guard abs(newHeight - lastHeight) >= Self.heightChangeThreshold || isScrollable != self.isScrollable else {
            return
        }

        let newDetent = PresentationDetent.height(newHeight)
        lastHeight = newHeight
        self.isScrollable = isScrollable

        var newSet = detents
        newSet.insert(newDetent)
        detents = newSet

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
            selectedDetent = newDetent
        }

        pruneTask?.cancel()
        pruneTask = Task { @MainActor in
            try? await Task.sleep(for: Self.detentPruneDelay)
            guard !Task.isCancelled, selectedDetent == newDetent else { return }
            detents = [newDetent]
        }
    }

    private func resetSizingState() {
        updateTask?.cancel()
        pruneTask?.cancel()
        updateTask = nil
        pruneTask = nil
        pendingHeight = nil
        isScrollable = false
        hasInnerSizing = false
        detents = [.height(Self.initialHeight)]
        selectedDetent = .height(Self.initialHeight)
        lastHeight = Self.initialHeight
    }
    #else
    private func resetSizingState() {}
    #endif
}
