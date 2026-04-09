import SwiftUI

public struct ZenDisclosure<Content: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    @State private var isExpanded: Bool

    private let title: String
    private let subtitle: String?
    private let leadingIcon: ZenIconSource?
    private let content: () -> Content

    public init(
        _ title: String,
        subtitle: String? = nil,
        leadingIcon: ZenIconSource? = nil,
        leadingIconSystemName: String? = nil,
        isExpanded: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon ?? leadingIconSystemName.map(ZenIconSource.system)
        _isExpanded = State(initialValue: isExpanded)
        self.content = content
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedControl, parentRadius: parentCornerRadius)

        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: ZenSpacing.small) {
                    if let leadingIcon {
                        ZenIcon(source: leadingIcon, size: 16)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.zenTextMuted)
                            .frame(width: 20, height: 20)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.zenLabel)
                            .foregroundStyle(Color.zenTextPrimary)

                        if let subtitle {
                            Text(subtitle)
                                .font(.zenCaption)
                                .foregroundStyle(Color.zenTextMuted)
                        }
                    }

                    Spacer(minLength: ZenSpacing.small)

                    ZenIcon(systemName: "chevron.right", size: 12)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.zenTextMuted)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, ZenSpacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Rectangle()
                    .fill(Color.zenBorder)
                    .frame(height: 1)

                content()
                    .environment(\.zenContainerCornerRadius, cornerRadius)
                    .padding(ZenSpacing.medium)
            }
        }
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: ZenSpacing.small) {
        ZenDisclosure("Advanced Settings", leadingIcon: .system("gearshape")) {
            VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                Text("Configure advanced options below.")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }

        ZenDisclosure("Notifications", subtitle: "Email and push", leadingIcon: .system("bell"), isExpanded: true) {
            VStack(spacing: ZenSpacing.xSmall) {
                Text("Push notifications are enabled.")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
                Text("Email digest: weekly")
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
