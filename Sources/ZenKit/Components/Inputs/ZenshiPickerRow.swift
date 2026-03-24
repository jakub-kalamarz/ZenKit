import SwiftUI

public struct ZenPickerRow<Option: Hashable & Sendable, OptionLabel: View>: View {
    private let title: String
    private let subtitle: String?
    private let leadingIconSystemName: String?
    private let iconColor: Color?
    @Binding private var selection: Option
    private let options: [Option]
    private let optionLabel: (Option) -> OptionLabel

    public init(
        title: String,
        subtitle: String? = nil,
        leadingIconSystemName: String? = nil,
        iconColor: Color? = nil,
        selection: Binding<Option>,
        options: [Option],
        @ViewBuilder optionLabel: @escaping (Option) -> OptionLabel
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIconSystemName = leadingIconSystemName
        self.iconColor = iconColor
        _selection = selection
        self.options = options
        self.optionLabel = optionLabel
    }

    public var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    optionLabel(option)
                }
            }
        } label: {
            ZenSettingRow(
                title: title,
                subtitle: subtitle,
                leadingIconSystemName: leadingIconSystemName,
                iconColor: iconColor
            ) {
                HStack(spacing: ZenSpacing.xSmall) {
                    optionLabel(selection)
                    ZenIcon(systemName: "chevron.up.chevron.down", size: 11)
                }
            }
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var language = "English"
        let options = ["English", "Polish", "German"]

        var body: some View {
            ZenCard {
                ZenPickerRow(
                    title: "Language",
                    subtitle: "Used for notifications",
                    leadingIconSystemName: "globe",
                    selection: $language,
                    options: options
                ) { option in
                    Text(option)
                }
            }
            .padding()
            .background(Color.zenBackground)
        }
    }

    return PreviewContainer()
}
