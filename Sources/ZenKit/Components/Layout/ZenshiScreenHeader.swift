import SwiftUI

public struct ZenScreenHeader: View {
    private let title: String
    private let subtitle: String?

    public init(
        title: String,
        subtitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.large) {
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                Text(title)
                    .font(.zenDisplayXL)
                    .tracking(-0.5)
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenIntro)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
    }
}
