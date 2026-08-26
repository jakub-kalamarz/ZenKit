import SwiftUI

public struct ZenAgentChat<Attachment: View>: View {
    private let messages: [ZenAgentMessage]
    @Binding private var draft: String
    @Binding private var approvalSelections: [String: String]
    @Binding private var feedbackSelections: [String: ZenAgentFeedback]
    private let prompt: LocalizedStringKey
    private let isStreaming: Bool
    private let streamingStatus: String?
    private let emptyTitle: LocalizedStringKey
    private let emptyDescription: LocalizedStringKey
    private let errorMessage: String?
    private let onSubmit: () -> Void
    private let onAction: (String) -> Void
    private let onContextOpen: (String) -> Void
    private let onMessageAction: (String, ZenAgentMessageAction) -> Void
    private let attachment: (ZenAgentMessage) -> Attachment
    @State private var isAtBottom = true
    @State private var isKeyboardVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        messages: [ZenAgentMessage],
        draft: Binding<String>,
        approvalSelections: Binding<[String: String]> = .constant([:]),
        feedbackSelections: Binding<[String: ZenAgentFeedback]> = .constant([:]),
        prompt: LocalizedStringKey = "Message",
        isStreaming: Bool = false,
        streamingStatus: String? = nil,
        emptyTitle: LocalizedStringKey = "Start a conversation",
        emptyDescription: LocalizedStringKey = "Ask your agent to help with a task.",
        errorMessage: String? = nil,
        onSubmit: @escaping () -> Void,
        onAction: @escaping (String) -> Void = { _ in },
        onContextOpen: @escaping (String) -> Void = { _ in },
        onMessageAction: @escaping (String, ZenAgentMessageAction) -> Void = { _, _ in },
        @ViewBuilder attachment: @escaping (ZenAgentMessage) -> Attachment
    ) {
        self.messages = messages
        _draft = draft
        _approvalSelections = approvalSelections
        _feedbackSelections = feedbackSelections
        self.prompt = prompt
        self.isStreaming = isStreaming
        self.streamingStatus = streamingStatus
        self.emptyTitle = emptyTitle
        self.emptyDescription = emptyDescription
        self.errorMessage = errorMessage
        self.onSubmit = onSubmit
        self.onAction = onAction
        self.onContextOpen = onContextOpen
        self.onMessageAction = onMessageAction
        self.attachment = attachment
    }

    public var body: some View {
        chatContent
        .background(Color.zenBackground)
    }

    @ViewBuilder
    private var chatContent: some View {
        if #available(iOS 26, macOS 26, *) {
            ScrollViewReader { proxy in
                transcript(proxy: proxy)
                    .safeAreaBar(edge: .bottom) {
                        composer
                    }
            }
        } else {
            ScrollViewReader { proxy in
                transcript(proxy: proxy)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        composer
                            .padding(.top, 6)
                            .padding(.bottom, 10)
                    }
            }
        }
    }

    private func transcript(proxy: ScrollViewProxy) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: ZenSpacing.medium) {
                if messages.isEmpty && !isStreaming {
                    ContentUnavailableView {
                        Label { Text(emptyTitle) } icon: { ZenIcon(icon: .sparkles, size: 24) }
                    } description: {
                        Text(emptyDescription)
                    }
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(maxWidth: .infinity, minHeight: 260)
                }

                ForEach(messages) { message in
                    ZenAgentMessageView(
                        message: message,
                        approvalSelection: approvalSelection(for: message.id),
                        feedbackSelection: feedbackSelection(for: message.id),
                        onAction: onAction,
                        onContextOpen: onContextOpen,
                        onMessageAction: onMessageAction,
                        attachment: attachment
                    )
                    .id(message.id)
                }

                if isStreaming {
                    ZenAgentStreamingStatus(text: streamingStatus)
                }

                if let errorMessage {
                    ZenStatusBanner(tone: .critical, message: LocalizedStringKey(errorMessage))
                }

                Color.clear
                    .frame(height: 1)
                    .id("zen-agent-chat-bottom")
                    .onAppear { isAtBottom = true }
                    .onDisappear { isAtBottom = false }
            }
            .padding(ZenSpacing.medium)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottomTrailing) {
            if !isAtBottom {
                Button(action: { scrollToBottom(proxy) }) { ZenIcon(icon: .arrowDown, size: 16) }
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay { Circle().strokeBorder(Color.zenBorder, lineWidth: 1) }
                    .padding(ZenSpacing.medium)
                    .accessibilityLabel("Jump to latest message")
            }
        }
        .onChange(of: messages.last?.id) { _, _ in scrollToBottom(proxy) }
        .onChange(of: messages.last?.blocks) { _, _ in
            guard isStreaming, isAtBottom else { return }
            scrollToBottom(proxy, animated: false)
        }
    }

    private var composer: some View {
        ZenInputBar(
            text: $draft,
            prompt: prompt,
            isLoading: isStreaming,
            lineLimit: 1...4,
            appearance: .glass,
            onSubmit: onSubmit
        )
            // The capsule swells toward the screen edges while the keyboard is up,
            // matching the app's other input bars.
            .padding(.horizontal, isKeyboardVisible ? ZenSpacing.small : 21)
            .padding(.bottom, ZenSpacing.small)
            .animation(
                reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7),
                value: isKeyboardVisible
            )
            .observeKeyboardVisibility($isKeyboardVisible)
    }

    private func approvalSelection(for messageID: String) -> Binding<String?> {
        Binding(
            get: { approvalSelections[messageID] },
            set: { selection in approvalSelections[messageID] = selection }
        )
    }

    private func feedbackSelection(for messageID: String) -> Binding<ZenAgentFeedback?> {
        Binding(
            get: { feedbackSelections[messageID] },
            set: { selection in feedbackSelections[messageID] = selection }
        )
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo("zen-agent-chat-bottom", anchor: .bottom) }
        } else {
            proxy.scrollTo("zen-agent-chat-bottom", anchor: .bottom)
        }
    }
}

public extension ZenAgentChat where Attachment == EmptyView {
    init(
        messages: [ZenAgentMessage],
        draft: Binding<String>,
        approvalSelections: Binding<[String: String]> = .constant([:]),
        feedbackSelections: Binding<[String: ZenAgentFeedback]> = .constant([:]),
        prompt: LocalizedStringKey = "Message",
        isStreaming: Bool = false,
        streamingStatus: String? = nil,
        emptyTitle: LocalizedStringKey = "Start a conversation",
        emptyDescription: LocalizedStringKey = "Ask your agent to help with a task.",
        errorMessage: String? = nil,
        onSubmit: @escaping () -> Void,
        onAction: @escaping (String) -> Void = { _ in },
        onContextOpen: @escaping (String) -> Void = { _ in },
        onMessageAction: @escaping (String, ZenAgentMessageAction) -> Void = { _, _ in }
    ) {
        self.init(
            messages: messages,
            draft: draft,
            approvalSelections: approvalSelections,
            feedbackSelections: feedbackSelections,
            prompt: prompt,
            isStreaming: isStreaming,
            streamingStatus: streamingStatus,
            emptyTitle: emptyTitle,
            emptyDescription: emptyDescription,
            errorMessage: errorMessage,
            onSubmit: onSubmit,
            onAction: onAction,
            onContextOpen: onContextOpen,
            onMessageAction: onMessageAction
        ) { _ in
            EmptyView()
        }
    }
}

private struct ZenAgentMessageView<Attachment: View>: View {
    let message: ZenAgentMessage
    @Binding var approvalSelection: String?
    @Binding var feedbackSelection: ZenAgentFeedback?
    let onAction: (String) -> Void
    let onContextOpen: (String) -> Void
    let onMessageAction: (String, ZenAgentMessageAction) -> Void
    let attachment: (ZenAgentMessage) -> Attachment

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: ZenSpacing.small) {
                ForEach(Array(message.blocks.enumerated()), id: \.offset) { _, block in
                    blockView(block)
                }
                attachment(message)
                if let metadata = message.responseMetadata {
                    ZenAgentResponseFooter(
                        metadata: metadata,
                        feedback: $feedbackSelection,
                        onAction: { onMessageAction(message.id, $0) }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    @ViewBuilder private func blockView(_ block: ZenAgentMessageBlock) -> some View {
        switch block {
        case .text(let text):
            if message.role == .user {
                Text(text)
                    .font(.zenBody)
                    .foregroundStyle(Color.zenTextPrimary)
                    .textSelection(.enabled)
                    .padding(.horizontal, ZenSpacing.small + 2)
                    .padding(.vertical, ZenSpacing.xSmall + 2)
                    .background(Color.zenSurfaceMuted, in: RoundedRectangle(cornerRadius: ZenRadius.large, style: .continuous))
            } else {
                // Assistant replies are Markdown and sit directly on the canvas —
                // no bubble, and no clip shape that would shave the glyph edges.
                ZenMarkdownText(text)
                    .textSelection(.enabled)
            }
        case .research(let answer):
            ZenAgentResearchAnswerCard(answer: answer, onFollowUp: onAction)
        case .reasoning(let summary, let detail):
            DisclosureGroup(summary) {
                if let detail { Text(detail).font(.zenGroup).foregroundStyle(Color.zenTextMuted).padding(.top, ZenSpacing.xSmall) }
            }
            .font(.zenGroup)
            .foregroundStyle(Color.zenTextMuted)
        case .toolCalls(let calls):
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) { ForEach(calls) { ZenAgentToolChip(toolCall: $0) } }
        case .contexts(let contexts):
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) { ForEach(contexts) { ZenAgentContextCard(item: $0, onOpen: onContextOpen) } }
        case .recommendation(let recommendation):
            ZenAgentRecommendationCard(recommendation: recommendation, onAction: onAction)
        case .approval(let approval):
            ZenAgentApprovalCard(approval: approval, selectedOptionID: $approvalSelection, onAction: onAction)
        }
    }
}

private struct ZenAgentStreamingStatus: View {
    let text: String?

    var body: some View {
        ZenThinkingIndicator(label: text ?? "Thinking…")
    }
}

private extension View {
    @ViewBuilder
    func observeKeyboardVisibility(_ isVisible: Binding<Bool>) -> some View {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        self
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isVisible.wrappedValue = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isVisible.wrappedValue = false
            }
        #else
        self
        #endif
    }
}
