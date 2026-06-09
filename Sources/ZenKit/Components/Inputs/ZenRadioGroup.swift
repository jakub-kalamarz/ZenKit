import SwiftUI

public enum ZenRadioAppearance: Sendable {
    case `default`
    case card
}

public struct ZenRadioGroup<Value: Hashable>: View {
    @Binding private var selection: Value
    private let options: [ZenRadioOption<Value>]
    private let appearance: ZenRadioAppearance

    public init(
        selection: Binding<Value>,
        appearance: ZenRadioAppearance = .default,
        options: [ZenRadioOption<Value>]
    ) {
        self._selection = selection
        self.appearance = appearance
        self.options = options
    }

    public var body: some View {
        VStack(spacing: appearance == .card ? ZenSpacing.small : ZenSpacing.xSmall) {
            ForEach(options) { option in
                ZenRadioRow(
                    option: option,
                    isSelected: selection == option.value,
                    appearance: appearance,
                    onSelect: { selection = option.value }
                )
            }
        }
    }
}

public struct ZenRadioOption<Value: Hashable>: Identifiable {
    public let id: Value
    public let value: Value
    public let label: String
    public let description: String?

    public init(value: Value, label: String, description: String? = nil) {
        self.id = value
        self.value = value
        self.label = label
        self.description = description
    }
}

private struct ZenRadioRow<Value: Hashable>: View {
    let option: ZenRadioOption<Value>
    let isSelected: Bool
    let appearance: ZenRadioAppearance
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: ZenSpacing.small) {
                radioIndicator

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)

                    if let description = option.description {
                        Text(description)
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }

                Spacer()
            }
            .padding(appearance == .card ? ZenSpacing.medium : ZenSpacing.xSmall)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: appearance == .card ? ZenRadius.small : 0, style: .continuous))
            .overlay(cardBorder)
        }
        .buttonStyle(.plain)
    }

    private var radioIndicator: some View {
        Circle()
            .strokeBorder(isSelected ? Color.zenPrimary : Color.zenBorderSubtle, lineWidth: isSelected ? 5 : 1.5)
            .frame(width: 18, height: 18)
            .animation(.easeOut(duration: 0.15), value: isSelected)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if appearance == .card {
            RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                .fill(isSelected ? Color.zenPrimary.opacity(0.04) : Color.zenSurface)
        }
    }

    @ViewBuilder
    private var cardBorder: some View {
        if appearance == .card {
            RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                .strokeBorder(isSelected ? Color.zenPrimary : Color.zenBorderSubtle, lineWidth: 1)
        }
    }
}

#Preview("ZenRadioGroup") {
    struct RadioPreview: View {
        @State private var selected = "option1"

        var body: some View {
            VStack(spacing: ZenSpacing.large) {
                ZenRadioGroup(
                    selection: $selected,
                    options: [
                        .init(value: "option1", label: "Default", description: "Use the default setting"),
                        .init(value: "option2", label: "Custom"),
                        .init(value: "option3", label: "Advanced", description: "For power users")
                    ]
                )

                ZenRadioGroup(
                    selection: $selected,
                    appearance: .card,
                    options: [
                        .init(value: "option1", label: "Free", description: "Basic features"),
                        .init(value: "option2", label: "Pro", description: "All features included"),
                        .init(value: "option3", label: "Enterprise", description: "Custom solutions")
                    ]
                )
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return RadioPreview()
}
