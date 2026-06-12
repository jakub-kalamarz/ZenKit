import SwiftUI

public struct ZenComboboxOption: Identifiable, Sendable, Hashable {
    public let id: String
    public let label: String
    public let icon: String?

    public init(id: String, label: String, icon: String? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
    }
}

public struct ZenCombobox: View {
    @Binding private var selection: Set<String>
    private let options: [ZenComboboxOption]
    private let placeholder: String
    private let label: String?
    @State private var searchText = ""
    @State private var isExpanded = false
    @FocusState private var isFocused: Bool

    public init(
        selection: Binding<Set<String>>,
        options: [ZenComboboxOption],
        placeholder: String = "Select...",
        label: String? = nil
    ) {
        self._selection = selection
        self.options = options
        self.placeholder = placeholder
        self.label = label
    }

    private var filteredOptions: [ZenComboboxOption] {
        guard !searchText.isEmpty else { return options }
        return options.filter { $0.label.localizedCaseInsensitiveContains(searchText) }
    }

    private var selectedOptions: [ZenComboboxOption] {
        options.filter { selection.contains($0.id) }
    }

    public var body: some View {
        #if DEBUG
        #endif
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                ZenLabel(label)
                    .padding(.bottom, ZenSpacing.xSmall)
            }

            VStack(alignment: .leading, spacing: 0) {
                triggerArea

                if isExpanded {
                    Divider()
                        .foregroundStyle(Color.zenBorderSubtle)

                    optionsList
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

    private var triggerArea: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if !selectedOptions.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(selectedOptions) { option in
                        ZenBadge(LocalizedStringKey(option.label)) {
                            selection.remove(option.id)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
            }

            HStack(spacing: 0) {
                TextField(selection.isEmpty ? placeholder : "Search...", text: $searchText)
                    .font(.zenIntro)
                    .foregroundStyle(Color.zenTextPrimary)
                    .focused($isFocused)
                    .onChange(of: isFocused) { focused in
                        withAnimation(.easeOut(duration: 0.15)) {
                            if focused { isExpanded = true }
                        }
                    }

                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        if isExpanded {
                            isExpanded = false
                            isFocused = false
                            searchText = ""
                        } else {
                            isExpanded = true
                            isFocused = true
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.zenTextMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .frame(minHeight: ZenTheme.current.resolvedMetrics.controlHeight)
        }
    }

    private var optionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if filteredOptions.isEmpty {
                    Text("No results")
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, ZenSpacing.small)
                } else {
                    ForEach(filteredOptions) { option in
                        Button {
                            toggleSelection(option)
                        } label: {
                            HStack(spacing: ZenSpacing.small) {
                                ZenIcon(
                                    source: .system(selection.contains(option.id) ? "checkmark.square.fill" : "square"),
                                    size: 16
                                )
                                .foregroundStyle(selection.contains(option.id) ? Color.zenPrimary : Color.zenTextMuted)

                                if let icon = option.icon {
                                    Image(systemName: icon)
                                        .font(.zenBody2)
                                        .foregroundStyle(Color.zenTextMuted)
                                }

                                Text(option.label)
                                    .font(.zenBody)
                                    .foregroundStyle(Color.zenTextPrimary)

                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, ZenSpacing.small)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxHeight: 200)
    }

    private func toggleSelection(_ option: ZenComboboxOption) {
        if selection.contains(option.id) {
            selection.remove(option.id)
        } else {
            selection.insert(option.id)
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

#Preview("ZenCombobox") {
    struct ComboboxPreview: View {
        @State private var selection: Set<String> = ["swift"]

        let options: [ZenComboboxOption] = [
            .init(id: "swift", label: "Swift", icon: "swift"),
            .init(id: "python", label: "Python"),
            .init(id: "rust", label: "Rust"),
            .init(id: "typescript", label: "TypeScript"),
            .init(id: "go", label: "Go"),
            .init(id: "kotlin", label: "Kotlin"),
        ]

        var body: some View {
            ZenCombobox(
                selection: $selection,
                options: options,
                placeholder: "Select languages...",
                label: "Languages"
            )
            .padding()
            .background(Color.zenBackground)
        }
    }

    return ComboboxPreview()
}
