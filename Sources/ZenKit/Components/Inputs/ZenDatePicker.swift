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
        let controlStyle = ZenControlSurfaceStyle.outline(theme: theme)

        HStack(spacing: ZenSpacing.small) {
            Text(title)
                .font(.zen(.body2, weight: .medium))
                .foregroundStyle(Color.zenTextPrimary)

            Spacer(minLength: ZenSpacing.small)

            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(Color.zenPrimary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, ZenSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: theme.resolvedMetrics.controlHeight, alignment: .leading)
        .background(controlStyle.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(controlStyle.borderColor, lineWidth: controlStyle.borderWidth)
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
