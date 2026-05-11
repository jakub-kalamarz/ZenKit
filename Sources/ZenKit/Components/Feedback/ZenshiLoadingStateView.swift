import SwiftUI

public struct ZenLoadingStateView: View {
    private let title: LocalizedStringKey
    private let message: LocalizedStringKey

    public init(title: LocalizedStringKey = "Preparing your session", message: LocalizedStringKey) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        ZenLoading(title: title, message: message)
    }
}

#Preview {
    ZenLoadingStateView(message: "Restoring your secure session.")
        .background(Color.zenBackground)
}
