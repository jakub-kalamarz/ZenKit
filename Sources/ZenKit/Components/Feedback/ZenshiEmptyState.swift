import SwiftUI

public enum ZenEmptyMediaVariant {
    case `default`
    case icon
}

public struct ZenEmpty<Content: View>: View {
    private let content: () -> Content

    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        container
    }

    private var container: some View {
        VStack(spacing: ZenSpacing.large) {
            content()
        }
        .frame(maxWidth: .infinity)
    }
}

public struct ZenEmptyHeader<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        VStack(spacing: ZenSpacing.medium) {
            content()
        }
        .frame(maxWidth: .infinity)
    }
}

public struct ZenEmptyMedia<Content: View>: View {
    private let variant: ZenEmptyMediaVariant
    private let content: () -> Content

    public init(
        variant: ZenEmptyMediaVariant = .default,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.variant = variant
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        Group {
            switch variant {
            case .default:
                content()
            case .icon:
                // The glyph sits in a tinted disc rather than floating grey in space: an
                // empty screen is still a screen, and the disc gives it one warm anchor.
                content()
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.zenPrimary)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(Color.zenPrimarySubtle))
            }
        }
    }
}

public struct ZenEmptyTitle<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        content()
            .font(.zen(.title, weight: .bold))
            .foregroundStyle(Color.zenTextPrimary)
            .multilineTextAlignment(.center)
    }
}

public struct ZenEmptyDescription<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        content()
            .font(.zenGroup)
            .foregroundStyle(Color.zenTextMuted)
            .multilineTextAlignment(.center)
    }
}

public struct ZenEmptyContent<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        #if DEBUG
        #endif
        VStack(spacing: ZenSpacing.small) {
            content()
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    ZenEmpty {
        ZenEmptyHeader {
            ZenEmptyMedia(variant: .icon) {
                ZenIcon(icon: .exclamationmarkTriangleFill, size: 24)
            }
            ZenEmptyTitle {
                Text("No results found")
            }
            ZenEmptyDescription {
                Text("Try adjusting your search or filter to find what you're looking for.")
            }
        }
        ZenEmptyContent {
            ZenButton(action: {}) {
                Text("Clear filters")
            }
        }
    }
    .background(Color.zenBackground)
}
