import SwiftUI
import Testing
@testable import ZenKit

struct ZenAgentComponentTests {
    @Test
    func agentModelsRetainStructuredConversationContent() {
        let action = ZenAgentAction(id: "accept", title: "Accept", style: .primary)
        let recommendation = ZenAgentRecommendation(id: "recommendation", title: "Best option", detail: "Use the verified supplier.", confidence: 0.92, actions: [action])
        let message = ZenAgentMessage(id: "message", role: .assistant, blocks: [.text("Here is a recommendation."), .recommendation(recommendation)])

        #expect(message.blocks.count == 2)
        #expect(recommendation.actions == [action])
    }

    @Test
    func researchAnswersKeepSourcesAndFollowUpsStructured() {
        let answer = ZenAgentResearchAnswer(
            id: "research",
            summary: "The launch is ready.",
            sources: [.init(id: "forecast", title: "Forecast", host: "forecast.csv")],
            followUps: ["Show the forecast"]
        )

        #expect(answer.sources.first?.host == "forecast.csv")
        #expect(answer.followUps == ["Show the forecast"])
    }

    @Test
    func agentComponentsComposeWithControlledState() {
        let approval = ZenAgentApproval(
            id: "approval",
            title: "Choose a plan",
            options: [.init(id: "core", title: "Core plan")],
            continueAction: .init(id: "continue", title: "Continue", style: .primary)
        )
        let chat = ZenAgentChat(
            messages: [.init(id: "assistant", role: .assistant, blocks: [.approval(approval)])],
            draft: .constant(""),
            approvalSelections: .constant([:]),
            onSubmit: {}
        )
        let task = ZenAgentTaskRow(task: .init(id: "task", title: "Read sources", state: .running, progress: 0.5))

        _ = chat
        _ = task
    }
}
