import SwiftUI

public struct ZenAgentResponseFooter: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    public let metadata: ZenAgentResponseMetadata
    @Binding private var feedback: ZenAgentFeedback?
    private let onAction: (ZenAgentMessageAction) -> Void
    @State private var showsSources = false

    public init(
        metadata: ZenAgentResponseMetadata,
        feedback: Binding<ZenAgentFeedback?>,
        onAction: @escaping (ZenAgentMessageAction) -> Void
    ) {
        self.metadata = metadata
        _feedback = feedback
        self.onAction = onAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.small) {
            actionBar

            if showsSources, !metadata.sources.isEmpty {
                sourceList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if !metadata.followUps.isEmpty {
                followUps
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var actionBar: some View {
        HStack(spacing: 2) {
            if metadata.allowsCopy {
                actionButton("Copy response", icon: .docOnDoc) {
                    onAction(.copy)
                }
            }

            if metadata.allowsFeedback {
                actionButton("Helpful", icon: feedback == .positive ? .heartFill : .heart) {
                    setFeedback(feedback == .positive ? nil : .positive)
                }
                actionButton("Not helpful", icon: feedback == .negative ? .xmarkCircleFill : .xmarkCircle) {
                    setFeedback(feedback == .negative ? nil : .negative)
                }
            }

            if !metadata.sources.isEmpty {
                Button {
                    if accessibilityReduceMotion {
                        showsSources.toggle()
                    } else {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showsSources.toggle()
                        }
                    }
                } label: {
                    HStack(spacing: ZenSpacing.xSmall) {
                        ZenIcon(icon: .booksVertical, size: 12)
                        Text("\(metadata.sources.count) source\(metadata.sources.count == 1 ? "" : "s")")
                            .font(.zenGroup)
                    }
                    .foregroundStyle(Color.zenTextMuted)
                    .padding(.horizontal, ZenSpacing.xSmall)
                    .frame(minHeight: 32)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showsSources ? "Hide sources" : "Show sources")
                .accessibilityValue("\(metadata.sources.count)")
            }
        }
    }

    private var sourceList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(metadata.sources) { source in
                sourceRow(source)

                if source.id != metadata.sources.last?.id {
                    Divider().overlay(Color.zenBorderSubtle)
                }
            }
        }
        .padding(ZenSpacing.xSmall)
        .background(Color.zenSurfaceMuted)
        .clipShape(.rect(cornerRadius: ZenRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: ZenRadius.medium)
                .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
        }
    }

    @ViewBuilder
    private func sourceRow(_ source: ZenAgentSource) -> some View {
        let content = HStack(spacing: ZenSpacing.small) {
            ZenIcon(icon: .docText, size: 13)
                .foregroundStyle(Color.zenTextMuted)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(source.title)
                    .font(.zen(.group, weight: .semibold))
                    .foregroundStyle(Color.zenTextPrimary)
                    .lineLimit(2)
                if let detail = source.detail {
                    Text(detail)
                        .font(.zenGroup)
                        .foregroundStyle(Color.zenTextMuted)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: ZenSpacing.xSmall)

            if let label = source.label {
                Text(label)
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
                    .lineLimit(1)
            }

            if source.isInteractive {
                ZenIcon(icon: .chevronRight, size: 10, weight: .semibold)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(.rect)

        if source.isInteractive {
            Button(action: { onAction(.openSource(source.id)) }) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
                .accessibilityElement(children: .combine)
        }
    }

    private var followUps: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            Text("Follow-ups")
                .font(.zen(.group, weight: .semibold))
                .foregroundStyle(Color.zenTextMuted)

            ForEach(metadata.followUps, id: \.self) { followUp in
                Button(action: { onAction(.followUp(followUp)) }) {
                    HStack(spacing: ZenSpacing.small) {
                        ZenIcon(icon: .arrowTurnDownRight, size: 11)
                            .foregroundStyle(Color.zenTextMuted)
                        Text(followUp)
                            .font(.zenBody)
                            .foregroundStyle(Color.zenTextPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func actionButton(
        _ title: LocalizedStringKey,
        icon: HugeIcon,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label { Text(title) } icon: { ZenIcon(icon: icon, size: 14) }
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.zenTextMuted)
                .frame(width: 32, height: 32)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }

    private func setFeedback(_ selection: ZenAgentFeedback?) {
        feedback = selection
        onAction(.feedback(selection))
    }
}
