import SwiftUI
import ZenKit

struct ThemePreviewScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Theme") {
            ZenCard(
                title: "Active Theme",
                subtitle: "Current defaults exposed by ZenKit"
            ) {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    Text("Density: \(description(for: ZenTheme.current.density))")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                    Text("Corner style: \(description(for: ZenTheme.current.cornerStyle))")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                    Text("Motion: \(description(for: ZenTheme.current.motion))")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                }
            }

            ZenCard(
                title: "Color Tokens",
                subtitle: "Quick visual check for background and surface layers"
            ) {
                HStack(spacing: ZenSpacing.medium) {
                    tokenSwatch(title: "Background", color: .zenBackground)
                    tokenSwatch(title: "Surface", color: .zenSurface)
                    tokenSwatch(title: "Muted", color: .zenSurfaceMuted)
                }
            }
        }
    }

    private func tokenSwatch(title: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            RoundedRectangle(cornerRadius: ZenRadius.small)
                .fill(color)
                .frame(height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: ZenRadius.small)
                        .stroke(Color.zenBorder, lineWidth: 1)
                )

            Text(title)
                .font(.zenCaption)
                .foregroundStyle(Color.zenTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func description(for density: ZenDensity) -> String {
        switch density {
        case .comfortable:
            return "Comfortable"
        case .compact:
            return "Compact"
        }
    }

    private func description(for cornerStyle: ZenCornerStyle) -> String {
        switch cornerStyle {
        case .none:
            return "None"
        case .rounded:
            return "Rounded"
        case .pronounced:
            return "Pronounced"
        }
    }

    private func description(for motion: ZenMotion) -> String {
        switch motion {
        case .standard:
            return "Standard"
        case .reduced:
            return "Reduced"
        }
    }
}
