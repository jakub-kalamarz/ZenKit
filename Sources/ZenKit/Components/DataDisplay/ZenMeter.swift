import SwiftUI

public struct ZenMeter: View {
    private let value: Double
    private let total: Double
    private let label: String?
    private let showValue: Bool
    private let tint: Color

    public init(
        value: Double,
        total: Double = 1.0,
        label: String? = nil,
        showValue: Bool = true,
        tint: Color = .zenPrimary
    ) {
        self.value = value
        self.total = total
        self.label = label
        self.showValue = showValue
        self.tint = tint
    }

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return min(max(value / total, 0), 1)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            if label != nil || showValue {
                HStack {
                    if let label {
                        Text(label)
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                    Spacer()
                    if showValue {
                        Text("\(Int(value))/\(Int(total))")
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.zenSurfaceMuted)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(meterColor)
                        .frame(width: geometry.size.width * fraction, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private var meterColor: Color {
        if fraction > 0.9 {
            return .zenCritical
        } else if fraction > 0.75 {
            return .zenWarning
        }
        return tint
    }
}

#Preview("ZenMeter") {
    VStack(spacing: ZenSpacing.large) {
        ZenMeter(value: 42, total: 100, label: "API Requests")
        ZenMeter(value: 80, total: 100, label: "Storage")
        ZenMeter(value: 95, total: 100, label: "Bandwidth")
        ZenMeter(value: 0.6, label: "Progress", showValue: false)
    }
    .padding()
    .background(Color.zenBackground)
}
