import SwiftUI
import ZenKit

struct ColorSwatchShowcaseScreen: View {
    @State private var accentColor: Color = .blue
    @State private var labelColor: Color = .red

    private let systemPalette: [Color] = [
        .red, .orange, .yellow, .green, .teal, .blue,
        .indigo, .purple, .pink, .brown, .gray, .black
    ]

    private let brandPalette: [Color] = [
        Color(red: 0.25, green: 0.32, blue: 0.97),
        Color(red: 0.0, green: 0.62, blue: 0.74),
        Color(red: 0.20, green: 0.78, blue: 0.35),
        Color(red: 1.0, green: 0.58, blue: 0.0),
        Color(red: 1.0, green: 0.27, blue: 0.23),
        Color(red: 0.61, green: 0.15, blue: 0.69)
    ]

    var body: some View {
        ShowcaseScreen(title: "Color Swatch") {
            ZenCard(title: "System Colors", subtitle: "12-color grid with selection") {
                VStack(spacing: ZenSpacing.small) {
                    ZenColorSwatch(selection: $accentColor, colors: systemPalette)

                    HStack(spacing: ZenSpacing.small) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 20, height: 20)
                        Text("Selected accent color")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            ZenCard(title: "Brand Palette", subtitle: "Compact 6-color picker") {
                ZenColorSwatch(selection: $labelColor, colors: brandPalette, columns: 6)
            }

            ZenCard(title: "Narrow Grid", subtitle: "4-column layout") {
                ZenColorSwatch(selection: $accentColor, colors: systemPalette, columns: 4)
            }
        }
    }
}
