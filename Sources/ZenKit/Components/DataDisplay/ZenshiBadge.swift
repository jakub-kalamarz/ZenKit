import SwiftUI

public enum ZenBadgeSize: Sendable {
    case `default`
    case small
}

public enum ZenBadgeVariant: Sendable {
    case outlined
    case filled
}

enum ZenBadgeStyleMetrics {
    static let height: CGFloat = 28
    static let cornerRadius: CGFloat = 8
    static let horizontalPadding: CGFloat = 10
    static let verticalPadding: CGFloat = 6
    static let labelSpacing: CGFloat = 4
    static let removeButtonWidth: CGFloat = 24
    static let removeDividerVerticalInset: CGFloat = 5
    static let iconSize: CGFloat = 10
    static let removeIconSize: CGFloat = 10

    static let smallHeight: CGFloat = 20
    static let smallCornerRadius: CGFloat = 6
    static let smallHorizontalPadding: CGFloat = 6
    static let smallVerticalPadding: CGFloat = 2
    static let smallIconSize: CGFloat = 8

    static let filledHorizontalPadding: CGFloat = 9
    static let filledVerticalPadding: CGFloat = 4
}

public struct ZenBadge: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: LocalizedStringKey
    private let tone: ZenSemanticTone
    private let size: ZenBadgeSize
    private let variant: ZenBadgeVariant
    private let isSelected: Bool
    private let iconSource: ZenIconSource?
    private let tint: Color?
    private let action: (() -> Void)?
    private let onRemove: (() -> Void)?

    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        size: ZenBadgeSize = .default,
        variant: ZenBadgeVariant = .outlined,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil
    ) {
        self.title = title
        self.tone = tone
        self.size = size
        self.variant = variant
        self.isSelected = false
        self.iconSource = iconSource
        self.tint = tint
        self.action = nil
        self.onRemove = nil
    }

    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        size: ZenBadgeSize = .default,
        variant: ZenBadgeVariant = .outlined,
        isSelected: Bool = false,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.tone = tone
        self.size = size
        self.variant = variant
        self.isSelected = isSelected
        self.iconSource = iconSource
        self.tint = tint
        self.action = action
        self.onRemove = nil
    }

    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        size: ZenBadgeSize = .default,
        variant: ZenBadgeVariant = .outlined,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil,
        onRemove: @escaping () -> Void
    ) {
        self.title = title
        self.tone = tone
        self.size = size
        self.variant = variant
        self.isSelected = false
        self.iconSource = iconSource
        self.tint = tint
        self.action = nil
        self.onRemove = onRemove
    }

    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        size: ZenBadgeSize = .default,
        variant: ZenBadgeVariant = .outlined,
        isSelected: Bool = false,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil,
        action: @escaping () -> Void,
        onRemove: @escaping () -> Void
    ) {
        self.title = title
        self.tone = tone
        self.size = size
        self.variant = variant
        self.isSelected = isSelected
        self.iconSource = iconSource
        self.tint = tint
        self.action = action
        self.onRemove = onRemove
    }
    
    private var resolvedCornerRadius: CGFloat {
        switch variant {
        case .filled:
            return ZenTheme.current.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        case .outlined:
            return size == .small ? ZenBadgeStyleMetrics.smallCornerRadius : ZenBadgeStyleMetrics.cornerRadius
        }
    }

    public var body: some View {
        let shape = RoundedRectangle(
            cornerRadius: resolvedCornerRadius,
            style: .continuous
        )

        HStack(spacing: 0) {
            mainContent

            if let onRemove {
                removeDivider

                Button(action: onRemove) {
                    ZenIcon(source: .system("xmark"), size: ZenBadgeStyleMetrics.removeIconSize)
                        .font(.system(size: ZenBadgeStyleMetrics.removeIconSize, weight: .bold))
                        .frame(
                            width: ZenBadgeStyleMetrics.removeButtonWidth,
                            height: size == .small ? ZenBadgeStyleMetrics.smallHeight : ZenBadgeStyleMetrics.height
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(foregroundColor)
                .accessibilityLabel("Remove badge")
            }
        }
        .background(backgroundColor)
        .overlay(
            shape.strokeBorder(variant == .filled ? .clear : borderColor, lineWidth: 1)
        )
        .clipShape(shape)
        .contentShape(shape)
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .zenPrimaryForeground
        }
        
        if let tint {
            return tint
        }
        
        switch tone {
        case .neutral:
            return .zenTextPrimary
        case .success:
            return .zenSuccess
        case .warning:
            return .zenWarning
        case .critical:
            return .zenCritical
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .zenPrimary
        }
        
        if let tint {
            return tint.opacity(0.12)
        }
        
        let colors = ZenTheme.current.resolvedColors
        
        switch tone {
        case .neutral:
            return .zenSurfaceMuted
        case .success:
            return colors.successSubtle.color
        case .warning:
            return colors.warningSubtle.color
        case .critical:
            return colors.criticalSubtle.color
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .zenPrimary
        }
        
        if let tint {
            return tint.opacity(0.24)
        }
        
        let colors = ZenTheme.current.resolvedColors
        
        switch tone {
        case .neutral:
            return .zenBorder
        case .success:
            return colors.successBorder.color
        case .warning:
            return colors.warningBorder.color
        case .critical:
            return colors.criticalBorder.color
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if let action {
            Button(action: action) {
                badgeLabel
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        } else {
            badgeLabel
        }
    }
    
    private var badgeLabel: some View {
        let isFilled = variant == .filled
        let isSmall = size == .small
        let iconSz = isSmall ? ZenBadgeStyleMetrics.smallIconSize : ZenBadgeStyleMetrics.iconSize
        let hPad = isFilled ? ZenBadgeStyleMetrics.filledHorizontalPadding : (isSmall ? ZenBadgeStyleMetrics.smallHorizontalPadding : ZenBadgeStyleMetrics.horizontalPadding)
        let vPad = isFilled ? ZenBadgeStyleMetrics.filledVerticalPadding : (isSmall ? ZenBadgeStyleMetrics.smallVerticalPadding : ZenBadgeStyleMetrics.verticalPadding)
        let minH = isSmall ? ZenBadgeStyleMetrics.smallHeight : ZenBadgeStyleMetrics.height
        let font: Font = isFilled ? .zen(.body2, weight: .semibold) : (isSmall ? .caption2.weight(.medium) : .zen(.group, weight: .semibold))

        return HStack(spacing: ZenBadgeStyleMetrics.labelSpacing) {
            if isSelected {
                ZenIcon(source: .system("checkmark"), size: iconSz)
                    .font(.system(size: iconSz, weight: .bold))
            } else if let iconSource {
                ZenIcon(source: iconSource, size: iconSz)
                    .font(.system(size: iconSz, weight: .bold))
            }

            Text(title)
                .lineLimit(1)
        }
        .font(font)
        .foregroundStyle(foregroundColor)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.leading, hPad)
        .padding(.trailing, onRemove == nil ? hPad : 8)
        .padding(.vertical, vPad)
        .frame(minHeight: isFilled ? 0 : minH)
    }
    
    private var removeDivider: some View {
        Rectangle()
            .fill(foregroundColor.opacity(isSelected ? 0.2 : 0.14))
            .frame(width: 1)
            .padding(.vertical, ZenBadgeStyleMetrics.removeDividerVerticalInset)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: ZenSpacing.small) {
        HStack(spacing: ZenSpacing.small) {
            ZenBadge("Draft")
            ZenBadge("Synced", tone: .success)
            ZenBadge("Review", tone: .warning)
            ZenBadge("Failed", tone: .critical)
        }
        
        HStack(spacing: ZenSpacing.small) {
            ZenBadge("Selected", isSelected: true) {}
            ZenBadge("Swift", onRemove: {})
            ZenBadge("Design", tone: .warning, isSelected: true, action: {}, onRemove: {})
        }

        HStack(spacing: ZenSpacing.small) {
            ZenBadge("2 kg", variant: .filled)
            ZenBadge("1.5 l", variant: .filled)
            ZenBadge("1 bunch", tone: .neutral, variant: .filled)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
