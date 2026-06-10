import SwiftUI

public struct ZenMeter: View {
    private let value: Double
    private let min: Double
    private let max: Double
    private let label: String
    private let customValue: String?
    private let showValue: Bool
    private let tint: Color?

    public init(
        value: Double,
        min: Double = 0,
        max: Double = 100,
        label: String,
        customValue: String? = nil,
        showValue: Bool = true,
        tint: Color? = nil
    ) {
        self.value = value
        self.min = min
        self.max = max
        self.label = label
        self.customValue = customValue
        self.showValue = showValue
        self.tint = tint
    }

    private var fraction: Double {
        let range = max - min
        guard range > 0 else { return 0 }
        return Swift.min(Swift.max((value - min) / range, 0), 1)
    }

    private var percentageText: String {
        "\(Int((fraction * 100).rounded()))%"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            HStack {
                Text(label)
                    .font(.zen(.group))
                    .foregroundStyle(Color.zenTextMuted)

                Spacer(minLength: ZenSpacing.medium)

                if let customValue {
                    Text(customValue)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(Color.zenTextPrimary)
                        .monospacedDigit()
                } else if showValue {
                    Text(percentageText)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(Color.zenTextPrimary)
                        .monospacedDigit()
                }
            }

            ZenProgressBar(progress: fraction, tint: tint)
        }
    }
}

#Preview("ZenMeter") {
    VStack(spacing: ZenSpacing.large) {
        ZenMeter(value: 65, label: "Storage used")
        ZenMeter(value: 75, label: "API requests", customValue: "750 / 1,000")
        ZenMeter(value: 40, label: "Progress", showValue: false)
        ZenMeter(value: 100, label: "Quota reached")
        ZenMeter(value: 15, label: "Memory usage")
        ZenMeter(value: 80, label: "Upload progress", tint: .zenSuccess)
    }
    .padding()
    .background(Color.zenBackground)
}
