import SwiftUI

public struct ZenCardSection<Content: View>: View {
    private let title: Text
    private let content: Content

    public init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.title = Text(title)
        self.content = content()
    }

    public init(_ title: Text, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            title
                .font(.zen(.group, weight: .bold))
                .foregroundStyle(Color.zenTextMuted)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.leading, 4)
            content
        }
    }
}

#Preview {
    ZenCardSection("Up next") {
        ZenCard {
            Text("Content goes here")
                .padding()
        }
    }
    .padding()
    .background(Color.zenBackground)
}
