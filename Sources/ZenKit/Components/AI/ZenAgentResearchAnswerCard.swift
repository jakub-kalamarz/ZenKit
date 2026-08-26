import SwiftUI

public struct ZenAgentResearchAnswerCard: View {
    public let answer: ZenAgentResearchAnswer
    private let onFollowUp: (String) -> Void

    public init(answer: ZenAgentResearchAnswer, onFollowUp: @escaping (String) -> Void = { _ in }) {
        self.answer = answer
        self.onFollowUp = onFollowUp
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.medium) {
            Text(answer.summary)
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
                .textSelection(.enabled)

            if !answer.sources.isEmpty {
                VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                    Text("Sources")
                        .font(.zen(.group, weight: .semibold))
                        .foregroundStyle(Color.zenTextMuted)
                    ForEach(answer.sources) { source in
                        HStack(spacing: ZenSpacing.xSmall) {
                            ZenIcon(icon: .link, size: 11)
                                .foregroundStyle(Color.zenTextMuted)
                            Text(source.title)
                                .font(.zenGroup)
                                .foregroundStyle(Color.zenTextPrimary)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                            Text(source.host)
                                .font(.zenGroup)
                                .foregroundStyle(Color.zenTextMuted)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            if !answer.followUps.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: ZenSpacing.xSmall) {
                        ForEach(answer.followUps, id: \.self) { followUp in
                            Button(followUp, action: { onFollowUp(followUp) })
                                .buttonStyle(.plain)
                                .font(.zenGroup)
                                .foregroundStyle(Color.zenPrimary)
                                .padding(.horizontal, ZenSpacing.small)
                                .frame(minHeight: 36)
                                .background(Color.zenPrimary.opacity(0.1))
                                .clipShape(.capsule)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .accessibilityElement(children: .contain)
    }
}
