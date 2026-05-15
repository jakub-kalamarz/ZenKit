import SwiftUI

public struct ZenWeekStrip: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Environment(\.calendar) private var calendar

    @Binding private var selection: Date
    private let range: ClosedRange<Date>
    @Namespace private var selectionAnimation

    public init(selection: Binding<Date>, in range: ClosedRange<Date>) {
        self._selection = selection
        self.range = range
    }

    public var body: some View {
        let theme = ZenTheme.current
        let controlCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let cellCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: controlCornerRadius)

        if #available(iOS 17, macOS 14, *) {
            modernWeekStrip(
                controlCornerRadius: controlCornerRadius,
                cellCornerRadius: cellCornerRadius
            )
        } else {
            fallbackWeekStrip(
                controlCornerRadius: controlCornerRadius,
                cellCornerRadius: cellCornerRadius
            )
        }
    }

    @available(iOS 17, macOS 14, *)
    private func modernWeekStrip(controlCornerRadius: CGFloat, cellCornerRadius: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(allWeeks, id: \.self) { week in
                        weekRow(week, cellCornerRadius: cellCornerRadius)
                            .id(week)
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .scrollTargetBehavior(.viewAligned)
            .onAppear {
                proxy.scrollTo(weekContaining(selection), anchor: .center)
            }
            .onChange(of: selection) { newValue in
                withAnimation(selectionAnimationStyle) {
                    proxy.scrollTo(weekContaining(newValue), anchor: .center)
                }
            }
        }
        .padding(ZenSpacing.xSmall)
        .contentShape(RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous))
    }

    private func fallbackWeekStrip(controlCornerRadius: CGFloat, cellCornerRadius: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(allWeeks, id: \.self) { week in
                        weekRow(week, cellCornerRadius: cellCornerRadius)
                            .id(week)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(weekContaining(selection), anchor: .center)
            }
            .onChange(of: selection) { newValue in
                withAnimation(selectionAnimationStyle) {
                    proxy.scrollTo(weekContaining(newValue), anchor: .center)
                }
            }
        }
        .padding(ZenSpacing.xSmall)
        .contentShape(RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous))
    }

    // MARK: - Week row

    private func weekRow(_ dates: [Date], cellCornerRadius: CGFloat) -> some View {
        HStack(spacing: ZenSpacing.xSmall) {
            ForEach(dates, id: \.self) { date in
                dayCell(date, cornerRadius: cellCornerRadius)
            }
        }
        .padding(.horizontal, ZenSpacing.xSmall)
    }

    // MARK: - Day cell

    private func dayCell(_ date: Date, cornerRadius: CGFloat) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selection)
        let isInRange = date >= calendar.startOfDay(for: range.lowerBound)
            && date <= calendar.startOfDay(for: range.upperBound)
        let isToday = calendar.isDateInToday(date)

        return Button {
            guard !isSelected else { return }
            withAnimation(selectionAnimationStyle) {
                selection = date
            }
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
                if isSelected {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.zenPrimary)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .matchedGeometryEffect(id: "week-strip-selection", in: selectionAnimation)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.zenSurface)
                }
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
        .disabled(!isInRange)
        .opacity(isInRange ? 1 : 0.35)
        .accessibilityLabel(accessibilityLabel(for: date))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Date helpers

    private var mondayCalendar: Calendar {
        var cal = calendar
        cal.firstWeekday = 2
        return cal
    }

    private var allWeeks: [[Date]] {
        let cal = mondayCalendar
        let rangeStart = cal.startOfDay(for: range.lowerBound)
        let rangeEnd = cal.startOfDay(for: range.upperBound)

        guard let firstMonday = cal.dateInterval(of: .weekOfYear, for: rangeStart)?.start,
              let lastWeekInterval = cal.dateInterval(of: .weekOfYear, for: rangeEnd)
        else { return [] }

        let lastMonday = lastWeekInterval.start
        var weeks: [[Date]] = []
        var current = firstMonday

        while current <= lastMonday {
            let week = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: current) }
            if week.count == 7 { weeks.append(week) }
            guard let next = cal.date(byAdding: .weekOfYear, value: 1, to: current) else { break }
            current = next
        }

        return weeks
    }

    private func weekContaining(_ date: Date) -> [Date]? {
        let cal = mondayCalendar
        let dayStart = cal.startOfDay(for: date)
        return allWeeks.first { week in
            week.contains { cal.isDate($0, inSameDayAs: dayStart) }
        }
    }

    private func weekdaySymbol(for date: Date) -> String {
        let symbols = calendar.shortWeekdaySymbols
        let weekday = calendar.component(.weekday, from: date)
        return symbols[weekday - 1].uppercased()
    }

    private func accessibilityLabel(for date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    // MARK: - Animation

    private var selectionAnimationStyle: Animation {
        if reduceMotion || ZenTheme.current.motion == .reduced {
            return .easeInOut(duration: 0.18)
        }
        return .spring(response: 0.28, dampingFraction: 0.84)
    }
}

// MARK: - Convenience init (no range limit)

public extension ZenWeekStrip {
    init(selection: Binding<Date>) {
        let cal = Calendar.current
        let start = cal.date(byAdding: .year, value: -1, to: .now) ?? .distantPast
        let end = cal.date(byAdding: .year, value: 1, to: .now) ?? .distantFuture
        self.init(selection: selection, in: start...end)
    }
}

// MARK: - Preview

private struct ZenWeekStripPreview: View {
    @State private var date = Date()

    var body: some View {
        let start = Calendar.current.date(byAdding: .day, value: -30, to: .now)!
        let end = Calendar.current.date(byAdding: .day, value: 30, to: .now)!
        let range = start...end

        VStack(spacing: ZenSpacing.large) {
            ZenWeekStrip(selection: $date, in: range)

            Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
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
