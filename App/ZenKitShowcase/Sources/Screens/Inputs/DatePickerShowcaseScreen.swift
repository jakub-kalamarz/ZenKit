import SwiftUI
import ZenKit

struct DatePickerShowcaseScreen: View {
    @State private var startDate = Date()
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var reminderTime = Date()
    @State private var meetingDateTime = Date()

    var body: some View {
        ShowcaseScreen(title: "Date Picker") {
            ZenCard(title: "Date Only", subtitle: "Select a calendar date") {
                VStack(spacing: ZenSpacing.small) {
                    ZenDatePicker("Start date", selection: $startDate)
                    ZenDatePicker("Due date", selection: $dueDate)
                }
            }

            ZenCard(title: "Date & Time", subtitle: "Select date with time") {
                VStack(spacing: ZenSpacing.small) {
                    ZenDatePicker("Reminder", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                    ZenDatePicker("Meeting", selection: $meetingDateTime, displayedComponents: [.date, .hourAndMinute])
                }
            }

            ZenCard(title: "Time Only", subtitle: "Select a time") {
                ZenDatePicker("Alarm time", selection: $reminderTime, displayedComponents: .hourAndMinute)
            }
        }
    }
}
