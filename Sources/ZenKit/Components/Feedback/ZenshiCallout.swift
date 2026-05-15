import SwiftUI

public enum ZenCalloutTone {
    case info
    case success
    case warning
    case critical
}

public struct ZenCallout: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let icon: String?
    private let message: LocalizedStringKey
    private let tone: ZenCalloutTone

    public init(icon: String? = nil, message: LocalizedStringKey, tone: ZenCalloutTone = .info) {
        self.icon = icon
        self.message = message
        self.tone = tone
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(alignment: .center, spacing: ZenSpacing.small) {
            if let icon {
                ZenIcon(systemName: icon, size: 14)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tintColor)
                    .padding(.top, 1)
            }

            Text(message)
                .font(.zenGroup)
                .foregroundStyle(tintColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var tintColor: Color {
        switch tone {
        case .info:     return .zenPrimary
        case .success:  return .zenSuccess
        case .warning:  return .zenWarning
        case .critical: return .zenCritical
        }
    }

    private var backgroundColor: Color {
        let colors = ZenTheme.current.resolvedColors
        switch tone {
        case .info:     return colors.primarySubtle.color
        case .success:  return colors.successSubtle.color
        case .warning:  return colors.warningSubtle.color
        case .critical: return colors.criticalSubtle.color
        }
    }

    private var borderColor: Color {
        let colors = ZenTheme.current.resolvedColors
        switch tone {
        case .info:     return Color.zenPrimary.opacity(0.2)
        case .success:  return colors.successBorder.color
        case .warning:  return colors.warningBorder.color
        case .critical: return colors.criticalBorder.color
        }
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenCallout(icon: "person.2", message: "Members can edit plans and check off items. Only admins can remove people.")
        ZenCallout(message: "Your household has been created.")
        ZenCallout(icon: "checkmark.circle", message: "All changes saved.", tone: .success)
        ZenCallout(icon: "exclamationmark.triangle", message: "You're approaching your weekly limit.", tone: .warning)
        ZenCallout(icon: "xmark.octagon", message: "This action cannot be undone.", tone: .critical)
    }
    .padding()
    .background(Color.zenBackground)
}
