import SwiftUI

public struct ZenPopover<Trigger: View, Content: View>: View {
    @State private var isPresented = false
    private let trigger: Trigger
    private let content: Content

    public init(
        @ViewBuilder trigger: () -> Trigger,
        @ViewBuilder content: () -> Content
    ) {
        self.trigger = trigger()
        self.content = content()
    }

    public var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            trigger
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented) {
            content
                .padding(ZenSpacing.medium)
                #if os(iOS)
                .presentationCompactAdaptation(.popover)
                #endif
        }
    }
}

#Preview("ZenPopover") {
    ZenPopover {
        Image(systemName: "info.circle")
            .foregroundStyle(Color.zenPrimary)
    } content: {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text("Popover Title")
                .font(.zenDisplayS)
                .foregroundStyle(Color.zenTextStrong)
            Text("This is some helpful information.")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        }
    }
    .padding()
}
