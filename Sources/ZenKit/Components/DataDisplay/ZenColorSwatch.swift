import SwiftUI

public struct ZenColorSwatch: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    @Binding private var selection: Color
    private let colors: [Color]
    private let columns: Int

    public init(selection: Binding<Color>, colors: [Color], columns: Int = 6) {
        _selection = selection
        self.colors = colors
        self.columns = columns
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: columns),
            spacing: ZenSpacing.small
        ) {
            ForEach(colors.indices, id: \.self) { index in
                let color = colors[index]
                let isSelected = color == selection

                Button {
                    selection = color
                } label: {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 36, height: 36)

                        if isSelected {
                            Circle()
                                .strokeBorder(Color.zenBorder, lineWidth: 2)
                                .frame(width: 40, height: 40)

                            ZenIcon(systemName: "checkmark", size: 12)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(ZenSpacing.medium)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct ZenColorSwatchPreview: View {
    @State private var selection: Color = .blue

    private let palette: [Color] = [
        .red, .orange, .yellow, .green, .teal, .blue,
        .indigo, .purple, .pink, .brown, .gray, .black
    ]

    var body: some View {
        VStack(spacing: ZenSpacing.medium) {
            ZenColorSwatch(selection: $selection, colors: palette)

            HStack(spacing: ZenSpacing.small) {
                Circle()
                    .fill(selection)
                    .frame(width: 24, height: 24)
                Text("Selected color")
                    .font(.zenTextSM.weight(.medium))
                    .foregroundStyle(Color.zenTextPrimary)
            }
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenColorSwatchPreview()
}
