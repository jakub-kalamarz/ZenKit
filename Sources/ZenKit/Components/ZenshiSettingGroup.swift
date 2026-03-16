import SwiftUI

public struct ZenSettingGroup<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            content()
        }
    }
}

#Preview {
    ZenCard {
        ZenSettingGroup {
            ZenSettingRow(title: "Notifications", subtitle: "Manage alerts")
            ZenSettingRow(title: "Language") {
                Text("English")
            }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
