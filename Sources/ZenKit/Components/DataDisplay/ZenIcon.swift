import SwiftUI

public enum ZenIconSource: Equatable, Sendable {
    case asset(String, renderingMode: ZenIconRenderingMode)
    case system(String)
}

public enum ZenIconRenderingMode: Equatable, Sendable {
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
    public let source: ZenIconSource
    public let size: CGFloat

    public init(source: ZenIconSource, size: CGFloat = 16) {
        self.source = source
        self.size = size
    }

    public init(assetName: String, size: CGFloat = 16, renderingMode: ZenIconRenderingMode) {
        self.init(source: .asset(assetName, renderingMode: renderingMode), size: size)
    }

    public init(systemName: String, size: CGFloat = 16) {
        self.init(source: .system(systemName), size: size)
    }

    public var body: some View {
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

    public init(systemName: String) {
        self.init(source: .system(systemName))
    }

    public var body: some View {
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
    ZenIcon(assetName: "Envelope", size: 18, renderingMode: .template)
        .foregroundStyle(Color.zenPrimary)
        .padding()
}
