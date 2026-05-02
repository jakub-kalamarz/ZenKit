import SwiftUI

public enum ZenMultiSelectMode: Sendable {
    case immediate
    case deferred
}

struct ZenMultiSelectSummary: Equatable, Sendable {
    let labels: [String]
    let overflowCount: Int

    var displayText: String {
        guard labels.isEmpty == false else { return "" }
        guard overflowCount > 0 else { return labels.joined(separator: ", ") }
        return "\(labels.joined(separator: ", ")) +\(overflowCount)"
    }

    static func make<Option>(
        options: [Option],
        selection: Set<Option>,
        optionTitle: (Option) -> String,
        maxVisibleLabels: Int = 2
    ) -> ZenMultiSelectSummary where Option: Hashable {
        let selectedOptions = options.filter { selection.contains($0) }
        let labels = selectedOptions.prefix(maxVisibleLabels).map(optionTitle)
        let overflowCount = max(selectedOptions.count - labels.count, 0)

        return ZenMultiSelectSummary(labels: labels, overflowCount: overflowCount)
    }
}

public struct ZenMultiSelect<Option, OptionLabel: View, SummaryLabel: View>: View where Option: Hashable & Sendable {
    @State private var isPresented = false
    @State private var draftSelection: Set<Option>

    private let title: String
    private let placeholder: String
    @Binding private var selection: Set<Option>
    private let options: [Option]
    private let mode: ZenMultiSelectMode
    private let optionLabel: (Option) -> OptionLabel
    private let summaryLabel: ([Option]) -> SummaryLabel

    public init(
        title: String,
        placeholder: String = "Select options",
        selection: Binding<Set<Option>>,
        options: [Option],
        mode: ZenMultiSelectMode = .immediate,
        @ViewBuilder optionLabel: @escaping (Option) -> OptionLabel,
        @ViewBuilder summaryLabel: @escaping ([Option]) -> SummaryLabel
    ) {
        self.title = title
        self.placeholder = placeholder
        _selection = selection
        self.options = options
        self.mode = mode
        self.optionLabel = optionLabel
        self.summaryLabel = summaryLabel
        _draftSelection = State(initialValue: selection.wrappedValue)
    }

    public var body: some View {
        Button {
            preparePresentation()
            isPresented = true
        } label: {
            ZenSettingRow(title: title) {
                HStack(spacing: ZenSpacing.xSmall) {
                    summaryContent
                    ZenIcon(systemName: "chevron.up.chevron.down", size: 11)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isPresented) {
            sheetContent
                .frame(minWidth: 320, idealWidth: 360)
                .padding()
        }
        .onChange(of: selection) { newValue in
            guard isPresented == false else { return }
            draftSelection = newValue
        }
    }

    @ViewBuilder
    private var summaryContent: some View {
        let selectedOptions = orderedSelection(from: selection)

        if selectedOptions.isEmpty {
            Text(placeholder)
                .font(.zen(.body2, weight: .medium))
                .foregroundStyle(Color.zenTextMuted)
        } else {
            summaryLabel(selectedOptions)
                .lineLimit(1)
        }
    }

    private var sheetContent: some View {
        ZenSheetContainer(
            title: title,
            subtitle: mode == .deferred ? "Select options and apply changes." : "Changes are applied immediately."
        ) {
            VStack(spacing: ZenSpacing.small) {
                ForEach(options, id: \.self) { option in
                    optionRow(for: option)
                }
            }
        } footer: {
            HStack(spacing: ZenSpacing.small) {
                ZenButton("Clear", variant: .secondary) {
                    clearSelection()
                }

                if mode == .deferred {
                    ZenButton("Apply", fullWidth: true) {
                        applyDraft()
                    }
                } else {
                    ZenButton("Done", fullWidth: true) {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func optionRow(for option: Option) -> some View {
        let isSelected = activeSelection.contains(option)

        return Button {
            toggle(option)
        } label: {
            HStack(spacing: ZenSpacing.small) {
                optionLabel(option)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    ZenIcon(systemName: "checkmark", size: 12)
                        .foregroundStyle(Color.zenPrimary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, ZenSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.zenSurfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: ZenTheme.current.resolvedCornerRadius(for: .nestedControl)))
        }
        .buttonStyle(.plain)
    }

    private var activeSelection: Set<Option> {
        mode == .deferred ? draftSelection : selection
    }

    private func orderedSelection(from selection: Set<Option>) -> [Option] {
        options.filter { selection.contains($0) }
    }

    private func preparePresentation() {
        draftSelection = selection
    }

    private func toggle(_ option: Option) {
        switch mode {
        case .immediate:
            if selection.contains(option) {
                selection.remove(option)
            } else {
                selection.insert(option)
            }
        case .deferred:
            if draftSelection.contains(option) {
                draftSelection.remove(option)
            } else {
                draftSelection.insert(option)
            }
        }
    }

    private func clearSelection() {
        switch mode {
        case .immediate:
            selection.removeAll()
        case .deferred:
            draftSelection.removeAll()
        }
    }

    private func applyDraft() {
        selection = draftSelection
        isPresented = false
    }
}

public extension ZenMultiSelect where Option == String, SummaryLabel == Text {
    init(
        title: String,
        placeholder: String = "Select options",
        selection: Binding<Set<String>>,
        options: [String],
        mode: ZenMultiSelectMode = .immediate,
        @ViewBuilder optionLabel: @escaping (String) -> OptionLabel
    ) {
        self.init(
            title: title,
            placeholder: placeholder,
            selection: selection,
            options: options,
            mode: mode,
            optionLabel: optionLabel
        ) { selectedOptions in
            let summary = ZenMultiSelectSummary.make(
                options: options,
                selection: Set(selectedOptions),
                optionTitle: { $0 }
            )
            Text(summary.displayText)
        }
    }
}

public extension ZenMultiSelect where Option: RawRepresentable, Option.RawValue == String, SummaryLabel == Text {
    init(
        title: String,
        placeholder: String = "Select options",
        selection: Binding<Set<Option>>,
        options: [Option],
        mode: ZenMultiSelectMode = .immediate,
        @ViewBuilder optionLabel: @escaping (Option) -> OptionLabel
    ) {
        self.init(
            title: title,
            placeholder: placeholder,
            selection: selection,
            options: options,
            mode: mode,
            optionLabel: optionLabel
        ) { selectedOptions in
            let summary = ZenMultiSelectSummary.make(
                options: options,
                selection: Set(selectedOptions),
                optionTitle: \.rawValue
            )
            Text(summary.displayText)
        }
    }
}

#Preview {
    enum Column: String, CaseIterable, Hashable, Sendable {
        case name = "Name"
        case owner = "Owner"
        case status = "Status"
        case updatedAt = "Updated"
    }

    struct PreviewContainer: View {
        @State private var immediateSelection: Set<Column> = [.name, .status]
        @State private var deferredSelection: Set<Column> = [.owner]

        var body: some View {
            VStack(spacing: ZenSpacing.medium) {
                ZenMultiSelect(
                    title: "Columns",
                    selection: $immediateSelection,
                    options: Column.allCases
                ) { option in
                    Text(option.rawValue)
                }

                ZenMultiSelect(
                    title: "Filters",
                    selection: $deferredSelection,
                    options: Column.allCases,
                    mode: .deferred
                ) { option in
                    Text(option.rawValue)
                }
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return PreviewContainer()
}
