import SwiftUI

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
}

public struct ZenBadge: View {
    private let title: LocalizedStringKey
    private let tone: ZenSemanticTone
    private let isSelected: Bool
    private let iconSource: ZenIconSource?
    private let tint: Color?
    private let action: (() -> Void)?
    private let onRemove: (() -> Void)?
    
    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil
    ) {
        self.title = title
        self.tone = tone
        self.isSelected = false
        self.iconSource = iconSource
        self.tint = tint
        self.action = nil
        self.onRemove = nil
    }
    
    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        isSelected: Bool = false,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.tone = tone
        self.isSelected = isSelected
        self.iconSource = iconSource
        self.tint = tint
        self.action = action
        self.onRemove = nil
    }
    
    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil,
        onRemove: @escaping () -> Void
    ) {
        self.title = title
        self.tone = tone
        self.isSelected = false
        self.iconSource = iconSource
        self.tint = tint
        self.action = nil
        self.onRemove = onRemove
    }
    
    public init(
        _ title: LocalizedStringKey,
        tone: ZenSemanticTone = .neutral,
        isSelected: Bool = false,
        iconSource: ZenIconSource? = nil,
        tint: Color? = nil,
        action: @escaping () -> Void,
        onRemove: @escaping () -> Void
    ) {
        self.title = title
        self.tone = tone
        self.isSelected = isSelected
        self.iconSource = iconSource
        self.tint = tint
        self.action = action
        self.onRemove = onRemove
    }
    
    public var body: some View {
        let shape = RoundedRectangle(
            cornerRadius: ZenBadgeStyleMetrics.cornerRadius,
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
                            height: ZenBadgeStyleMetrics.height
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
            shape.strokeBorder(borderColor, lineWidth: 1)
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
        HStack(spacing: ZenBadgeStyleMetrics.labelSpacing) {
            if isSelected {
                ZenIcon(source: .system("checkmark"), size: ZenBadgeStyleMetrics.iconSize)
                    .font(.system(size: ZenBadgeStyleMetrics.iconSize, weight: .bold))
            } else if let iconSource {
                ZenIcon(source: iconSource, size: ZenBadgeStyleMetrics.iconSize)
                    .font(.system(size: ZenBadgeStyleMetrics.iconSize, weight: .bold))
            }
            
            Text(title)
                .lineLimit(1)
        }
        .font(.zenCaption.weight(.semibold))
        .foregroundStyle(foregroundColor)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.leading, ZenBadgeStyleMetrics.horizontalPadding)
        .padding(.trailing, onRemove == nil ? ZenBadgeStyleMetrics.horizontalPadding : 8)
        .padding(.vertical, ZenBadgeStyleMetrics.verticalPadding)
        .frame(minHeight: ZenBadgeStyleMetrics.height)
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
    }
    .padding()
    .background(Color.zenBackground)
}
