import SwiftUI

public struct ZenSwipeAction {
    public let label: String
    public let systemIconName: String
    public let tint: Color
    public let action: () -> Void

    public init(
        label: String,
        systemIconName: String,
        tint: Color = Color.zenTextMuted,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.systemIconName = systemIconName
        self.tint = tint
        self.action = action
    }
}

public struct ZenSwipeRow<Content: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius

    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false

    private let trailingActions: [ZenSwipeAction]
    private let content: () -> Content

    public init(
        trailingActions: [ZenSwipeAction],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.trailingActions = trailingActions
        self.content = content
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)
        let maxOffset = -CGFloat(72 * trailingActions.count)

        ZStack(alignment: .trailing) {
            // Trailing action buttons
            if !trailingActions.isEmpty {
                HStack(spacing: 0) {
                    ForEach(trailingActions.indices, id: \.self) { index in
                        let action = trailingActions[index]
                        let isLast = index == trailingActions.count - 1

                        Button {
                            action.action()
                            withAnimation(.spring(duration: 0.3)) {
                                offset = 0
                                isSwiped = false
                            }
                        } label: {
                            VStack(spacing: 4) {
                                ZenIcon(systemName: action.systemIconName, size: 16)
                                    .font(.system(size: 16, weight: .medium))
                                Text(action.label)
                                    .font(.zenTextXS)
                            }
                            .foregroundStyle(Color.white)
                            .frame(width: 72)
                            .frame(maxHeight: .infinity)
                            .background(action.tint)
                        }
                        .buttonStyle(.plain)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: isLast ? cornerRadius : 0,
                                topTrailingRadius: isLast ? cornerRadius : 0,
                                style: .continuous
                            )
                        )
                    }
                }
                .frame(width: CGFloat(72 * trailingActions.count))
            }

            // Content view
            content()
                .offset(x: offset)
                .animation(.spring(duration: 0.3), value: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.width
                            if translation < 0 {
                                offset = max(translation, maxOffset)
                            } else if isSwiped {
                                offset = min(maxOffset + translation, 0)
                            }
                        }
                        .onEnded { value in
                            let translation = value.translation.width
                            withAnimation(.spring(duration: 0.3)) {
                                if translation < -36 {
                                    offset = maxOffset
                                    isSwiped = true
                                } else {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    if isSwiped {
                        withAnimation(.spring(duration: 0.3)) {
                            offset = 0
                            isSwiped = false
                        }
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenSwipeRow(
            trailingActions: [
                ZenSwipeAction(
                    label: "Archive",
                    systemIconName: "archivebox",
                    tint: Color.zenWarning,
                    action: {}
                ),
                ZenSwipeAction(
                    label: "Delete",
                    systemIconName: "trash",
                    tint: Color.zenCritical,
                    action: {}
                )
            ]
        ) {
            HStack(spacing: ZenSpacing.small) {
                ZenIconBadge(systemName: "envelope.fill", color: .blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Team Update")
                        .font(.zenTextSM.weight(.medium))
                        .foregroundStyle(Color.zenTextPrimary)
                    Text("Swipe left to reveal actions")
                        .font(.zenTextXS)
                        .foregroundStyle(Color.zenTextMuted)
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, ZenSpacing.medium)
            .background(Color.zenSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.zenBorder, lineWidth: 1)
            )
        }

        ZenSwipeRow(
            trailingActions: [
                ZenSwipeAction(
                    label: "Delete",
                    systemIconName: "trash",
                    tint: Color.zenCritical,
                    action: {}
                )
            ]
        ) {
            HStack(spacing: ZenSpacing.small) {
                ZenIconBadge(systemName: "bell.fill", color: .red)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reminder")
                        .font(.zenTextSM.weight(.medium))
                        .foregroundStyle(Color.zenTextPrimary)
                    Text("Swipe left to delete")
                        .font(.zenTextXS)
                        .foregroundStyle(Color.zenTextMuted)
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, ZenSpacing.medium)
            .background(Color.zenSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.zenBorder, lineWidth: 1)
            )
        }
    }
    .padding()
    .background(Color.zenBackground)
}
