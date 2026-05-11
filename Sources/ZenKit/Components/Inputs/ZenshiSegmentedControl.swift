import SwiftUI

public enum ZenSegmentedControlLabelLayout: Equatable, Sendable {
    case horizontal(spacing: CGFloat = 6)
    case vertical(spacing: CGFloat = 4)
}

public struct ZenSegmentedControl<Value: Hashable, Label: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @Environment(\.colorScheme) private var colorScheme

    private let title: LocalizedStringKey?
    @Binding private var selection: Value
    private let segments: [Value]
    private let disabledSegments: Set<Value>
    private let label: (Value, Bool) -> Label
    @Namespace private var selectionAnimation

    public init(
        title: LocalizedStringKey? = nil,
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
        let controlCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let segmentCornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: controlCornerRadius)

        return VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if let title {
                Text(title)
                    .font(.zen(.group, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: segmentCornerRadius, style: .continuous)
                    .fill(Color.zenSurface)
                    .shadow(color: selectedSegmentShadowColor, radius: 10, y: 3)
                    .overlay {
                        if colorScheme == .dark {
                            RoundedRectangle(cornerRadius: segmentCornerRadius, style: .continuous)
                                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                        }
                    }
                    .matchedGeometryEffect(id: selection, in: selectionAnimation, isSource: false)
                    .allowsHitTesting(false)

                HStack(spacing: ZenSpacing.xSmall) {
                    ForEach(segments, id: \.self) { value in
                        segmentButton(
                            for: value,
                            metrics: metrics,
                            segmentCornerRadius: segmentCornerRadius
                        )
                    }
                }
            }
            .padding(4)
            .background(Color.zenSurfaceMuted)
            .overlay(
                RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous)
                    .strokeBorder(Color.zenBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: controlCornerRadius, style: .continuous))
            .zenContainerCornerRadius(controlCornerRadius)
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
            segmentLabel(for: value, isSelected: isSelected, isDisabled: isDisabled)
                .frame(maxWidth: .infinity, minHeight: metrics.controlHeightSmall)
                .padding(.horizontal, ZenSpacing.small)
                .background(Color.clear.matchedGeometryEffect(id: value, in: selectionAnimation))
                .contentShape(RoundedRectangle(cornerRadius: segmentCornerRadius, style: .continuous))
        }
        .buttonStyle(ZenSegmentedControlButtonStyle())
        .disabled(isDisabled)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var selectionAnimationStyle: Animation {
        if reduceMotion || ZenTheme.current.motion == .reduced {
            return .easeInOut(duration: 0.18)
        }

        return .spring(response: 0.28, dampingFraction: 0.84)
    }

    private var selectedSegmentShadowColor: Color {
        if colorScheme == .dark {
            return .white.opacity(0.06)
        }
        return .black.opacity(0.06)
    }

    private func segmentLabel(for value: Value, isSelected: Bool, isDisabled: Bool) -> some View {
        label(value, isSelected)
            .lineLimit(1)
            .font(.zen(.body2, weight: isSelected ? .semibold : .medium))
            .foregroundStyle(foregroundColor(isSelected: isSelected, isDisabled: isDisabled))
            .multilineTextAlignment(.center)
    }

    private func foregroundColor(isSelected: Bool, isDisabled: Bool) -> Color {
        if isSelected {
            return .zenPrimary
        }

        return isDisabled ? Color.zenTextMuted.opacity(0.5) : Color.zenTextMuted
    }

}

private struct ZenSegmentedControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ZenSegmentedControl where Label == AnyView {
    init(
        title: String? = nil,
        selection: Binding<Value>,
        segments: [Value],
        disabledSegments: Set<Value> = [],
        layout: ZenSegmentedControlLabelLayout = .vertical(),
        icon: @escaping (Value) -> ZenIconSource,
        segmentTitle: @escaping (Value) -> String
    ) {
        self.init(title: title.map { LocalizedStringKey($0) }, selection: selection, segments: segments, disabledSegments: disabledSegments) { value, _ in
            AnyView(
                Group {
                    switch layout {
                    case .horizontal(let spacing):
                        HStack(spacing: spacing) {
                            ZenSegmentIcon(source: icon(value))
                            Text(LocalizedStringKey(segmentTitle(value)))
                        }
                    case .vertical(let spacing):
                        VStack(spacing: spacing) {
                            ZenSegmentIcon(source: icon(value))
                            Text(LocalizedStringKey(segmentTitle(value)))
                        }
                    }
                }
                .padding(.vertical, 4)
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
        self.init(title: title.map { LocalizedStringKey($0) }, selection: selection, segments: segments, disabledSegments: disabledSegments) { value, _ in
            Text(LocalizedStringKey(value))
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
        self.init(title: title.map { LocalizedStringKey($0) }, selection: selection, segments: segments, disabledSegments: disabledSegments) { value, _ in
            Text(LocalizedStringKey(value.rawValue))
        }
    }
}

private struct ZenSegmentIcon: View {
    let source: ZenIconSource

    var body: some View {
        switch source {
        case .asset(let name, let renderingMode):
            Image(name)
                .renderingMode(renderingMode.imageRenderingMode)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        case .system(let name):
            Image(systemName: name)
                .renderingMode(.template)
                .frame(width: 16, height: 16)
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
                title: "Horizontal Icon + Title",
                selection: $selection,
                segments: Segment.allCases,
                layout: .horizontal(),
                icon: { .system($0.systemImage) },
                segmentTitle: { $0.rawValue }
            )

            ZenSegmentedControl(
                title: "Vertical Icon + Title",
                selection: $selection,
                segments: Segment.allCases,
                layout: .vertical(),
                icon: { .system($0.systemImage) },
                segmentTitle: { $0.rawValue }
            )
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenSegmentedControlPreview()
}

#Preview("Dark") {
    ZenSegmentedControlPreview()
        .preferredColorScheme(.dark)
}
