import SwiftUI

public enum ZenIconSource: Hashable, Sendable {
    case asset(String, renderingMode: ZenIconRenderingMode)
    case hugeIcon(HugeIcon)
    case system(String)
}

public enum ZenIconRenderingMode: Hashable, Sendable {
    case original
    case template

    var imageRenderingMode: Image.TemplateRenderingMode {
        switch self {
        case .original:
            return .original
        case .template:
            return .template
        }
    }
}

public struct ZenIcon: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let source: ZenIconSource
    public let size: CGFloat

    public init(source: ZenIconSource, size: CGFloat = 16) {
        self.source = source
        self.size = size
    }

    public init(assetName: String, size: CGFloat = 16, renderingMode: ZenIconRenderingMode) {
        self.init(source: .asset(assetName, renderingMode: renderingMode), size: size)
    }

    public init(icon: HugeIcon, size: CGFloat = 16) {
        self.init(source: .hugeIcon(icon), size: size)
    }

    @available(*, deprecated, message: "Use init(icon:size:) with HugeIcon")
    public init(systemName: String, size: CGFloat = 16, weight: Font.Weight? = nil) {
        guard let icon = HugeIcon.legacy(systemName) else {
            preconditionFailure("Missing HugeIcons migration mapping for \(systemName)")
        }
        self.init(icon: icon, size: size)
    }

    public var body: some View {
        ZStack {
            icon
                .id(source)
                .transition(iconTransition)
        }
        .animation(iconAnimation, value: source)
    }

    @ViewBuilder
    private var icon: some View {
        scaledIcon
    }

    private var iconTransition: AnyTransition {
        reduceMotion ? .opacity : .scale(scale: 0.72).combined(with: .opacity)
    }

    private var iconAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.3, dampingFraction: 0.68)
    }

    private var scaledIcon: some View {
        Group {
            switch source {
            case .asset(let assetName, let renderingMode):
                Image(assetName)
                    .renderingMode(renderingMode.imageRenderingMode)
                    .resizable()
                    .scaledToFit()
            case .hugeIcon(let icon):
                if HugeIconFont.isAvailable {
                    Text(icon.character)
                        .font(.custom(HugeIcon.fontFamily, fixedSize: size))
                        .accessibilityHidden(true)
                } else {
                    RoundedRectangle(cornerRadius: size * 0.18)
                        .stroke(lineWidth: max(1, size * 0.08))
                        .accessibilityHidden(true)
                }
            case .system(let name):
                if let icon = HugeIcon.legacy(name), HugeIconFont.isAvailable {
                    Text(icon.character)
                        .font(.custom(HugeIcon.fontFamily, fixedSize: size))
                        .accessibilityHidden(true)
                } else {
                    RoundedRectangle(cornerRadius: size * 0.18)
                        .stroke(lineWidth: max(1, size * 0.08))
                        .accessibilityHidden(true)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

public struct ZenMenuIcon: View {
    public let source: ZenIconSource

    public init(source: ZenIconSource) {
        self.source = source
    }

    public init(assetName: String, renderingMode: ZenIconRenderingMode) {
        self.init(source: .asset(assetName, renderingMode: renderingMode))
    }

    public init(icon: HugeIcon) {
        self.init(source: .hugeIcon(icon))
    }

    init(systemName: String) {
        self.init(source: .system(systemName))
    }

    public var body: some View {
        #if DEBUG
        #endif
        switch source {
        case .asset(let assetName, let renderingMode):
            Image(assetName)
                .renderingMode(renderingMode.imageRenderingMode)
        case .hugeIcon(let icon):
            Text(icon.character)
                .font(.custom(HugeIcon.fontFamily, fixedSize: 16))
                .accessibilityHidden(true)
        case .system(let name):
            if let icon = HugeIcon.legacy(name) {
                Text(icon.character)
                    .font(.custom(HugeIcon.fontFamily, fixedSize: 16))
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview {
    ZenIcon(icon: .envelope)
        .foregroundStyle(Color.zenPrimary)
        .padding()
}
