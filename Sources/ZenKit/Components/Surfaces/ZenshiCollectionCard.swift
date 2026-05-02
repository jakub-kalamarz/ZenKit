import SwiftUI

public struct ZenCollectionCard<Content: View>: View {
    private let title: String
    private let subtitle: String?
    private let badgeText: String?
    private let content: () -> Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        badgeText: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.badgeText = badgeText
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            HStack(alignment: .top, spacing: ZenSpacing.small) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.zenStat)
                        .foregroundStyle(Color.zenTextPrimary)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.zenGroup)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
                
                Spacer()
                
                if let badgeText {
                    ZenBadge(LocalizedStringKey(badgeText))
                }
            }
            
            content()
        }
    }
}

#Preview {
    ZenCollectionCard(title: "My Collection", subtitle: "5 items", badgeText: "New") {
        ForEach(0..<5) { index in
            Text("Item \(index + 1)")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.zenBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: ZenTheme.current.resolvedCornerRadius(for: 8))
                )
        }
    }
}
