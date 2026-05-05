import SwiftUI

public struct ZenInputBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var text: String
    @FocusState private var internalFocus: Bool

    private let prompt: String
    private let isLoading: Bool
    private let lineLimit: ClosedRange<Int>
    private let submitsOnReturn: Bool
    private let onSubmit: () -> Void
    private let externalFocus: FocusState<Bool>.Binding?

    public init(
        text: Binding<String>,
        prompt: String,
        isFocused: FocusState<Bool>.Binding? = nil,
        isLoading: Bool = false,
        lineLimit: ClosedRange<Int> = 1...4,
        submitsOnReturn: Bool = false,
        onSubmit: @escaping () -> Void
    ) {
        _text = text
        self.prompt = prompt
        self.externalFocus = isFocused
        self.isLoading = isLoading
        self.lineLimit = lineLimit
        self.submitsOnReturn = submitsOnReturn
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: ZenSpacing.small) {
            textField
            submitButton
        }
        .padding(.leading, ZenSpacing.medium)
        .padding(.trailing, ZenSpacing.xSmall)
        .padding(.vertical, ZenSpacing.xSmall)
        .background(Capsule().fill(Color.zenSurface))
        .overlay(
            Capsule()
                .strokeBorder(borderColor, lineWidth: isFieldFocused ? 1.5 : 1)
        )
        .shadow(color: shadowColor, radius: isFieldFocused ? 14 : 0, y: isFieldFocused ? 6 : 0)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isFieldFocused)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: canSubmit)
    }

    @ViewBuilder
    private var textField: some View {
        let field = inputField
            .font(.zenBody2)
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
            TextField(prompt, text: $text)
                .submitLabel(.send)
                .onSubmit(submitIfPossible)
        } else {
            TextField(prompt, text: $text, axis: .vertical)
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
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.zenPrimaryForeground)
            }
        }
        .frame(width: 34, height: 34)
        .background(
            Circle()
                .fill(isSubmitControlActive ? Color.zenPrimary : Color.zenSurfaceMuted)
        )
        .scaleEffect(isSubmitControlActive ? 1 : 0.92)
        .opacity(isSubmitControlActive ? 1 : 0.72)
        .disabled(!canSubmit)
        .accessibilityLabel("Send")
        .accessibilityHint(submitsOnReturn ? "Sends the message. Return also sends." : "Sends the message.")
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

    private var borderColor: Color {
        if isFieldFocused {
            return Color.zenPrimary.opacity(0.75)
        }

        return Color.zenBorder
    }

    private var shadowColor: Color {
        Color.zenPrimary.opacity(0.10)
    }

    private func submitIfPossible() {
        guard canSubmit else { return }
        onSubmit()
    }
}

private struct ZenInputBarPreview: View {
    @State private var text = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: ZenSpacing.medium) {
            ZenInputBar(text: $text, prompt: "Ask anything...", submitsOnReturn: true, onSubmit: {})
            ZenInputBar(text: $text, prompt: "Ask anything...", isLoading: true, onSubmit: {})
            ZenInputBar(text: .constant("Some text"), prompt: "Ask anything...", onSubmit: {})
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenInputBarPreview()
}
