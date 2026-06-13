import SwiftUI

public struct ZenInputGroup<Leading: View, Trailing: View>: View {
    @Binding private var text: String
    private let placeholder: String
    private let label: String?
    private let leading: Leading?
    private let trailing: Trailing?
    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        #if DEBUG
        #endif
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if let label {
                ZenLabel(label)
            }

            HStack(spacing: 0) {
                if let leading {
                    leading
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.leading, 12)
                        .padding(.trailing, 4)
                }

                TextField(placeholder, text: $text)
                    .font(.zenIntro)
                    .foregroundStyle(Color.zenTextPrimary)
                    .focused($isFocused)
                    .padding(.horizontal, leading == nil ? 12 : 0)

                if let trailing {
                    trailing
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.trailing, 8)
                        .padding(.leading, 4)
                }
            }
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

extension ZenInputGroup where Leading == EmptyView {
    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.leading = nil
        self.trailing = trailing()
    }
}

extension ZenInputGroup where Trailing == EmptyView {
    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.leading = leading()
        self.trailing = nil
    }
}

#Preview("ZenInputGroup") {
    struct InputGroupPreview: View {
        @State private var url = ""
        @State private var amount = ""

        var body: some View {
            VStack(spacing: ZenSpacing.medium) {
                ZenInputGroup(text: $url, placeholder: "example.com", label: "URL") {
                    Text("https://")
                } trailing: {
                    EmptyView()
                }

                ZenInputGroup(text: $amount, placeholder: "0.00", label: "Amount") {
                    Text("$")
                } trailing: {
                    Text("USD")
                }
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return InputGroupPreview()
}
