import SwiftUI

public struct ZenAgentApprovalCard: View {
    public let approval: ZenAgentApproval
    @Binding private var selectedOptionID: String?
    private let onAction: (String) -> Void

    public init(approval: ZenAgentApproval, selectedOptionID: Binding<String?>, onAction: @escaping (String) -> Void) {
        self.approval = approval
        _selectedOptionID = selectedOptionID
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text(approval.title)
                .font(.zen(.body, weight: .semibold))
                .foregroundStyle(Color.zenTextPrimary)
            ForEach(approval.options) { option in
                Button(action: { selectedOptionID = option.id }) {
                    HStack(spacing: ZenSpacing.small) {
                        Image(systemName: selectedOptionID == option.id ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selectedOptionID == option.id ? Color.zenPrimary : Color.zenTextMuted)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title).font(.zen(.group, weight: .semibold))
                            if let detail = option.detail { Text(detail).font(.zenGroup).foregroundStyle(Color.zenTextMuted) }
                        }
                        Spacer(minLength: 0)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedOptionID == option.id ? .isSelected : [])
            }
            HStack(spacing: ZenSpacing.small) {
                if let skipAction = approval.skipAction { actionButton(skipAction) }
                Spacer(minLength: 0)
                actionButton(approval.continueAction)
            }
        }
    }

    @ViewBuilder private func actionButton(_ action: ZenAgentAction) -> some View {
        ZenButton(LocalizedStringKey(action.title), variant: action.style == .primary ? .default : .outline) { onAction(action.id) }
    }
}

public struct ZenAgentRecommendationCard: View {
    public let recommendation: ZenAgentRecommendation
    private let onAction: (String) -> Void

    public init(recommendation: ZenAgentRecommendation, onAction: @escaping (String) -> Void) {
        self.recommendation = recommendation
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            Text(recommendation.title).font(.zen(.body, weight: .semibold)).foregroundStyle(Color.zenTextPrimary)
            Text(recommendation.detail).font(.zenBody).foregroundStyle(Color.zenTextPrimary)
            ZenProgressBar(progress: min(max(recommendation.confidence, 0), 1))
            Text("\(Int(recommendation.confidence * 100))% confidence")
                .font(.zenGroup).foregroundStyle(Color.zenTextMuted)
            if !recommendation.alternatives.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Other options").font(.zen(.group, weight: .semibold))
                    ForEach(recommendation.alternatives, id: \.self) { Text($0).font(.zenGroup).foregroundStyle(Color.zenTextMuted) }
                }
            }
            HStack(spacing: ZenSpacing.small) {
                ForEach(recommendation.actions) { action in
                    ZenButton(LocalizedStringKey(action.title), variant: action.style == .primary ? .default : .outline) { onAction(action.id) }
                }
            }
        }
    }
}

public struct ZenAgentContextCard: View {
    public let item: ZenAgentContextItem
    private let onOpen: (String) -> Void

    public init(item: ZenAgentContextItem, onOpen: @escaping (String) -> Void) {
        self.item = item
        self.onOpen = onOpen
    }

    public var body: some View {
        Button(action: { onOpen(item.id) }) {
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                HStack {
                    Text(item.title).font(.zen(.group, weight: .semibold)).foregroundStyle(Color.zenTextPrimary)
                    Spacer(minLength: 0)
                    ZenIcon(icon: .arrowUpRight, size: 12).foregroundStyle(Color.zenTextMuted)
                }
                Text(item.excerpt).font(.zenGroup).foregroundStyle(Color.zenTextMuted).lineLimit(3)
                Text([item.sourceLabel, item.metadata].compactMap { $0 }.joined(separator: " · "))
                    .font(.zenGroup).foregroundStyle(Color.zenPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}
