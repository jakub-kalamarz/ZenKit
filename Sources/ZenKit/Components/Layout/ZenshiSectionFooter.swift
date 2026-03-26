import SwiftUI

public struct ZenSectionFooter<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .font(.zenCaption)
            .foregroundStyle(Color.zenTextMuted)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ZenSpacing.small)
            .padding(.bottom, ZenSpacing.small)
    }
}

#Preview {
    ZenSection {
        Text("Row")
    } footer: {
        ZenSectionFooter {
            Text("Admins can update access.")
        }
    }
    .padding()
    .background(Color.zenBackground)
}
