import SwiftUI

public struct ZenWeekStrip: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Environment(\.calendar) private var calendar

    @Binding private var selection: Date
    private let range: ClosedRange<Date>
    private let horizontalInset: CGFloat
    @Namespace private var selectionAnimation
    @State private var visibleDay: Date?
    @State private var containerWidth: CGFloat = 0

    public init(
        selection: Binding<Date>,
        in range: ClosedRange<Date>,
        horizontalInset: CGFloat = 0
    ) {
        self._selection = selection
        self.range = range
        self.horizontalInset = horizontalInset
    }

    public var body: some View {
        let theme = ZenTheme.current
        let controlCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let cellCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: controlCornerRadius)

        VStack(spacing: ZenSpacing.xSmall) {
            monthHeader

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
    }

    private static let minCellWidth: CGFloat = 56

    private var visibleDayCount: Int {
        let available = max(0, containerWidth - horizontalInset * 2)
        let count = Int((available + ZenSpacing.xSmall) / (Self.minCellWidth + ZenSpacing.xSmall))
        return max(5, count)
    }

    @available(iOS 17, macOS 14, *)
    private func modernWeekStrip(controlCornerRadius: CGFloat, cellCornerRadius: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: ZenSpacing.xSmall) {
                    ForEach(allDays, id: \.self) { date in
                        dayCell(date, cornerRadius: cellCornerRadius)
                            .id(date)
                            .containerRelativeFrame(
                                .horizontal,
                                count: visibleDayCount,
                                span: 1,
                                spacing: ZenSpacing.xSmall
                            )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $visibleDay)
            .onAppear {
                visibleDay = normalizedSelection
                proxy.scrollTo(normalizedSelection, anchor: .center)
            }
            .onChange(of: selection) { newValue in
                withAnimation(selectionAnimationStyle) {
                    visibleDay = normalized(date: newValue)
                    proxy.scrollTo(normalized(date: newValue), anchor: .center)
                }
            }
        }
        .background {
            GeometryReader { geo in
                Color.clear.preference(key: WidthPreferenceKey.self, value: geo.size.width)
            }
        }
        .onPreferenceChange(WidthPreferenceKey.self) { containerWidth = $0 }
        .padding(.top, ZenSpacing.xSmall)
        .padding(.bottom, ZenSpacing.small + ZenSpacing.xSmall)
        .padding(.horizontal, horizontalInset)
        .contentShape(RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous))
    }

    private func fallbackWeekStrip(controlCornerRadius: CGFloat, cellCornerRadius: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: ZenSpacing.xSmall) {
                    ForEach(allDays, id: \.self) { date in
                        dayCell(date, cornerRadius: cellCornerRadius)
                            .frame(width: 68)
                            .id(date)
                    }
                }
                .padding(.horizontal, horizontalInset)
            }
            .onAppear {
                visibleDay = normalizedSelection
                proxy.scrollTo(normalizedSelection, anchor: .center)
            }
            .onChange(of: selection) { newValue in
                withAnimation(selectionAnimationStyle) {
                    visibleDay = normalized(date: newValue)
                    proxy.scrollTo(normalized(date: newValue), anchor: .center)
                }
            }
        }
        .padding(.top, ZenSpacing.xSmall)
        .padding(.bottom, ZenSpacing.small + ZenSpacing.xSmall)
        .padding(.horizontal, horizontalInset)
        .contentShape(RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous))
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

    // MARK: - Month header

    private var monthHeader: some View {
        let label = monthYearLabel(for: visibleDay ?? normalizedSelection)

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

    // MARK: - Date helpers

    private var normalizedSelection: Date {
        normalized(date: selection)
    }

    private var allDays: [Date] {
        let cal = calendar
        let rangeStart = cal.startOfDay(for: range.lowerBound)
        let rangeEnd = cal.startOfDay(for: range.upperBound)

        var dates: [Date] = []
        var current = rangeStart

        while current <= rangeEnd {
            dates.append(current)
            guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return dates
    }

    private func normalized(date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func monthYearLabel(for date: Date) -> String {
        normalized(date: date).formatted(.dateTime.month(.wide).year())
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

// MARK: - Width preference

private struct WidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Convenience init (no range limit)

public extension ZenWeekStrip {
    init(selection: Binding<Date>, horizontalInset: CGFloat = 0) {
        let cal = Calendar.current
        let start = cal.date(byAdding: .year, value: -1, to: .now) ?? .distantPast
        let end = cal.date(byAdding: .year, value: 1, to: .now) ?? .distantFuture
        self.init(selection: selection, in: start...end, horizontalInset: horizontalInset)
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
