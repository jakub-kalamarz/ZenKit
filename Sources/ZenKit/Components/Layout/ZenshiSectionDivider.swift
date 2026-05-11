import SwiftUI

public struct ZenSectionDivider: View {
    private let label: LocalizedStringKey

    public init(_ label: LocalizedStringKey) {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.zenBorder)
                .frame(height: 1)
            Text(label)
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
            Rectangle()
                .fill(Color.zenBorder)
                .frame(height: 1)
        }
    }
}

#Preview {
    ZenSectionDivider("Or continue with")
        .padding()
}
