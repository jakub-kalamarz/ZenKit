import SwiftUI

public struct ZenInputBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var text: String
    @FocusState private var internalFocus: Bool

    private let prompt: LocalizedStringKey
    private let promptPlaceholder: String
    private let isLoading: Bool
    private let lineLimit: ClosedRange<Int>
    private let submitsOnReturn: Bool
    private let keepsFocusAfterSubmit: Bool
    private let onSubmit: () -> Void
    private let externalFocus: FocusState<Bool>.Binding?

    public init(
        text: Binding<String>,
        prompt: LocalizedStringKey,
        promptPlaceholder: String = "",
        isFocused: FocusState<Bool>.Binding? = nil,
        isLoading: Bool = false,
        lineLimit: ClosedRange<Int> = 1...4,
        submitsOnReturn: Bool = false,
        keepsFocusAfterSubmit: Bool = false,
        onSubmit: @escaping () -> Void
    ) {
        _text = text
        self.prompt = prompt
        self.promptPlaceholder = promptPlaceholder
        self.externalFocus = isFocused
        self.isLoading = isLoading
        self.lineLimit = lineLimit
        self.submitsOnReturn = submitsOnReturn
        self.keepsFocusAfterSubmit = keepsFocusAfterSubmit
        self.onSubmit = onSubmit
    }

    private let cornerRadius: CGFloat = 22

    public var body: some View {
        #if DEBUG
        #endif
        HStack(alignment: .bottom, spacing: ZenSpacing.small) {
            textField
                .frame(minHeight: 34)
            submitButton
        }
        .padding(.leading, ZenSpacing.medium)
        .padding(.trailing, ZenSpacing.small)
        .padding(.vertical, ZenSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.zenSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(borderColor, lineWidth: isFieldFocused ? 1.5 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture { setFieldFocused(true) }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isFieldFocused)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: canSubmit)
    }

    @ViewBuilder
    private var textField: some View {
        let field = inputField
            .font(.zenBody)
            .foregroundStyle(Color.zenTextPrimary)
            .textFieldStyle(.plain)
            .accessibilityLabel(prompt)

        if let externalFocus {
            field.focused(externalFocus)
        } else {
            field.focused($internalFocus)
        }
    }

    @ViewBuilder
    private var inputField: some View {
        if submitsOnReturn {
            TextField(inputPrompt, text: $text)
                .submitLabel(.send)
                .onSubmit(submitIfPossible)
        } else {
            TextField(inputPrompt, text: $text, axis: .vertical)
                .lineLimit(lineLimit)
                .submitLabel(.return)
        }
    }

    private var submitButton: some View {
        Button(action: submitIfPossible) {
            if isLoading {
                ProgressView()
                    .tint(Color.zenPrimaryForeground)
                    .controlSize(.small)
            } else {
                Image(systemName: "arrow.up")
                    .font(.zen(.body2, weight: .bold))
                    .foregroundStyle(isSubmitControlActive ? Color.zenPrimaryForeground : Color.zenTextPlaceholder)
            }
        }
        .frame(width: 34, height: 34)
        .background(
            Circle()
                .fill(isSubmitControlActive ? Color.zenPrimary : Color.zenSurfaceMuted)
        )
        .disabled(!canSubmit)
        .accessibilityLabel("Send")
    }

    private var isSubmitControlActive: Bool {
        isLoading || canSubmit
    }

    private var canSubmit: Bool {
        !isLoading && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isFieldFocused: Bool {
        externalFocus?.wrappedValue ?? internalFocus
    }

    private var inputPrompt: LocalizedStringKey {
        promptPlaceholder.isEmpty ? prompt : LocalizedStringKey(promptPlaceholder)
    }

    private var borderColor: Color {
        isFieldFocused ? Color.zenTextStrong.opacity(0.5) : Color.zenBorder
    }

    private func setFieldFocused(_ isFocused: Bool) {
        if let externalFocus {
            externalFocus.wrappedValue = isFocused
        } else {
            internalFocus = isFocused
        }
    }

    private func submitIfPossible() {
        guard canSubmit else { return }
        onSubmit()
        guard keepsFocusAfterSubmit else { return }
        Task { @MainActor in
            await Task.yield()
            setFieldFocused(true)
        }
    }
}

private struct ZenInputBarPreview: View {
    @State private var text = ""
    @State private var multiText = "Hello, this is a longer message that wraps, demonstrating the multiline capabilities of the input bar. Try resizing the preview to see how it adapts!"

    var body: some View {
        VStack(spacing: ZenSpacing.medium) {
            ZenInputBar(text: $text, prompt: "Ask anything...", submitsOnReturn: true, onSubmit: {})
            ZenInputBar(text: $text, prompt: "Ask anything...", isLoading: true, onSubmit: {})
            ZenInputBar(text: $multiText, prompt: "Message...", keepsFocusAfterSubmit: true, onSubmit: {})
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenInputBarPreview()
}
