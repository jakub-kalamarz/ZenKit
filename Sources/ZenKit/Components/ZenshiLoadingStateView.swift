import SwiftUI

public struct ZenLoadingStateView: View {
    private let title: String
    private let message: String

    public init(title: String = "Preparing your session", message: String) {
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
