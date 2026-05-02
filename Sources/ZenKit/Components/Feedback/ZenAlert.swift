import SwiftUI

public struct ZenAlertAction {
    public let label: String
    public let handler: () -> Void

    public init(_ label: String, handler: @escaping () -> Void) {
        self.label = label
        self.handler = handler
    }
}

public struct ZenAlert: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let tone: ZenBannerTone
    private let title: String?
    private let message: String
    private let action: ZenAlertAction?
    private let onDismiss: (() -> Void)?

    public init(
        tone: ZenBannerTone = .critical,
        title: String? = nil,
        message: String,
        action: ZenAlertAction? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(alignment: .top, spacing: ZenSpacing.small) {
            ZenIcon(systemName: iconSystemName, size: 15)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tintColor)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(tintColor)
                }

                Text(message)
                    .font(.zenGroup)
                    .foregroundStyle(tintColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let action {
                    Button(action.label, action: action.handler)
                        .font(.zen(.group, weight: .semibold))
                        .foregroundStyle(tintColor)
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                }
            }

            if let onDismiss {
                Spacer(minLength: ZenSpacing.small)

                Button {
                    onDismiss()
                } label: {
                    ZenIcon(systemName: "xmark", size: 11)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(tintColor.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
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

    private var iconSystemName: String {
        switch tone {
        case .critical: return "exclamationmark.triangle.fill"
        case .warning: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        }
    }

    private var tintColor: Color {
        switch tone {
        case .critical: return .zenCritical
        case .warning: return .zenWarning
        case .success: return .zenSuccess
        }
    }

    private var backgroundColor: Color {
        let colors = ZenTheme.current.resolvedColors
        switch tone {
        case .critical: return colors.criticalSubtle.color
        case .warning: return colors.warningSubtle.color
        case .success: return colors.successSubtle.color
        }
    }

    private var borderColor: Color {
        let colors = ZenTheme.current.resolvedColors
        switch tone {
        case .critical: return colors.criticalBorder.color
        case .warning: return colors.warningBorder.color
        case .success: return colors.successBorder.color
        }
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenAlert(
            tone: .critical,
            title: "Payment failed",
            message: "Your card was declined. Please update your billing details.",
            action: ZenAlertAction("Update billing") {},
            onDismiss: {}
        )
        ZenAlert(
            tone: .warning,
            title: "Storage almost full",
            message: "You have used 90% of your storage quota.",
            action: ZenAlertAction("Upgrade plan") {}
        )
        ZenAlert(
            tone: .success,
            message: "Your changes have been saved successfully."
        )
    }
    .padding()
    .background(Color.zenBackground)
}
