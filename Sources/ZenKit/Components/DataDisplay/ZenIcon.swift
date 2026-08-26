import SwiftUI

public enum ZenIconSource: Hashable, Sendable {
    case asset(String, renderingMode: ZenIconRenderingMode)
    case hugeIcon(HugeIcon)
    case system(String)
}

extension ZenIconSource: ExpressibleByStringLiteral {
    /// A bare string literal is an SF Symbol name, so `icon: "house"` keeps working
    /// while callers can still pass `.hugeIcon(_:)` or `.asset(_:renderingMode:)`.
    public init(stringLiteral value: String) {
        self = .system(value)
    }
}

extension ZenIconSource {
    /// Best-effort human-readable name. Components use it as an accessibility
    /// fallback when the caller gave an icon but no label.
    public var fallbackLabel: String {
        switch self {
        case .asset(let name, _):
            return name
        case .hugeIcon(let icon):
            return String(describing: icon)
        case .system(let name):
            return name
        }
    }
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
    public let weight: Font.Weight?

    public init(source: ZenIconSource, size: CGFloat = 16, weight: Font.Weight? = nil) {
        self.source = source
        self.size = size
        self.weight = weight
    }

    public init(assetName: String, size: CGFloat = 16, renderingMode: ZenIconRenderingMode) {
        self.init(source: .asset(assetName, renderingMode: renderingMode), size: size)
    }

    public init(icon: HugeIcon, size: CGFloat = 16, weight: Font.Weight? = nil) {
        self.init(source: .hugeIcon(icon), size: size, weight: weight)
    }

    @available(*, deprecated, message: "Use init(icon:size:) with HugeIcon")
    public init(systemName: String, size: CGFloat = 16, weight: Font.Weight? = nil) {
        guard let icon = HugeIcon.legacy(systemName) else {
            preconditionFailure("Missing HugeIcons migration mapping for \(systemName)")
        }
        self.init(icon: icon, size: size, weight: weight)
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

    public init(systemName: String) {
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
