import SwiftUI

public struct ZenAutocompleteItem: Identifiable, Sendable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

public struct ZenAutocomplete: View {
    @Binding private var text: String
    private let placeholder: String
    private let label: String?
    private let items: [ZenAutocompleteItem]
    private let onSelect: (ZenAutocompleteItem) -> Void
    @State private var isExpanded = false
    @FocusState private var isFocused: Bool

    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        items: [ZenAutocompleteItem],
        onSelect: @escaping (ZenAutocompleteItem) -> Void = { _ in }
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.items = items
        self.onSelect = onSelect
    }

    private var filteredItems: [ZenAutocompleteItem] {
        guard !text.isEmpty else { return items }
        return items.filter { $0.label.localizedCaseInsensitiveContains(text) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                ZenLabel(label)
                    .padding(.bottom, ZenSpacing.xSmall)
            }

            VStack(alignment: .leading, spacing: 0) {
                TextField(placeholder, text: $text)
                    .font(.zenIntro)
                    .foregroundStyle(Color.zenTextPrimary)
                    .focused($isFocused)
                    .padding(.horizontal, 12)
                    .frame(minHeight: ZenTheme.current.resolvedMetrics.controlHeight)
                    .onChange(of: isFocused) { focused in
                        withAnimation(.easeOut(duration: 0.15)) {
                            isExpanded = focused
                        }
                    }

                if isExpanded && !filteredItems.isEmpty {
                    Divider()
                        .foregroundStyle(Color.zenBorderSubtle)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredItems) { item in
                                Button {
                                    text = item.label
                                    onSelect(item)
                                    isFocused = false
                                } label: {
                                    Text(item.label)
                                        .font(.zenBody)
                                        .foregroundStyle(Color.zenTextPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, ZenSpacing.small)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            .background(Color.zenSurface)
            .clipShape(RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ZenRadius.small, style: .continuous)
                    .strokeBorder(isFocused ? Color.zenPrimary : Color.zenBorderSubtle, lineWidth: isFocused ? 1.5 : 1)
            )
            .shadow(
                color: isExpanded ? ZenShadow.sm.color : .clear,
                radius: ZenShadow.sm.radius,
                x: ZenShadow.sm.x,
                y: ZenShadow.sm.y
            )
        }
    }
}

#Preview("ZenAutocomplete") {
    struct AutocompletePreview: View {
        @State private var query = ""
        let items: [ZenAutocompleteItem] = [
            .init(id: "1", label: "United States"),
            .init(id: "2", label: "United Kingdom"),
            .init(id: "3", label: "Germany"),
            .init(id: "4", label: "France"),
            .init(id: "5", label: "Japan"),
        ]

        var body: some View {
            ZenAutocomplete(
                text: $query,
                placeholder: "Search countries...",
                label: "Country",
                items: items
            )
            .padding()
            .background(Color.zenBackground)
        }
    }

    return AutocompletePreview()
}
