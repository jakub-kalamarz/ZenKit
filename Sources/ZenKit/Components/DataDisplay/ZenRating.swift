import SwiftUI

public struct ZenRating: View {
    @Binding private var value: Int
    private let maximum: Int
    private let isInteractive: Bool

    public init(value: Binding<Int>, maximum: Int = 5) {
        _value = value
        self.maximum = maximum
        self.isInteractive = true
    }

    public init(value: Int, maximum: Int = 5) {
        _value = .constant(value)
        self.maximum = maximum
        self.isInteractive = false
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maximum, id: \.self) { i in
                if isInteractive {
                    Button {
                        value = i
                    } label: {
                        starIcon(for: i)
                    }
                    .buttonStyle(.plain)
                } else {
                    starIcon(for: i)
                }
            }
        }
    }

    @ViewBuilder
    private func starIcon(for i: Int) -> some View {
        if i <= value {
            ZenIcon(systemName: "star.fill", size: 20)
                .font(.system(size: 20))
                .foregroundStyle(Color.zenWarning)
        } else {
            ZenIcon(systemName: "star", size: 20)
                .font(.system(size: 20))
                .foregroundStyle(Color.zenBorder)
        }
    }
}

public struct ZenRatingRow: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    private let title: String
    @Binding private var value: Int
    private let maximum: Int

    public init(_ title: String, value: Binding<Int>, maximum: Int = 5) {
        self.title = title
        _value = value
        self.maximum = maximum
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        HStack(spacing: ZenSpacing.small) {
            Text(title)
                .font(.zenLabel)
                .foregroundStyle(Color.zenTextPrimary)

            Spacer(minLength: ZenSpacing.small)

            ZenRating(value: $value, maximum: maximum)
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

private struct ZenRatingPreview: View {
    @State private var interactiveRating = 3
    @State private var rowRating = 4

    var body: some View {
        VStack(spacing: ZenSpacing.medium) {
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                Text("Interactive Rating")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
                ZenRating(value: $interactiveRating)
            }

            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                Text("Display-only Rating")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
                ZenRating(value: 2)
            }

            ZenRatingRow("Overall Quality", value: $rowRating)
        }
        .padding()
        .background(Color.zenBackground)
    }
}

#Preview {
    ZenRatingPreview()
}
