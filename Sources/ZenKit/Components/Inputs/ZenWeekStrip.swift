import SwiftUI

public struct ZenWeekStrip: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Environment(\.calendar) private var calendar

    private enum SelectionMode {
        case single(Binding<Date>)
        case multiple(Binding<Set<Date>>)
    }

    private let mode: SelectionMode
    private let range: ClosedRange<Date>
    private let horizontalInset: CGFloat
    @Namespace private var pill
    @State private var visibleWeekID: WeekID?
    @State private var multiAnchor: Date

    /// Single-date selection (one moving pill).
    public init(
        selection: Binding<Date>,
        in range: ClosedRange<Date>,
        horizontalInset: CGFloat = 0
    ) {
        self.mode = .single(selection)
        self.range = range
        self.horizontalInset = horizontalInset
        self._multiAnchor = State(initialValue: selection.wrappedValue)
    }

    /// Multi-date selection — each selected day is filled independently; tapping toggles.
    public init(
        selection: Binding<Set<Date>>,
        in range: ClosedRange<Date>,
        horizontalInset: CGFloat = 0
    ) {
        self.mode = .multiple(selection)
        self.range = range
        self.horizontalInset = horizontalInset
        self._multiAnchor = State(initialValue: selection.wrappedValue.min() ?? range.lowerBound)
    }

    public var body: some View {
        #if DEBUG
        #endif
        let theme = ZenTheme.current
        let controlRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let cellRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: controlRadius)
        let weeks = allWeeks

        VStack(spacing: ZenSpacing.xSmall) {
            monthLabel(weeks: weeks)

            pager(weeks: weeks, cellRadius: cellRadius)
                .padding(.top, ZenSpacing.xSmall)
                .padding(.bottom, ZenSpacing.small + ZenSpacing.xSmall)
                .padding(.horizontal, horizontalInset)
                .contentShape(RoundedRectangle(cornerRadius: controlRadius, style: .continuous))
        }
    }

    // MARK: - Selection helpers

    private var isMultiple: Bool {
        if case .multiple = mode { return true }
        return false
    }

    /// The date used to anchor the month label and initial scroll position.
    private var anchorDate: Date {
        switch mode {
        case .single(let binding): return binding.wrappedValue
        case .multiple: return multiAnchor
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        switch mode {
        case .single(let binding):
            return calendar.isDate(date, inSameDayAs: binding.wrappedValue)
        case .multiple(let binding):
            return binding.wrappedValue.contains { calendar.isDate($0, inSameDayAs: date) }
        }
    }

    private func selectDay(_ date: Date) {
        switch mode {
        case .single(let binding):
            guard !calendar.isDate(date, inSameDayAs: binding.wrappedValue) else { return }
            withAnimation(springAnimation) {
                binding.wrappedValue = date
            }
        case .multiple(let binding):
            let day = calendar.startOfDay(for: date)
            withAnimation(springAnimation) {
                if let existing = binding.wrappedValue.first(where: { calendar.isDate($0, inSameDayAs: day) }) {
                    binding.wrappedValue.remove(existing)
                } else {
                    binding.wrappedValue.insert(day)
                }
                multiAnchor = day
            }
        }
    }

    // MARK: - Month label

    private func monthLabel(weeks: [Week]) -> some View {
        let week = weeks.first { $0.id == visibleWeekID } ?? weeks.first { $0.days.contains { calendar.isDate($0, inSameDayAs: anchorDate) } }
        let label = week.map { monthRangeLabel(for: $0) } ?? anchorDate.formatted(.dateTime.month(.wide).year())

        return HStack {
            Text(label)
                .font(.zen(.body2, weight: .semibold))
                .foregroundStyle(Color.zenTextPrimary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: label)
            Spacer()
        }
        .padding(.horizontal, ZenSpacing.small + ZenSpacing.xSmall)
    }

    // MARK: - Pager

    private func pager(weeks: [Week], cellRadius: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(weeks) { week in
                    weekRow(week, cellRadius: cellRadius)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $visibleWeekID)
        .onAppear {
            visibleWeekID = weekID(for: anchorDate, in: weeks)
        }
        .onChange(of: anchorDate) { _, newValue in
            let targetID = weekID(for: newValue, in: weeks)
            guard targetID != visibleWeekID else { return }
            withAnimation(springAnimation) {
                visibleWeekID = targetID
            }
        }
    }

    // MARK: - Week row

    private func weekRow(_ week: Week, cellRadius: CGFloat) -> some View {
        HStack(spacing: ZenSpacing.xSmall) {
            ForEach(week.days, id: \.self) { date in
                dayCell(date, cornerRadius: cellRadius)
            }
        }
        .padding(.horizontal, ZenSpacing.xSmall)
    }

    // MARK: - Day cell

    private func dayCell(_ date: Date, cornerRadius: CGFloat) -> some View {
        let isSelected = isSelected(date)
        let isToday = calendar.isDateInToday(date)
        let isInRange = date >= calendar.startOfDay(for: range.lowerBound)
            && date <= calendar.startOfDay(for: range.upperBound)

        return Button {
            selectDay(date)
        } label: {
            VStack(spacing: 2) {
                Text(weekdaySymbol(for: date))
                    .font(.zen(.group, weight: .medium))
                    .foregroundStyle(isSelected ? Color.zenPrimaryForeground.opacity(0.8) : Color.zenTextMuted)

                Text("\(calendar.component(.day, from: date))")
                    .font(.zenStat)
                    .foregroundStyle(isSelected ? Color.zenPrimaryForeground : Color.zenTextPrimary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ZenSpacing.small)
            .background {
                selectionBackground(isSelected: isSelected, cornerRadius: cornerRadius)
            }
            .overlay {
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.zenPrimary.opacity(0.4), lineWidth: 1.5)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .zIndex(isSelected ? 1 : 0)
        .disabled(!isInRange)
        .opacity(isInRange ? 1 : 0.35)
        .accessibilityLabel(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    @ViewBuilder
    private func selectionBackground(isSelected: Bool, cornerRadius: CGFloat) -> some View {
        if isSelected {
            // A single moving pill only works with one selection; multi-select fills each cell.
            if isMultiple {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.zenPrimary)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.zenPrimary)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    .matchedGeometryEffect(id: "pill", in: pill)
            }
        } else {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.zenSurface)
        }
    }

    // MARK: - Week computation

    private typealias WeekID = [Date]

    private struct Week: Identifiable {
        let days: [Date]
        var id: WeekID { days }
    }

    private var mondayCalendar: Calendar {
        var cal = calendar
        cal.firstWeekday = 2
        return cal
    }

    private var allWeeks: [Week] {
        let cal = mondayCalendar
        let start = cal.startOfDay(for: range.lowerBound)
        let end = cal.startOfDay(for: range.upperBound)

        guard let firstMonday = cal.dateInterval(of: .weekOfYear, for: start)?.start,
              let lastInterval = cal.dateInterval(of: .weekOfYear, for: end)
        else { return [] }

        var weeks: [Week] = []
        var current = firstMonday

        while current <= lastInterval.start {
            let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: current) }
            if days.count == 7 { weeks.append(Week(days: days)) }
            guard let next = cal.date(byAdding: .weekOfYear, value: 1, to: current) else { break }
            current = next
        }
        return weeks
    }

    private func weekID(for date: Date, in weeks: [Week]) -> WeekID? {
        let day = calendar.startOfDay(for: date)
        return weeks.first { $0.days.contains { calendar.isDate($0, inSameDayAs: day) } }?.id
    }

    // MARK: - Month label helpers

    private func monthRangeLabel(for week: Week) -> String {
        guard let first = week.days.first, let last = week.days.last else { return "" }
        let m1 = calendar.component(.month, from: first)
        let m2 = calendar.component(.month, from: last)
        let y1 = calendar.component(.year, from: first)
        let y2 = calendar.component(.year, from: last)

        if m1 == m2 {
            return first.formatted(.dateTime.month(.wide).year())
        }
        if y1 == y2 {
            return "\(first.formatted(.dateTime.month(.wide))) – \(last.formatted(.dateTime.month(.wide).year()))"
        }
        return "\(first.formatted(.dateTime.month(.wide).year())) – \(last.formatted(.dateTime.month(.wide).year()))"
    }

    private func weekdaySymbol(for date: Date) -> String {
        let symbols = calendar.shortWeekdaySymbols
        let weekday = calendar.component(.weekday, from: date)
        return symbols[weekday - 1].uppercased()
    }

    // MARK: - Animation

    private var springAnimation: Animation {
        if reduceMotion || ZenTheme.current.motion == .reduced {
            return .easeInOut(duration: 0.18)
        }
        return .spring(response: 0.28, dampingFraction: 0.84)
    }
}

// MARK: - Convenience inits

public extension ZenWeekStrip {
    init(selection: Binding<Date>, horizontalInset: CGFloat = 0) {
        let cal = Calendar.current
        let start = cal.date(byAdding: .month, value: -2, to: .now) ?? .distantPast
        let end = cal.date(byAdding: .month, value: 2, to: .now) ?? .distantFuture
        self.init(selection: selection, in: start...end, horizontalInset: horizontalInset)
    }

    init(selection: Binding<Set<Date>>, horizontalInset: CGFloat = 0) {
        let cal = Calendar.current
        let start = cal.date(byAdding: .month, value: -2, to: .now) ?? .distantPast
        let end = cal.date(byAdding: .month, value: 2, to: .now) ?? .distantFuture
        self.init(selection: selection, in: start...end, horizontalInset: horizontalInset)
    }
}

// MARK: - Preview

private struct ZenWeekStripPreview: View {
    @State private var date = Date()
    @State private var dates: Set<Date> = []

    var body: some View {
        let start = Calendar.current.date(byAdding: .day, value: -30, to: .now)!
        let end = Calendar.current.date(byAdding: .day, value: 30, to: .now)!

        VStack(spacing: ZenSpacing.large) {
            ZenWeekStrip(selection: $date, in: start...end)

            Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextMuted)

            ZenWeekStrip(selection: $dates, in: start...end)

            Text("\(dates.count) selected")
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextMuted)
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenWeekStripPreview()
}
