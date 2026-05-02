import SwiftUI

public struct ZenLoading: View {
    private let title: String?
    private let message: String?

    public init(title: String? = nil, message: String? = nil) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: ZenSpacing.medium) {
            ZenSpinner(size: .large)

            if title != nil || message != nil {
                VStack(spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.zenStat)
                            .foregroundStyle(Color.zenTextPrimary)
                    }

                    if let message {
                        Text(message)
                            .font(.zenGroup)
                            .foregroundStyle(Color.zenTextMuted)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(ZenSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    ZenLoading(title: "Preparing your session", message: "Restoring your secure session.")
        .background(Color.zenBackground)
}
