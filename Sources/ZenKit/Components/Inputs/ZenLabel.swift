import SwiftUI

public struct ZenLabel: View {
    private let text: String
    private let isOptional: Bool
    private let tooltip: String?
    private let isRequired: Bool

    public init(
        _ text: String,
        isOptional: Bool = false,
        isRequired: Bool = false,
        tooltip: String? = nil
    ) {
        self.text = text
        self.isOptional = isOptional
        self.isRequired = isRequired
        self.tooltip = tooltip
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextPrimary)

            if isRequired {
                Text("*")
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenCritical)
            }

            if isOptional {
                Text("(optional)")
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextMuted)
            }

            if let tooltip {
                ZenLabelTooltip(text: tooltip)
            }
        }
    }
}

private struct ZenLabelTooltip: View {
    let text: String
    @State private var isShowing = false

    var body: some View {
        Button {
            isShowing.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextMuted)
        }
        .buttonStyle(.plain)
        #if os(iOS)
        .popover(isPresented: $isShowing) {
            Text(text)
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextPrimary)
                .padding(ZenSpacing.small)
                .presentationCompactAdaptation(.popover)
        }
        #endif
    }
}

#Preview("ZenLabel") {
    VStack(alignment: .leading, spacing: ZenSpacing.medium) {
        ZenLabel("Email address")
        ZenLabel("Full name", isRequired: true)
        ZenLabel("Phone number", isOptional: true)
        ZenLabel("API Key", tooltip: "Find this in your dashboard settings")
    }
    .padding()
    .background(Color.zenBackground)
}
