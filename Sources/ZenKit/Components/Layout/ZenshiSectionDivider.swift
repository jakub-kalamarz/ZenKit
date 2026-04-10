import SwiftUI

public struct ZenSectionDivider: View {
    private let label: String

    public init(_ label: String) {
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.zenBorder)
                .frame(height: 1)
            Text(label)
                .font(.zenTextXS)
                .foregroundStyle(Color.zenTextMuted)
                .fixedSize()
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
