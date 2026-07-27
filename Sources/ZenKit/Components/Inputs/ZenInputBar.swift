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

    #if canImport(UIKit)
    /// First-responder state for the UIKit-backed field. A SwiftUI `@FocusState`
    /// only keeps a value while a SwiftUI view claims focus, so writing the
    /// external binding from `textFieldDidBeginEditing` made SwiftUI reset it to
    /// `false` — which resigned the field again and closed the keyboard the
    /// instant it opened. On this path the external binding is a focus *request*
    /// channel only; this state is the source of truth.
    @State private var uiKitFocus = false
    #endif

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
        .onTapGesture {
            // Only a *request* to focus. Re-asserting focus while the field is
            // already focused fights app-level dismiss gestures, which run
            // simultaneously with this recogniser.
            guard !isFieldFocused else { return }
            setFieldFocused(true)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isFieldFocused)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: canSubmit)
    }

    @ViewBuilder
    private var textField: some View {
        #if canImport(UIKit)
        if usesUIKitField {
            // A UITextField lets us submit on return WITHOUT resigning first
            // responder (`textFieldShouldReturn` returns false), so the keyboard
            // never dips out and back in. The SwiftUI `.onSubmit` path always
            // resigns, which forced a hide/show flicker even when refocused.
            ZenReturnSubmitTextField(
                text: $text,
                isFocused: $uiKitFocus,
                onSubmit: submitIfPossible
            )
            .overlay(alignment: .leading) {
                if text.isEmpty {
                    Text(inputPrompt)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPlaceholder)
                        .allowsHitTesting(false)
                }
            }
            .accessibilityLabel(prompt)
            .onChange(of: externalFocus?.wrappedValue ?? false) { _, requested in
                // Only honour focus requests — a `false` here is usually SwiftUI
                // dropping the unclaimed @FocusState, not the user dismissing.
                if requested { uiKitFocus = true }
            }
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

    /// The UIKit-backed field is only used when a submit must not resign the
    /// keyboard; every other configuration stays on the SwiftUI `TextField`.
    private var usesUIKitField: Bool {
        submitsOnReturn && keepsFocusAfterSubmit
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
        #if canImport(UIKit)
        if usesUIKitField { return uiKitFocus }
        #endif
        return externalFocus?.wrappedValue ?? internalFocus
    }

    private var inputPrompt: LocalizedStringKey {
        promptPlaceholder.isEmpty ? prompt : LocalizedStringKey(promptPlaceholder)
    }

    private var borderColor: Color {
        isFieldFocused ? Color.zenTextStrong.opacity(0.5) : Color.zenBorder
    }

    private func setFieldFocused(_ isFocused: Bool) {
        #if canImport(UIKit)
        if usesUIKitField {
            uiKitFocus = isFocused
            return
        }
        #endif
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

        // `isFocused` lags the actual first-responder state by one runloop turn:
        // an app-level `endEditing(true)` resigns the field synchronously, while
        // the matching `false` only arrives via `textFieldDidEndEditing`. Any
        // re-render landing in that window would otherwise read a stale `true`
        // and re-open the keyboard the user just dismissed — hence the re-read
        // of the binding inside the async hop instead of trusting `wantsFocus`.
        let focus = isFocused
        let wantsFocus = focus.wrappedValue
        if wantsFocus, !field.isFirstResponder {
            DispatchQueue.main.async {
                guard focus.wrappedValue, !field.isFirstResponder else { return }
                field.becomeFirstResponder()
            }
        } else if !wantsFocus, field.isFirstResponder {
            DispatchQueue.main.async {
                guard !focus.wrappedValue, field.isFirstResponder else { return }
                field.resignFirstResponder()
            }
        }
    }

    /// Without this the representable accepts whatever height SwiftUI proposes
    /// and the input bar grows to fill the screen — a single-line field must
    /// report its intrinsic height instead.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        let intrinsic = uiView.intrinsicContentSize
        return CGSize(
            width: proposal.width ?? intrinsic.width,
            height: max(intrinsic.height, uiView.font?.lineHeight ?? 0)
        )
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
