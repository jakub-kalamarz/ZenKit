import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct ZenInputBar: View {
    public enum Appearance: Sendable {
        case standard
        case glass
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var text: String
    @FocusState private var internalFocus: Bool

    private let prompt: LocalizedStringKey
    private let promptPlaceholder: String
    private let isLoading: Bool
    private let lineLimit: ClosedRange<Int>
    private let submitsOnReturn: Bool
    private let keepsFocusAfterSubmit: Bool
    private let appearance: Appearance
    private let onSubmit: () -> Void
    private let externalFocus: FocusState<Bool>.Binding?

    /// Reported by the layout, which is the only place the field's measured height is known.
    @State private var isExpanded = false

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
        appearance: Appearance = .standard,
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
        self.appearance = appearance
        self.onSubmit = onSubmit
    }

    private static let submitDiameter: CGFloat = 44
    private static let expandedCornerRadius: CGFloat = ZenRadius.large + ZenSpacing.small

    /// A capsule reads as a capsule only while the bar is one line tall. Past that its side
    /// arcs swell into a lozenge, so the surface squares off into a rounded rectangle instead.
    private var shape: AnyShape {
        isExpanded
            ? AnyShape(RoundedRectangle(cornerRadius: Self.expandedCornerRadius, style: .continuous))
            : AnyShape(Capsule(style: .continuous))
    }

    public var body: some View {
        let inputContent = ZenInputBarLayout(
            isExpanded: isExpanded,
            spacing: ZenSpacing.xSmall,
            maximumLines: lineLimit.upperBound,
            // A single-line field cannot wrap; it scrolls its own text instead.
            allowsExpansion: !submitsOnReturn,
            onExpansionChange: { expanded in
                guard expanded != isExpanded else { return }
                isExpanded = expanded
            }
        ) {
            textField
            submitButton

            // Wrap probes. A `TextField` reports the same height whatever width it is offered,
            // so it cannot say whether it wrapped; `Text` honours the proposal, so the layout
            // measures these two instead — the live text, and one line of it as the baseline.
            Text(text).font(.zenBody).hidden()
            Text(verbatim: "A").font(.zenBody).hidden()
        }
        .padding(.leading, ZenSpacing.medium)
        .padding(.trailing, ZenSpacing.xSmall)
        .padding(.vertical, ZenSpacing.xSmall)

        Group {
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *), appearance == .glass {
                inputContent
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
                inputContent
                    .background(shape.fill(Color.zenSurface))
                    .overlay { border }
                    .zenControlSurfaceShadow()
            }
        }
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
        .animation(reduceMotion ? nil : .snappy(duration: 0.24), value: isExpanded)
    }

    /// `strokeBorder` insets the stroke so it stays inside the surface, and it is only available
    /// on a concrete shape — hence the branch here rather than reusing the erased `shape`.
    @ViewBuilder
    private var border: some View {
        let width = isFieldFocused ? 1.5 : 1
        if isExpanded {
            RoundedRectangle(cornerRadius: Self.expandedCornerRadius, style: .continuous)
                .strokeBorder(borderColor, lineWidth: width)
        } else {
            Capsule(style: .continuous)
                .strokeBorder(borderColor, lineWidth: width)
        }
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
            Group {
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
                    .fill(isSubmitControlActive ? Color.zenPrimary : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
        .contentShape(.rect)
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

/// Reflows the bar between its one-line and expanded shapes without replacing the text field.
///
/// A `if isExpanded { VStack } else { HStack }` would build a new field on each side of the
/// branch, and SwiftUI tears the old one down — taking first responder with it, so the keyboard
/// dips out the moment the text wraps. One `Layout` moving the same two subviews keeps the field
/// in the same place in the hierarchy.
///
/// Subviews, in order: the field, then the submit button.
private struct ZenInputBarLayout: Layout {
    let isExpanded: Bool
    let spacing: CGFloat
    let maximumLines: Int
    let allowsExpansion: Bool
    let onExpansionChange: (Bool) -> Void

    /// The 44pt submit button carries ~5pt of tap slack above its 34pt circle, so the accessory
    /// row can ride up into the text's bottom margin without the two ever touching.
    private static let accessoryOverlap = ZenSpacing.xSmall

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count >= 4 else { return .zero }

        let width = proposal.width ?? subviews.map { $0.sizeThatFits(.unspecified).width }.reduce(0, +)
        let submit = subviews[1].sizeThatFits(.unspecified)
        let field = fieldSize(subviews: subviews, in: width, submit: submit)

        report(wraps: field.wraps)

        return CGSize(
            width: width,
            height: isExpanded
                ? field.size.height + submit.height - Self.accessoryOverlap
                : max(field.size.height, submit.height)
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count >= 4 else { return }

        // The probes never draw; give them no room.
        for index in 2..<subviews.count {
            subviews[index].place(at: bounds.origin, anchor: .topLeading, proposal: .zero)
        }

        let submit = subviews[1].sizeThatFits(.unspecified)
        let submitProposal = ProposedViewSize(width: submit.width, height: submit.height)
        let field = fieldSize(subviews: subviews, in: bounds.width, submit: submit)

        report(wraps: field.wraps)

        if isExpanded {
            subviews[0].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY),
                anchor: .topLeading,
                proposal: .init(width: field.size.width, height: field.size.height)
            )
            subviews[1].place(
                at: CGPoint(
                    x: bounds.maxX - submit.width,
                    y: bounds.minY + field.size.height - Self.accessoryOverlap
                ),
                anchor: .topLeading,
                proposal: submitProposal
            )
            return
        }

        subviews[0].place(
            at: CGPoint(x: bounds.minX, y: bounds.midY - field.size.height / 2),
            anchor: .topLeading,
            proposal: .init(width: field.size.width, height: field.size.height)
        )
        subviews[1].place(
            at: CGPoint(x: bounds.maxX - submit.width, y: bounds.midY - submit.height / 2),
            anchor: .topLeading,
            proposal: submitProposal
        )
    }

    /// Expansion is always judged at the *collapsed* width — the width the text has while it
    /// still shares its row with the button. Judging it at the expanded width instead would let
    /// the very wrap that caused the expansion disappear, collapsing the bar and re-wrapping the
    /// text: a layout that never settles.
    private func fieldSize(
        subviews: Subviews,
        in total: CGFloat,
        submit: CGSize
    ) -> (size: CGSize, wraps: Bool) {
        // One line of the same font is the baseline — measured rather than assumed, so the
        // comparison holds at any Dynamic Type size.
        let lineHeight = subviews[3].sizeThatFits(.unspecified).height
        let collapsedWidth = max(0, total - submit.width - spacing)
        let wraps = subviews[2].sizeThatFits(.init(width: collapsedWidth, height: nil)).height
            > lineHeight + 1

        let width = isExpanded ? total : collapsedWidth
        let textHeight = subviews[2].sizeThatFits(.init(width: width, height: nil)).height
        // One line is the floor, not the bar's 44pt control height: forcing the taller frame
        // makes the field top-align its text instead of centring it, and the 44pt submit button
        // already holds the collapsed bar open.
        let height = max(lineHeight, min(textHeight, lineHeight * CGFloat(maximumLines)))
        return (CGSize(width: width, height: height), wraps)
    }

    /// Layout runs inside the view update, so the state change has to wait for the next turn.
    private func report(wraps: Bool) {
        let expanded = allowsExpansion && wraps
        guard expanded != isExpanded else { return }
        Task { @MainActor in onExpansionChange(expanded) }
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
