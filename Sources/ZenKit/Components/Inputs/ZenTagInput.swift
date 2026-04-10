import SwiftUI

public struct ZenTagInput: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool

    @Binding private var tags: [String]
    private let prompt: String
    private let onSubmit: ((String) -> Bool)?

    public init(
        tags: Binding<[String]>,
        prompt: String = "Add tag...",
        onSubmit: ((String) -> Bool)? = nil
    ) {
        _tags = tags
        self.prompt = prompt
        self.onSubmit = onSubmit
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let controlStyle = ZenControlSurfaceStyle.field(theme: theme)
        let borderColor = isFocused
            ? theme.resolvedColors.focusRing.color
            : controlStyle.borderColor

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ZenSpacing.xSmall) {
                ForEach(tags, id: \.self) { tag in
                    ZenBadge(LocalizedStringKey(tag)) {
                        removeTag(tag)
                    }
                }

                TextField(prompt, text: $inputText)
                    .font(.zenTextBase)
                    .foregroundStyle(Color.zenTextPrimary)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .fixedSize()
                    .onSubmit {
                        submitTag()
                    }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: theme.resolvedMetrics.controlHeight)
        .background(controlStyle.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(borderColor, lineWidth: controlStyle.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }

    private func submitTag() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let onSubmit {
            if onSubmit(trimmed) && !tags.contains(trimmed) {
                tags.append(trimmed)
            }
        } else {
            if !tags.contains(trimmed) {
                tags.append(trimmed)
            }
        }

        inputText = ""
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

private struct ZenTagInputPreview: View {
    @State private var tags: [String] = ["SwiftUI", "Design", "ZenKit"]

    var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            Text("Tags")
                .font(.zenTextSM.weight(.medium))
                .foregroundStyle(Color.zenTextPrimary)

            ZenTagInput(tags: $tags, prompt: "Add tag...")

            Text("Type a tag name and press Return to add. Tap \u{00D7} to remove.")
                .font(.zenTextXS)
                .foregroundStyle(Color.zenTextMuted)
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenTagInputPreview()
}
