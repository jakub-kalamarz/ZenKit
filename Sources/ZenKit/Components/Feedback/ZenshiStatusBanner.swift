import SwiftUI

public enum ZenBannerTone {
    case critical
    case warning
    case success
}

public struct ZenStatusBanner: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let tone: ZenBannerTone
    private let message: String

    public init(tone: ZenBannerTone = .critical, message: String) {
        self.tone = tone
        self.message = message
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(alignment: .center, spacing: ZenSpacing.small) {
            ZenIcon(systemName: iconSystemName, size: 15)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tintColor)
                .padding(.top, 1)

            Text(message)
                .font(.zenTextXS)
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

    private var iconSystemName: String {
        switch tone {
        case .critical:
            return "exclamationmark.triangle.fill"
        case .warning:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }

    private var tintColor: Color {
        switch tone {
        case .critical:
            return .zenCritical
        case .warning:
            return .zenWarning
        case .success:
            return .zenSuccess
        }
    }

    private var backgroundColor: Color {
        let colors = ZenTheme.current.resolvedColors

        switch tone {
        case .critical:
            return colors.criticalSubtle.color
        case .warning:
            return colors.warningSubtle.color
        case .success:
            return colors.successSubtle.color
        }
    }

    private var borderColor: Color {
        let colors = ZenTheme.current.resolvedColors

        switch tone {
        case .critical:
            return colors.criticalBorder.color
        case .warning:
            return colors.warningBorder.color
        case .success:
            return colors.successBorder.color
        }
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        ZenStatusBanner(message: "Invalid email or password.")
        ZenStatusBanner(tone: .warning, message: "Connection looks unstable.")
        ZenStatusBanner(tone: .success, message: "Google account linked.")
    }
    .padding()
}
