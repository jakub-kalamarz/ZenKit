import SwiftUI

public struct ZenCardHeader: View {
    private let title: String
    private let subtitle: String?
    private let leadingIconSystemName: String?
    private let iconTint: Color

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIconSystemName: String? = nil,
        iconTint: Color = .zenTextMuted
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIconSystemName = leadingIconSystemName
        self.iconTint = iconTint
    }

    public var body: some View {
        HStack(alignment: .top, spacing: ZenSpacing.small) {
            if let leadingIconSystemName {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconTint.opacity(0.14))
                        .frame(width: 36, height: 36)

                    ZenIcon(systemName: leadingIconSystemName, size: 16)
                        .foregroundStyle(iconTint)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zenTitle)
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenCaption)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
    }
}

#Preview {
    ZenCard {
        ZenCardHeader(
            title: "Notifications",
            subtitle: "Manage delivery settings",
            leadingIconSystemName: "bell.badge.fill",
            iconTint: .zenPrimary
        )
    }
    .padding()
    .background(Color.zenBackground)
}
