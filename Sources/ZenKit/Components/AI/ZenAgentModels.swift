import Foundation

public enum ZenAgentMessageRole: String, Sendable, Equatable {
    case user
    case assistant
}

public enum ZenAgentFeedback: String, Sendable, Equatable {
    case positive
    case negative
}

public struct ZenAgentSource: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let detail: String?
    public let label: String?
    public let isInteractive: Bool

    public init(
        id: String,
        title: String,
        detail: String? = nil,
        label: String? = nil,
        isInteractive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.label = label
        self.isInteractive = isInteractive
    }
}

public struct ZenAgentResponseMetadata: Sendable, Equatable {
    public let sources: [ZenAgentSource]
    public let followUps: [String]
    public let allowsCopy: Bool
    public let allowsFeedback: Bool

    public init(
        sources: [ZenAgentSource] = [],
        followUps: [String] = [],
        allowsCopy: Bool = true,
        allowsFeedback: Bool = true
    ) {
        self.sources = sources
        self.followUps = followUps
        self.allowsCopy = allowsCopy
        self.allowsFeedback = allowsFeedback
    }
}

public enum ZenAgentMessageAction: Sendable, Equatable {
    case copy
    case feedback(ZenAgentFeedback?)
    case openSource(String)
    case followUp(String)
}

public enum ZenAgentTaskState: String, Sendable, Equatable {
    case queued
    case running
    case completed
    case failed
}

public struct ZenAgentAction: Identifiable, Sendable, Equatable {
    public enum Style: Sendable, Equatable { case primary, secondary, destructive }

    public let id: String
    public let title: String
    public let style: Style

    public init(id: String, title: String, style: Style = .secondary) {
        self.id = id
        self.title = title
        self.style = style
    }
}

public struct ZenAgentToolCall: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let detail: String?
    public let state: ZenAgentTaskState

    public init(id: String, title: String, detail: String? = nil, state: ZenAgentTaskState) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
    }
}

public struct ZenAgentContextItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let excerpt: String
    public let sourceLabel: String
    public let metadata: String?

    public init(id: String, title: String, excerpt: String, sourceLabel: String, metadata: String? = nil) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.sourceLabel = sourceLabel
        self.metadata = metadata
    }
}

public struct ZenAgentResearchAnswer: Identifiable, Sendable, Equatable {
    public struct Source: Identifiable, Sendable, Equatable {
        public let id: String
        public let title: String
        public let host: String

        public init(id: String, title: String, host: String) {
            self.id = id
            self.title = title
            self.host = host
        }
    }

    public let id: String
    public let summary: String
    public let sources: [Source]
    public let followUps: [String]

    public init(id: String, summary: String, sources: [Source], followUps: [String] = []) {
        self.id = id
        self.summary = summary
        self.sources = sources
        self.followUps = followUps
    }
}

public struct ZenAgentTask: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let detail: String?
    public let state: ZenAgentTaskState
    public let progress: Double?

    public init(id: String, title: String, detail: String? = nil, state: ZenAgentTaskState, progress: Double? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
        self.progress = progress
    }
}

public struct ZenAgentApproval: Identifiable, Sendable, Equatable {
    public struct Option: Identifiable, Sendable, Equatable {
        public let id: String
        public let title: String
        public let detail: String?

        public init(id: String, title: String, detail: String? = nil) {
            self.id = id
            self.title = title
            self.detail = detail
        }
    }

    public let id: String
    public let title: String
    public let options: [Option]
    public let continueAction: ZenAgentAction
    public let skipAction: ZenAgentAction?

    public init(id: String, title: String, options: [Option], continueAction: ZenAgentAction, skipAction: ZenAgentAction? = nil) {
        self.id = id
        self.title = title
        self.options = options
        self.continueAction = continueAction
        self.skipAction = skipAction
    }
}

public struct ZenAgentRecommendation: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let detail: String
    public let confidence: Double
    public let alternatives: [String]
    public let actions: [ZenAgentAction]

    public init(id: String, title: String, detail: String, confidence: Double, alternatives: [String] = [], actions: [ZenAgentAction] = []) {
        self.id = id
        self.title = title
        self.detail = detail
        self.confidence = confidence
        self.alternatives = alternatives
        self.actions = actions
    }
}

public enum ZenAgentMessageBlock: Sendable, Equatable {
    case text(String)
    case research(ZenAgentResearchAnswer)
    case reasoning(summary: String, detail: String?)
    case toolCalls([ZenAgentToolCall])
    case contexts([ZenAgentContextItem])
    case recommendation(ZenAgentRecommendation)
    case approval(ZenAgentApproval)
}

public struct ZenAgentMessage: Identifiable, Sendable, Equatable {
    public let id: String
    public let role: ZenAgentMessageRole
    public let blocks: [ZenAgentMessageBlock]
    public let responseMetadata: ZenAgentResponseMetadata?

    public init(
        id: String,
        role: ZenAgentMessageRole,
        blocks: [ZenAgentMessageBlock],
        responseMetadata: ZenAgentResponseMetadata? = nil
    ) {
        self.id = id
        self.role = role
        self.blocks = blocks
        self.responseMetadata = responseMetadata
    }
}
