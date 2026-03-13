import SwiftUI

public struct ZenInfoCard: View {
    private let title: String
    private let value: String
    private let monospaced: Bool

    public init(title: String, value: String, monospaced: Bool = false) {
        self.title = title
        self.value = value
        self.monospaced = monospaced
    }

    public var body: some View {
        let theme = ZenTheme.current

        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            Text(title)
                .font(.zenCaption)
                .foregroundStyle(Color.zenTextMuted)

            Text(value)
                .font(monospaced ? .zenMono : .zenBody)
                .foregroundStyle(Color.zenTextPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.zenSurfaceMuted)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small))
                        .strokeBorder(Color.zenBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: theme.resolvedCornerRadius(for: ZenRadius.small)))
        }
    }
}

#Preview {
    ZenInfoCard(title: "Session token", value: "token-id-1234567890", monospaced: true)
        .padding()
}
