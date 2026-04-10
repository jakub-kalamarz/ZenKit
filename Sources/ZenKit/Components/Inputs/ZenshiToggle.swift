import SwiftUI

public struct ZenToggle: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    @Binding private var isOn: Bool

    public init(_ title: String, isOn: Binding<Bool>, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        _isOn = isOn
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zenTextSM.weight(.medium))
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenTextXS)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
        .tint(Color.zenPrimary)
        .padding(.vertical, 12)
        .padding(.horizontal, ZenSpacing.medium)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct ZenTogglePreview: View {
    @State private var notificationsEnabled = true
    @State private var marketingEnabled = false

    var body: some View {
        VStack(spacing: ZenSpacing.small) {
            ZenToggle(
                "Push notifications",
                isOn: $notificationsEnabled,
                subtitle: "Alerts for mentions and approvals"
            )

            ZenToggle(
                "Marketing emails",
                isOn: $marketingEnabled,
                subtitle: "Product updates and release notes"
            )
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenTogglePreview()
}
