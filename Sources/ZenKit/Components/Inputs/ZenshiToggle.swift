import SwiftUI

public struct ZenToggle: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Environment(\.zenHapticsOverride) private var hapticsOverride

    private let title: LocalizedStringKey
    private let subtitle: LocalizedStringKey?
    @Binding private var isOn: Bool

    public init(_ title: LocalizedStringKey, isOn: Binding<Bool>, subtitle: LocalizedStringKey? = nil) {
        self.title = title
        self.subtitle = subtitle
        _isOn = isOn
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        Toggle(isOn: hapticBinding) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.zen(.body2, weight: .medium))
                    .foregroundStyle(Color.zenTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.zenGroup)
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

    private var hapticBinding: Binding<Bool> {
        Binding(
            get: { isOn },
            set: { newValue in
                guard isOn != newValue else { return }

                ZenHapticEngine.perform(.toggleChange, haptics: hapticsOverride)
                isOn = newValue
            }
        )
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
