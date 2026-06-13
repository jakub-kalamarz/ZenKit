import SwiftUI

public struct ZenSensitiveInput: View {
    @Binding private var text: String
    private let placeholder: String
    private let label: String?
    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
    }

    public var body: some View {
        #if DEBUG
        #endif
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if let label {
                ZenLabel(label)
            }

            HStack(spacing: 0) {
                Group {
                    if isRevealed {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.zenIntro)
                .foregroundStyle(Color.zenTextPrimary)
                .focused($isFocused)

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: ZenTheme.current.resolvedMetrics.controlHeight)
            .background(Color.zenSurface)
            .clipShape(RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                    .strokeBorder(isFocused ? Color.zenPrimary : Color.zenBorderSubtle, lineWidth: isFocused ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous))
            .onTapGesture {
                isFocused = true
            }
        }
    }
}

#Preview("ZenSensitiveInput") {
    struct SensitiveInputPreview: View {
        @State private var password = ""
        @State private var apiKey = "sk-1234567890abcdef"

        var body: some View {
            VStack(spacing: ZenSpacing.medium) {
                ZenSensitiveInput(text: $password, placeholder: "Enter password", label: "Password")
                ZenSensitiveInput(text: $apiKey, placeholder: "API Key", label: "API Key")
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return SensitiveInputPreview()
}
