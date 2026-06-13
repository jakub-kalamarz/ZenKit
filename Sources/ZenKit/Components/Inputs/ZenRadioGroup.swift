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
        #if DEBUG
        #endif
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
    public let imageURL: URL?
    public let trailingText: String?

    public init(
        value: Value,
        label: String,
        description: String? = nil,
        imageURL: URL? = nil,
        trailingText: String? = nil
    ) {
        self.id = value
        self.value = value
        self.label = label
        self.description = description
        self.imageURL = imageURL
        self.trailingText = trailingText
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

                if let imageURL = option.imageURL {
                    thumbnail(imageURL)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                        .lineLimit(1)

                    if let description = option.description {
                        Text(description)
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: ZenSpacing.small)

                if let trailingText = option.trailingText {
                    Text(trailingText)
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .lineLimit(1)
                }
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

    private func thumbnail(_ url: URL) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                .fill(Color.zenSurfaceMuted)

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    ZenIcon(systemName: "photo", size: 16)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous))
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
