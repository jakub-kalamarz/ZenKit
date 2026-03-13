import SwiftUI

public struct ZenSegmentedControl<Value: Hashable, Label: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String?
    @Binding private var selection: Value
    private let segments: [Value]
    private let disabledSegments: Set<Value>
    private let label: (Value, Bool) -> Label
    @Namespace private var selectionAnimation

    public init(
        title: String? = nil,
        selection: Binding<Value>,
        segments: [Value],
        disabledSegments: Set<Value> = [],
        @ViewBuilder label: @escaping (Value, Bool) -> Label
    ) {
        self.title = title
        self._selection = selection
        self.segments = segments
        self.disabledSegments = disabledSegments
        self.label = label
    }

    public var body: some View {
        let theme = ZenTheme.current
        let metrics = theme.resolvedMetrics
        let controlCornerRadius = theme.cornerStyle == .none ? 0 : max(ZenRadius.small, theme.resolvedCornerRadius - 4)
        let segmentCornerRadius = theme.cornerStyle == .none ? 0 : max(8, controlCornerRadius - 4)

        return VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if let title {
                Text(title)
                    .font(.zenCaption.weight(.semibold))
                    .foregroundStyle(Color.zenTextMuted)
            }

            HStack(spacing: ZenSpacing.xSmall) {
                ForEach(segments, id: \.self) { value in
                    segmentButton(
                        for: value,
                        metrics: metrics,
                        segmentCornerRadius: segmentCornerRadius
                    )
                }
            }
            .padding(4)
            .background(Color.zenSurface)
            .overlay(
                RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous)
                    .strokeBorder(Color.zenBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous))
        }
    }

    private func segmentButton(
        for value: Value,
        metrics: ZenResolvedMetrics,
        segmentCornerRadius: CGFloat
    ) -> some View {
        let isSelected = selection == value
        let isDisabled = disabledSegments.contains(value)

        return Button {
            guard selection != value else { return }

            withAnimation(selectionAnimationStyle) {
                selection = value
            }
        } label: {
            label(value, isSelected)
                .lineLimit(1)
                .font(.zenLabel)
                .foregroundStyle(isSelected ? Color.zenPrimaryForeground : (isDisabled ? Color.zenTextMuted.opacity(0.5) : Color.zenTextPrimary))
                .frame(maxWidth: .infinity, minHeight: metrics.controlHeightSmall)
                .padding(.horizontal, ZenSpacing.small)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: segmentCornerRadius, style: .continuous)
                            .fill(Color.zenPrimary)
                            .matchedGeometryEffect(id: "selected-segment", in: selectionAnimation)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: segmentCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var selectionAnimationStyle: Animation {
        if reduceMotion || ZenTheme.current.motion == .reduced {
            return .easeInOut(duration: 0.18)
        }

        return .spring(response: 0.28, dampingFraction: 0.84)
    }
}

public extension ZenSegmentedControl where Label == AnyView {
    init<IconView: View, LabelView: View>(
        title: String? = nil,
        selection: Binding<Value>,
        segments: [Value],
        disabledSegments: Set<Value> = [],
        @ViewBuilder icon: @escaping (Value) -> IconView,
        @ViewBuilder label: @escaping (Value, Bool) -> LabelView
    ) {
        self.init(title: title, selection: selection, segments: segments, disabledSegments: disabledSegments) { value, isSelected in
            AnyView(
                ViewThatFits {
                    HStack(spacing: 6) {
                        icon(value)
                        label(value, isSelected)
                    }
                    icon(value)
                }
            )
        }
    }
}

public extension ZenSegmentedControl where Value == String, Label == Text {
    init(
        title: String? = nil,
        selection: Binding<String>,
        segments: [String],
        disabledSegments: Set<String> = []
    ) {
        self.init(title: title, selection: selection, segments: segments, disabledSegments: disabledSegments) { value, _ in
            Text(value)
        }
    }
}

public extension ZenSegmentedControl where Value: RawRepresentable, Value.RawValue == String, Label == Text {
    init(
        title: String? = nil,
        selection: Binding<Value>,
        segments: [Value],
        disabledSegments: Set<Value> = []
    ) {
        self.init(title: title, selection: selection, segments: segments, disabledSegments: disabledSegments) { value, _ in
            Text(value.rawValue)
        }
    }
}

private struct ZenSegmentedControlPreview: View {
    private enum Segment: String, CaseIterable {
        case week = "7D"
        case month = "28D"
        case quarter = "3M"
        case year = "1Y"

        var systemImage: String {
            switch self {
            case .week: "calendar"
            case .month: "calendar.badge.clock"
            case .quarter: "chart.bar"
            case .year: "chart.line.uptrend.xyaxis"
            }
        }
    }

    @State private var selection: Segment = .quarter

    var body: some View {
        VStack(spacing: ZenSpacing.large) {
            ZenSegmentedControl(
                title: "Range",
                selection: $selection,
                segments: Segment.allCases
            )

            ZenSegmentedControl(
                title: "Icon + Label (ViewThatFits)",
                selection: $selection,
                segments: Segment.allCases,
                icon: { value in
                    Image(systemName: value.systemImage)
                        .font(.system(size: 12))
                },
                label: { value, _ in
                    Text(value.rawValue)
                }
            )
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenSegmentedControlPreview()
}
