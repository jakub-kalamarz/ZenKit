import SwiftUI

public struct ZenAgentTaskRow: View {
    public let task: ZenAgentTask

    public init(task: ZenAgentTask) {
        self.task = task
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
            HStack(spacing: ZenSpacing.small) {
                statusIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.zen(.group, weight: .semibold))
                        .foregroundStyle(Color.zenTextPrimary)
                    if let detail = task.detail {
                        Text(detail)
                            .font(.zenGroup)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
                Spacer(minLength: 0)
                Text(statusTitle)
                    .font(.zenGroup)
                    .foregroundStyle(statusColor)
            }
            if let progress = task.progress {
                ZenProgressBar(progress: min(max(progress, 0), 1))
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var statusIcon: some View {
        switch task.state {
        case .running: ZenSpinner(size: .small)
        case .queued: ZenIcon(systemName: "clock", size: 14).foregroundStyle(Color.zenTextMuted)
        case .completed: ZenIcon(systemName: "checkmark.circle.fill", size: 14).foregroundStyle(Color.zenSuccess)
        case .failed: ZenIcon(systemName: "exclamationmark.triangle.fill", size: 14).foregroundStyle(Color.zenCritical)
        }
    }

    private var statusTitle: String {
        switch task.state { case .queued: "Queued"; case .running: "Running"; case .completed: "Completed"; case .failed: "Failed" }
    }

    private var statusColor: Color {
        switch task.state { case .queued: .zenTextMuted; case .running: .zenPrimary; case .completed: .zenSuccess; case .failed: .zenCritical }
    }
}

public struct ZenAgentToolChip: View {
    public let toolCall: ZenAgentToolCall

    public init(toolCall: ZenAgentToolCall) { self.toolCall = toolCall }

    public var body: some View {
        HStack(spacing: ZenSpacing.xSmall) {
            stateSymbol
            Text(toolCall.title)
                .font(.zen(.group, weight: .semibold))
                .foregroundStyle(Color.zenTextPrimary)
                .lineLimit(1)
            if let detail = toolCall.detail {
                Text(detail)
                    .font(.zenGroup)
                    .foregroundStyle(Color.zenTextMuted)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, ZenSpacing.small)
        .frame(minHeight: 32)
        .background(Color.zenSurfaceMuted)
        .clipShape(.capsule)
        .overlay { Capsule().strokeBorder(Color.zenBorderSubtle, lineWidth: 1) }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var stateSymbol: some View {
        switch toolCall.state {
        case .running:
            ZenSpinner(size: .small)
        case .queued:
            ZenIcon(systemName: "clock", size: 11).foregroundStyle(Color.zenTextMuted)
        case .completed:
            ZenIcon(systemName: "checkmark", size: 11).foregroundStyle(Color.zenSuccess)
        case .failed:
            ZenIcon(systemName: "exclamationmark", size: 11).foregroundStyle(Color.zenCritical)
        }
    }
}
