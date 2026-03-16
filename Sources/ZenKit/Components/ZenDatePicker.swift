import SwiftUI

public struct ZenDatePicker: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    @Binding private var selection: Date
    private let displayedComponents: DatePickerComponents

    public init(_ title: String, selection: Binding<Date>, displayedComponents: DatePickerComponents = .date) {
        self.title = title
        _selection = selection
        self.displayedComponents = displayedComponents
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(spacing: ZenSpacing.small) {
            Text(title)
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextPrimary)

            Spacer(minLength: ZenSpacing.small)

            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(Color.zenPrimary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, ZenSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct ZenDatePickerPreview: View {
    @State private var date = Date()
    @State private var dateTime = Date()

    var body: some View {
        VStack(spacing: ZenSpacing.small) {
            ZenDatePicker("Start date", selection: $date, displayedComponents: .date)
            ZenDatePicker("Reminder", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenDatePickerPreview()
}
