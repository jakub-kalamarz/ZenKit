import SwiftUI

public struct ZenSearchBar: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @FocusState private var isFocused: Bool

    private let prompt: String
    @Binding private var text: String

    public init(text: Binding<String>, prompt: String = "Search") {
        _text = text
        self.prompt = prompt
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(spacing: ZenSpacing.small) {
            ZenIcon(systemName: "magnifyingglass", size: 15)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.zenTextMuted)

            TextField(prompt, text: $text)
                .font(.zenBody)
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
        .background(Color.zenSurfaceMuted)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor(theme: theme), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func borderColor(theme: ZenTheme) -> Color {
        if isFocused {
            return theme.resolvedColors.focusRing.color
        }
        return .zenBorder
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
                    .font(.zenCaption)
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
