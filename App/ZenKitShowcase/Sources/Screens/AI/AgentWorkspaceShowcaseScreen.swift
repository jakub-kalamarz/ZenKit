import SwiftUI
import ZenKit

struct AgentWorkspaceShowcaseScreen: View {
    @State private var draft = ""
    @State private var approvals: [String: String] = [:]
    @State private var feedback: [String: ZenAgentFeedback] = [:]
    @State private var submittedMessages: [ZenAgentMessage] = []

    var body: some View {
        ZenScreen(containerStyle: .static, navigationTitle: "Agent Workspace") {
            ZenAgentChat(
                messages: sampleMessages + submittedMessages,
                draft: $draft,
                approvalSelections: $approvals,
                feedbackSelections: $feedback,
                prompt: "Ask about the launch plan…",
                onSubmit: submitDraft,
                onAction: handleAction,
                onContextOpen: { _ in },
                onMessageAction: handleMessageAction
            )
        }
        .zenBackground()
    }

    private var sampleMessages: [ZenAgentMessage] {
        [
            .init(
                id: "user-1",
                role: .user,
                blocks: [.text("Prepare the launch recommendation for next week.")]
            ),
            .init(
                id: "assistant-1",
                role: .assistant,
                blocks: [
                    .research(.init(id: "research-1", summary: "Inventory is sufficient for a staged northern-region launch, provided the two outstanding supplier confirmations arrive this week.", sources: [.init(id: "source-1", title: "Regional demand forecast", host: "Forecast.csv"), .init(id: "source-2", title: "Supplier lead-time policy", host: "Operations.pdf")], followUps: ["Compare suppliers", "Show stock risk"])),
                    .reasoning(summary: "Reviewed the launch brief and current inventory.", detail: "Demand is strongest in the northern region, while two suppliers need confirmation."),
                    .toolCalls([.init(id: "tool-1", title: "Analyze inventory", detail: "12 SKUs checked", state: .completed)]),
                    .contexts([.init(id: "context-1", title: "Launch brief", excerpt: "Prioritize the northern region and validate supplier lead times before committing inventory.", sourceLabel: "PDF", metadata: "Launch Brief.pdf")]),
                    .recommendation(.init(id: "recommendation-1", title: "Recommended launch", detail: "Launch the core assortment in the northern region, then expand after supplier confirmation.", confidence: 0.88, alternatives: ["Nationwide launch", "Delay by one week"], actions: [.init(id: "alternatives", title: "Alternatives"), .init(id: "accept", title: "Accept", style: .primary)])),
                    .approval(.init(id: "approval-1", title: "How should the agent proceed?", options: [.init(id: "core", title: "Core launch", detail: "Northern region first"), .init(id: "full", title: "Full launch", detail: "All regions at once")], continueAction: .init(id: "continue", title: "Continue", style: .primary), skipAction: .init(id: "skip")))
                ],
                responseMetadata: .init(
                    sources: [
                        .init(id: "forecast", title: "Regional demand forecast", detail: "Northern-region demand outlook", label: "CSV"),
                        .init(id: "inventory", title: "Current inventory", detail: "12 SKUs checked", label: "Workspace", isInteractive: false),
                    ],
                    followUps: ["Compare suppliers", "Show stock risk"]
                )
            )
        ]
    }

    private func submitDraft() {
        let message = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        submittedMessages.append(.init(id: UUID().uuidString, role: .user, blocks: [.text(message)]))
        draft = ""
    }

    private func handleAction(_ actionID: String) {
        submittedMessages.append(.init(id: UUID().uuidString, role: .assistant, blocks: [.text("Action \(actionID) was handed to the host app.")]))
    }

    private func handleMessageAction(_ messageID: String, _ action: ZenAgentMessageAction) {
        if case .followUp(let prompt) = action {
            draft = prompt
            submitDraft()
        }
    }
}
