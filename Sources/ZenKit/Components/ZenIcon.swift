import SwiftUI

public enum ZenIconSource: Equatable, Sendable {
    case asset(String)
    case system(String)
}

public struct ZenIcon: View {
    public let source: ZenIconSource
    public let size: CGFloat

    public init(source: ZenIconSource, size: CGFloat = 16) {
        self.source = source
        self.size = size
    }

    public init(assetName: String, size: CGFloat = 16) {
        self.init(source: .asset(assetName), size: size)
    }

    public init(systemName: String, size: CGFloat = 16) {
        self.init(source: .system(systemName), size: size)
    }

    public var body: some View {
        Group {
            switch source {
            case .asset(let assetName):
                Image(assetName)
                    .renderingMode(.template)
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

    public init(assetName: String) {
        self.init(source: .asset(assetName))
    }

    public init(systemName: String) {
        self.init(source: .system(systemName))
    }

    public var body: some View {
        switch source {
        case .asset(let assetName):
            Image(assetName)
                .renderingMode(.template)
        case .system(let systemName):
            Image(systemName: systemName)
                .renderingMode(.template)
        }
    }
}

#Preview {
    ZenIcon(assetName: "Envelope", size: 18)
        .foregroundStyle(Color.zenPrimary)
        .padding()
}
