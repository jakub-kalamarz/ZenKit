import SwiftUI
import ZenAvatar

public struct ZenAvatar: View {
    private let name: String?
    private let imageURL: URL?
    private let size: CGFloat

    public init(name: String?, imageURL: URL?, size: CGFloat = 52) {
        self.name = name
        self.imageURL = imageURL
        self.size = size
    }

    public var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedFullyRoundedCornerRadius(for: size)

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(theme.resolvedColors.primarySubtle.color)

            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        initialsView
                    }
                }
            } else {
                AvatarView(seed: name ?? "", size: size, variant: .beam, shape: .square)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var initialsView: some View {
        Text(InitialsFormatter.initials(for: name))
            .font(.system(size: size * 0.34, weight: .semibold))
            .foregroundStyle(Color.zenAccent)
    }
}

#Preview {
    HStack(spacing: ZenSpacing.medium) {
        ZenAvatar(name: "Alex Morgan", imageURL: nil)
        ZenAvatar(name: "Zen", imageURL: nil)
    }
    .padding()
}
