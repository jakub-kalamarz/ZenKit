import SwiftUI

public enum ZenIconSource: Hashable, Sendable {
    case asset(String, renderingMode: ZenIconRenderingMode)
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
    /// When set, an SF Symbol is rendered at `.system(size:weight:)` instead of
    /// being scaled to fit the box. `.resizable()` discards a symbol's stroke
    /// weight, so weighted icons have to take the font path — `size` is then the
    /// font size rather than the bounding box.
    public let weight: Font.Weight?

    public init(source: ZenIconSource, size: CGFloat = 16, weight: Font.Weight? = nil) {
        self.source = source
        self.size = size
        self.weight = weight
    }

    public init(assetName: String, size: CGFloat = 16, renderingMode: ZenIconRenderingMode) {
        self.init(source: .asset(assetName, renderingMode: renderingMode), size: size)
    }

    public init(systemName: String, size: CGFloat = 16, weight: Font.Weight? = nil) {
        self.init(source: .system(systemName), size: size, weight: weight)
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
        if case .system(let systemName) = source, let weight {
            Image(systemName: systemName)
                .font(.system(size: size, weight: weight))
        } else {
            scaledIcon
        }
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
            case .system(let systemName):
                Image(systemName: systemName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxWidth: size, maxHeight: size)
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
        case .system(let systemName):
            Image(systemName: systemName)
                .renderingMode(.template)
        }
    }
}

#Preview {
    ZenIcon(systemName: "envelope")
        .foregroundStyle(Color.zenPrimary)
        .padding()
}
