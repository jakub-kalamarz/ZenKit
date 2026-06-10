import SwiftUI

public struct ZenTooltip<Trigger: View>: View {
    private let text: String
    private let trigger: Trigger
    @State private var isShowing = false

    public init(
        _ text: String,
        @ViewBuilder trigger: () -> Trigger
    ) {
        self.text = text
        self.trigger = trigger()
    }

    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        trigger
            #if os(macOS)
            .help(text)
            #else
            .onLongPressGesture(minimumDuration: 0.5) {
                isShowing = true
            }
            .popover(isPresented: $isShowing) {
                Text(text)
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextPrimary)
                    .padding(.horizontal, ZenSpacing.small)
                    .padding(.vertical, ZenSpacing.xSmall)
                    .presentationCompactAdaptation(.popover)
            }
            #endif
    }
}

#Preview("ZenTooltip") {
    ZenTooltip("This is a helpful tooltip") {
        Image(systemName: "questionmark.circle")
            .foregroundStyle(Color.zenTextMuted)
    }
    .padding()
}
