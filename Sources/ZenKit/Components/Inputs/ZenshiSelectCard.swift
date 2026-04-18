import SwiftUI

public enum ZenSelectCardVariant: Sendable {
    case card
    case inline
}

enum ZenSelectCardMetrics {
    static let contentSpacing: CGFloat = ZenSpacing.small
    static let verticalSpacing: CGFloat = 4
    static let verticalPadding: CGFloat = ZenSpacing.small
    static let compactVerticalPadding: CGFloat = 13
    static let inlineVerticalPadding: CGFloat = 12
    static let horizontalPadding: CGFloat = ZenSpacing.small
    static let indicatorSize: CGFloat = 16
    static let indicatorInnerSize: CGFloat = 10
    static let indicatorTopInset: CGFloat = ZenSpacing.small
    static let indicatorTrailingInset: CGFloat = ZenSpacing.small
    static let indicatorReservedWidth: CGFloat = ZenSpacing.medium + indicatorSize
}

public struct ZenSelectCard: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    private let subtitle: String?
    private let leadingIconSource: ZenIconSource?
    private let iconColor: Color?
    private let iconSize: CGFloat
    private let variant: ZenSelectCardVariant
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIconSource: ZenIconSource? = nil,
        iconColor: Color? = nil,
        iconSize: CGFloat = 40,
        variant: ZenSelectCardVariant = .card,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIconSource = leadingIconSource
        self.iconColor = iconColor
        self.iconSize = iconSize
        self.variant = variant
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: cornerRole, parentRadius: parentCornerRadius)
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Button(action: action) {
            content
                .opacity(isEnabled ? 1 : 0.55)
                .padding(.horizontal, ZenSelectCardMetrics.horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor)
                .overlay(
                    shape.strokeBorder(borderColor, lineWidth: 1)
                )
                .overlay(alignment: .topTrailing) {
                    if showsSelectionIndicator {
                        ZenSelectCardIndicator(isSelected: isSelected)
                            .padding(.top, ZenSelectCardMetrics.indicatorTopInset)
                            .padding(.trailing, ZenSelectCardMetrics.indicatorTrailingInset)
                    }
                }
                .clipShape(shape)
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    @ViewBuilder
    private var content: some View {
        switch variant {
        case .card:
            VStack(alignment: .leading, spacing: ZenSelectCardMetrics.contentSpacing) {
                if let leadingIconSource {
                    HStack(spacing: 0) {
                        leadingIcon(for: leadingIconSource)
                        Spacer(minLength: 0)
                    }
                }

                VStack(alignment: .leading, spacing: ZenSelectCardMetrics.verticalSpacing) {
                    titleView

                    if let subtitle {
                        subtitleView(subtitle)
                    }
                }
            }
            .padding(.trailing, ZenSelectCardMetrics.indicatorReservedWidth)
        case .inline:
            HStack(spacing: ZenSelectCardMetrics.contentSpacing) {
                if let leadingIconSource {
                    leadingIcon(for: leadingIconSource)
                }

                VStack(alignment: .leading, spacing: ZenSelectCardMetrics.verticalSpacing) {
                    titleView

                    if let subtitle {
                        subtitleView(subtitle)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }

    internal var resolvedLeadingIconSource: ZenIconSource? {
        leadingIconSource
    }

    internal var usesCompactLayout: Bool {
        subtitle == nil
    }

    internal var appliesSelectedAccessibilityTrait: Bool {
        isSelected
    }

    internal var hidesSelectionIndicator: Bool {
        !showsSelectionIndicator
    }

    private var backgroundColor: Color {
        switch variant {
        case .card:
            isSelected ? Color.zenSurfaceMuted : Color.zenSurface
        case .inline:
            Color.zenSurface
        }
    }

    private var borderColor: Color {
        switch variant {
        case .card:
            isSelected ? Color.zenTextPrimary.opacity(0.22) : Color.zenBorder
        case .inline:
            Color.zenBorder
        }
    }

    private var verticalPadding: CGFloat {
        switch variant {
        case .card:
            usesCompactLayout ? ZenSelectCardMetrics.compactVerticalPadding : ZenSelectCardMetrics.verticalPadding
        case .inline:
            ZenSelectCardMetrics.inlineVerticalPadding
        }
    }

    private var cornerRole: ZenCornerRole {
        switch variant {
        case .card:
            .nestedContainer
        case .inline:
            .nestedControl
        }
    }

    private var showsSelectionIndicator: Bool {
        variant == .card
    }

    private var titleView: some View {
        Text(title)
            .font(.zenTextSM.weight(.semibold))
            .foregroundStyle(Color.zenTextPrimary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subtitleView(_ subtitle: String) -> some View {
        Text(subtitle)
            .font(.zenTextXS)
            .foregroundStyle(Color.zenTextMuted)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func leadingIcon(for source: ZenIconSource) -> some View {
        if let iconColor {
            ZenIconBadge(source: source, color: iconColor, size: iconSize)
        } else if case .asset = source, variant == .card {
            ZenIcon(source: source, size: iconSize)
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: ZenNavigationRow.leadingIconBadgeCornerRadius, style: .continuous)
                    .fill(Color.zenSurfaceMuted)
                    .frame(width: iconSize, height: iconSize)

                ZenIcon(source: source, size: iconSize * 0.5)
                    .font(.system(size: iconSize * 0.5, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
    }
}

private struct ZenSelectCardIndicator: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(borderColor, lineWidth: isSelected ? 1.5 : 1)
                .background(Circle().fill(backgroundColor))
                .frame(width: ZenSelectCardMetrics.indicatorSize, height: ZenSelectCardMetrics.indicatorSize)

            if isSelected {
                Circle()
                    .fill(Color.zenTextPrimary)
                    .frame(
                        width: ZenSelectCardMetrics.indicatorInnerSize,
                        height: ZenSelectCardMetrics.indicatorInnerSize
                    )
            }
        }
        .accessibilityHidden(true)
    }

    private var borderColor: Color {
        isSelected ? Color.zenTextPrimary : Color.zenTextMuted.opacity(0.22)
    }

    private var backgroundColor: Color {
        .clear
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var selectedPlan = "Pro"
        @State private var selectedMethod = "Visa"

        var body: some View {
            VStack(spacing: ZenSpacing.medium) {
                ZenSelectCard(
                    title: "Plus",
                    subtitle: "For individuals and small teams.",
                    isSelected: selectedPlan == "Plus"
                ) {
                    selectedPlan = "Plus"
                }

                ZenSelectCard(
                    title: "Pro",
                    subtitle: "For growing businesses.",
                    isSelected: selectedPlan == "Pro"
                ) {
                    selectedPlan = "Pro"
                }

                ZenSelectCard(
                    title: "Visa ending in 4242",
                    subtitle: "Expires 12/26",
                    leadingIconSource: .asset("CreditCard"),
                    iconColor: .blue,
                    isSelected: selectedMethod == "Visa"
                ) {
                    selectedMethod = "Visa"
                }

                ZenSelectCard(
                    title: "Add new payment method",
                    leadingIconSource: .asset("Plus"),
                    variant: .inline,
                    isSelected: false
                ) {}
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return PreviewContainer()
}
