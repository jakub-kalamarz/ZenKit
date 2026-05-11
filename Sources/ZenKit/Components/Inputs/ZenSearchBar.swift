import SwiftUI

public struct ZenSearchBar: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @FocusState private var isFocused: Bool

    private let prompt: LocalizedStringKey
    @Binding private var text: String

    public init(text: Binding<String>, prompt: LocalizedStringKey = "Search") {
        _text = text
        self.prompt = prompt
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let controlStyle = ZenControlSurfaceStyle.searchField(theme: theme)

        HStack(spacing: ZenSpacing.small) {
            ZenIcon(systemName: "magnifyingglass", size: 15)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.zenTextMuted)

            TextField(prompt, text: $text)
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextPrimary)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    ZenIcon(systemName: "xmark.circle.fill", size: 15)
                        .foregroundStyle(Color.zenTextMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(minHeight: theme.resolvedMetrics.controlHeight)
        .background(controlStyle.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor(theme: theme, controlStyle: controlStyle), lineWidth: borderWidth(controlStyle: controlStyle))
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func borderWidth(controlStyle: ZenControlSurfaceStyle) -> CGFloat {
        isFocused ? 1 : controlStyle.borderWidth
    }

    private func borderColor(theme: ZenTheme, controlStyle: ZenControlSurfaceStyle) -> Color {
        if isFocused {
            return theme.resolvedColors.focusRing.color
        }
        return controlStyle.borderColor
    }
}

private struct ZenSearchBarPreview: View {
    @State private var query = ""

    var body: some View {
        VStack(spacing: ZenSpacing.small) {
            ZenSearchBar(text: $query)
            ZenSearchBar(text: $query, prompt: "Search members…")
            if !query.isEmpty {
                Text("Searching for: \(query)")
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenSearchBarPreview()
}
