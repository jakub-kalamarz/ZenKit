import SwiftUI

public struct ZenIconBadge: View {
    private let source: ZenIconSource
    private let color: Color
    private let size: CGFloat

    public static let defaultSize: CGFloat = 28

    public init(source: ZenIconSource, color: Color, size: CGFloat = defaultSize) {
        self.source = source
        self.color = color
        self.size = size
    }

    public init(systemName: String, color: Color, size: CGFloat = defaultSize) {
        self.init(source: .system(systemName), color: color, size: size)
    }

    public init(assetName: String, color: Color, size: CGFloat = defaultSize) {
        self.init(source: .asset(assetName), color: color, size: size)
    }

    public var body: some View {
        let cornerRadius = ZenTheme.current.resolvedCornerRadius(for: ZenRadius.small)
        let style = ZenTheme.current.iconStyle

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background(for: style))
                .frame(width: size, height: size)

            ZenIcon(source: source, size: size * 0.5)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundStyle(iconColor(for: style))
        }
    }

    private func background(for style: ZenIconStyle) -> AnyShapeStyle {
        switch style {
        case .simple:
            AnyShapeStyle(color)
        case .gradient:
            AnyShapeStyle(LinearGradient(
                colors: [color, color.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        case .single:
            AnyShapeStyle(color.opacity(0.15))
        }
    }

    private func iconColor(for style: ZenIconStyle) -> Color {
        switch style {
        case .simple, .gradient: .white
        case .single: color
        }
    }
}

#Preview {
    VStack(spacing: ZenSpacing.large) {
        ZenThemePreviewScope(theme: ZenTheme(iconStyle: .simple)) {
            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                Text("simple").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: ZenSpacing.small) {
                    ZenIconBadge(systemName: "person.circle.fill", color: .blue)
                    ZenIconBadge(systemName: "bell.fill", color: .red)
                    ZenIconBadge(systemName: "shield.fill", color: .green)
                    ZenIconBadge(systemName: "globe", color: .cyan)
                    ZenIconBadge(systemName: "paintpalette.fill", color: .purple)
                }
            }
        }

        ZenThemePreviewScope(theme: ZenTheme(iconStyle: .gradient)) {
            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                Text("gradient").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: ZenSpacing.small) {
                    ZenIconBadge(systemName: "person.circle.fill", color: .blue)
                    ZenIconBadge(systemName: "bell.fill", color: .red)
                    ZenIconBadge(systemName: "shield.fill", color: .green)
                    ZenIconBadge(systemName: "globe", color: .cyan)
                    ZenIconBadge(systemName: "paintpalette.fill", color: .purple)
                }
            }
        }

        ZenThemePreviewScope(theme: ZenTheme(iconStyle: .single)) {
            VStack(alignment: .leading, spacing: ZenSpacing.small) {
                Text("single").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: ZenSpacing.small) {
                    ZenIconBadge(systemName: "person.circle.fill", color: .blue)
                    ZenIconBadge(systemName: "bell.fill", color: .red)
                    ZenIconBadge(systemName: "shield.fill", color: .green)
                    ZenIconBadge(systemName: "globe", color: .cyan)
                    ZenIconBadge(systemName: "paintpalette.fill", color: .purple)
                }
            }
        }
    }
    .padding()
    .background(Color.zenBackground)
}
