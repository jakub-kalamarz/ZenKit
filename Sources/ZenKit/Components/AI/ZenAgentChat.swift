import SwiftUI

public struct ZenAgentChat<Attachment: View>: View {
    private let messages: [ZenAgentMessage]
    @Binding private var draft: String
    @Binding private var approvalSelections: [String: String]
    private let prompt: LocalizedStringKey
    private let isStreaming: Bool
    private let streamingStatus: String?
    private let emptyTitle: LocalizedStringKey
    private let emptyDescription: LocalizedStringKey
    private let errorMessage: String?
    private let onSubmit: () -> Void
    private let onAction: (String) -> Void
    private let onContextOpen: (String) -> Void
    private let attachment: (ZenAgentMessage) -> Attachment
    @State private var isAtBottom = true

    public init(
        messages: [ZenAgentMessage],
        draft: Binding<String>,
        approvalSelections: Binding<[String: String]> = .constant([:]),
        prompt: LocalizedStringKey = "Message",
        isStreaming: Bool = false,
        streamingStatus: String? = nil,
        emptyTitle: LocalizedStringKey = "Start a conversation",
        emptyDescription: LocalizedStringKey = "Ask your agent to help with a task.",
        errorMessage: String? = nil,
        onSubmit: @escaping () -> Void,
        onAction: @escaping (String) -> Void = { _ in },
        onContextOpen: @escaping (String) -> Void = { _ in },
        @ViewBuilder attachment: @escaping (ZenAgentMessage) -> Attachment
    ) {
        self.messages = messages
        _draft = draft
        _approvalSelections = approvalSelections
        self.prompt = prompt
        self.isStreaming = isStreaming
        self.streamingStatus = streamingStatus
        self.emptyTitle = emptyTitle
        self.emptyDescription = emptyDescription
        self.errorMessage = errorMessage
        self.onSubmit = onSubmit
        self.onAction = onAction
        self.onContextOpen = onContextOpen
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
                            .padding(.top, 6)
                            .padding(.bottom, 10)
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
                    ContentUnavailableView(emptyTitle, systemImage: "sparkles", description: Text(emptyDescription))
                        .foregroundStyle(Color.zenTextMuted)
                        .frame(maxWidth: .infinity, minHeight: 260)
                }

                ForEach(messages) { message in
                    ZenAgentMessageView(
                        message: message,
                        approvalSelection: approvalSelection(for: message.id),
                        onAction: onAction,
                        onContextOpen: onContextOpen,
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
                Button("Jump to latest", systemImage: "arrow.down", action: { scrollToBottom(proxy) })
                    .labelStyle(.iconOnly)
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
            .padding(.horizontal, 21)
            .padding(.vertical, ZenSpacing.small)
    }

    private func approvalSelection(for messageID: String) -> Binding<String?> {
        Binding(
            get: { approvalSelections[messageID] },
            set: { selection in approvalSelections[messageID] = selection }
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
        prompt: LocalizedStringKey = "Message",
        isStreaming: Bool = false,
        streamingStatus: String? = nil,
        emptyTitle: LocalizedStringKey = "Start a conversation",
        emptyDescription: LocalizedStringKey = "Ask your agent to help with a task.",
        errorMessage: String? = nil,
        onSubmit: @escaping () -> Void,
        onAction: @escaping (String) -> Void = { _ in },
        onContextOpen: @escaping (String) -> Void = { _ in }
    ) {
        self.init(
            messages: messages,
            draft: draft,
            approvalSelections: approvalSelections,
            prompt: prompt,
            isStreaming: isStreaming,
            streamingStatus: streamingStatus,
            emptyTitle: emptyTitle,
            emptyDescription: emptyDescription,
            errorMessage: errorMessage,
            onSubmit: onSubmit,
            onAction: onAction,
            onContextOpen: onContextOpen
        ) { _ in
            EmptyView()
        }
    }
}

private struct ZenAgentMessageView<Attachment: View>: View {
    let message: ZenAgentMessage
    @Binding var approvalSelection: String?
    let onAction: (String) -> Void
    let onContextOpen: (String) -> Void
    let attachment: (ZenAgentMessage) -> Attachment

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: ZenSpacing.small) {
                ForEach(Array(message.blocks.enumerated()), id: \.offset) { _, block in
                    blockView(block)
                }
                attachment(message)
            }
            if message.role == .assistant { Spacer(minLength: 48) }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    @ViewBuilder private func blockView(_ block: ZenAgentMessageBlock) -> some View {
        switch block {
        case .text(let text):
            Text(text)
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
                .textSelection(.enabled)
                .padding(message.role == .user ? ZenSpacing.small : 0)
                .background(message.role == .user ? Color.zenSurfaceMuted : .clear)
                .clipShape(.rect(cornerRadius: ZenRadius.medium))
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
