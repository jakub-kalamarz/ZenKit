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
        Group {
            switch variant {
            case .default:
                content()
            case .icon:
                content()
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.zenTextMuted)
                    .frame(width: 56, height: 56)
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
        content()
            .font(.zenTitle)
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
        content()
            .font(.zenCaption)
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
                ZenIcon(systemName: "exclamationmark.triangle.fill", size: 24)
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
