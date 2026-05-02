import SwiftUI

public struct ZenInputBar: View {
    @Binding private var text: String
    @FocusState private var internalFocus: Bool

    private let prompt: String
    private let isLoading: Bool
    private let lineLimit: ClosedRange<Int>
    private let onSubmit: () -> Void
    private let externalFocus: FocusState<Bool>.Binding?

    public init(
        text: Binding<String>,
        prompt: String,
        isFocused: FocusState<Bool>.Binding? = nil,
        isLoading: Bool = false,
        lineLimit: ClosedRange<Int> = 1...4,
        onSubmit: @escaping () -> Void
    ) {
        _text = text
        self.prompt = prompt
        self.externalFocus = isFocused
        self.isLoading = isLoading
        self.lineLimit = lineLimit
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
        .background(
            Capsule()
                .fill(Color.zenSurface)
                .overlay(Capsule().stroke(Color.zenBorder, lineWidth: 1))
        )
    }

    @ViewBuilder
    private var textField: some View {
        let field = TextField(prompt, text: $text, axis: .vertical)
            .font(.zenGroup)
            .foregroundStyle(Color.zenTextPrimary)
            .textFieldStyle(.plain)
            .lineLimit(lineLimit)

        if let externalFocus {
            field.focused(externalFocus)
        } else {
            field.focused($internalFocus)
        }
    }

    private var submitButton: some View {
        Button(action: onSubmit) {
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
        .background(Circle().fill(Color.zenPrimary))
        .disabled(isLoading)
    }
}

private struct ZenInputBarPreview: View {
    @State private var text = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: ZenSpacing.medium) {
            ZenInputBar(text: $text, prompt: "Ask anything...", onSubmit: {})
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
