import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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

    private let shape = Capsule(style: .continuous)

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
            shape.fill(Color.zenSurface)
        )
        .overlay(
            shape.strokeBorder(borderColor, lineWidth: isFieldFocused ? 1.5 : 1)
        )
        .zenControlSurfaceShadow()
        .contentShape(shape)
        .onTapGesture { setFieldFocused(true) }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isFieldFocused)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: canSubmit)
    }

    @ViewBuilder
    private var textField: some View {
        #if canImport(UIKit)
        if submitsOnReturn && keepsFocusAfterSubmit {
            // A UITextField lets us submit on return WITHOUT resigning first
            // responder (`textFieldShouldReturn` returns false), so the keyboard
            // never dips out and back in. The SwiftUI `.onSubmit` path always
            // resigns, which forced a hide/show flicker even when refocused.
            ZenReturnSubmitTextField(
                text: $text,
                isFocused: focusBinding,
                onSubmit: submitIfPossible
            )
            .frame(minHeight: 34)
            .overlay(alignment: .leading) {
                if text.isEmpty {
                    Text(inputPrompt)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPlaceholder)
                        .allowsHitTesting(false)
                }
            }
            .accessibilityLabel(prompt)
        } else {
            focusableSwiftUIField
        }
        #else
        focusableSwiftUIField
        #endif
    }

    @ViewBuilder
    private var focusableSwiftUIField: some View {
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

    /// Bridges the component's `@FocusState` (external or internal) to a plain
    /// `Binding<Bool>` so the UIKit-backed field can drive/report first-responder
    /// state and keep the border/focus styling in sync.
    private var focusBinding: Binding<Bool> {
        if let externalFocus {
            return Binding(get: { externalFocus.wrappedValue },
                           set: { externalFocus.wrappedValue = $0 })
        } else {
            return Binding(get: { internalFocus },
                           set: { internalFocus = $0 })
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
    }
}

#if canImport(UIKit)
/// A single-line `UITextField` wrapper that submits on return while keeping the
/// keyboard up. `textFieldShouldReturn` returns `false`, so the field never
/// resigns first responder — eliminating the keyboard hide/show flicker that
/// SwiftUI's `.onSubmit` (or the newline-insertion workaround) produces.
private struct ZenReturnSubmitTextField: UIViewRepresentable {
    @Binding var text: String
    var isFocused: Binding<Bool>
    let onSubmit: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.returnKeyType = .send
        field.enablesReturnKeyAutomatically = true
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.font = ZenTheme.current.resolvedTypography.fontSpec(for: .body).uiFont
        field.textColor = UIColor(Color.zenTextPrimary)
        field.tintColor = UIColor(Color.zenPrimary)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.addTarget(
            context.coordinator,
            action: #selector(Coordinator.editingChanged(_:)),
            for: .editingChanged
        )
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.onSubmit = onSubmit
        if field.text != text { field.text = text }

        let wantsFocus = isFocused.wrappedValue
        if wantsFocus, !field.isFirstResponder {
            DispatchQueue.main.async { field.becomeFirstResponder() }
        } else if !wantsFocus, field.isFirstResponder {
            DispatchQueue.main.async { field.resignFirstResponder() }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFocused: isFocused, onSubmit: onSubmit)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding private var text: String
        private let isFocused: Binding<Bool>
        var onSubmit: () -> Void

        init(text: Binding<String>, isFocused: Binding<Bool>, onSubmit: @escaping () -> Void) {
            _text = text
            self.isFocused = isFocused
            self.onSubmit = onSubmit
        }

        @objc func editingChanged(_ field: UITextField) {
            text = field.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit()
            return false
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            if !isFocused.wrappedValue { isFocused.wrappedValue = true }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if isFocused.wrappedValue { isFocused.wrappedValue = false }
        }
    }
}
#endif

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
