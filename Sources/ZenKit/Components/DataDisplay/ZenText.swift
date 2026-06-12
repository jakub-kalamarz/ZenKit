import SwiftUI

public enum ZenTextVariant: Sendable {
    case heading1
    case heading2
    case heading3
    case body
    case secondary
    case success
    case danger
    case mono
}

public enum ZenTextSize: Sendable {
    case xs
    case sm
    case base
    case lg
}

public struct ZenText: View {
    private let content: String
    private let variant: ZenTextVariant
    private let size: ZenTextSize

    public init(_ content: String, variant: ZenTextVariant = .body, size: ZenTextSize = .base) {
        self.content = content
        self.variant = variant
        self.size = size
    }

    public var body: some View {
        #if DEBUG
        #endif
        Text(content)
            .font(resolvedFont)
            .foregroundStyle(resolvedColor)
    }

    private var resolvedFont: Font {
        switch variant {
        case .heading1:
            return .zenDisplayM
        case .heading2:
            return .zenDisplayS
        case .heading3:
            return .zen(.body, weight: .semibold)
        case .body, .success, .danger:
            return sizeToFont
        case .secondary:
            return sizeToFont
        case .mono:
            return sizeToFont.monospaced()
        }
    }

    private var resolvedColor: Color {
        switch variant {
        case .heading1, .heading2, .heading3:
            return .zenTextStrong
        case .body:
            return .zenTextPrimary
        case .secondary:
            return .zenTextMuted
        case .success:
            return .zenSuccess
        case .danger:
            return .zenCritical
        case .mono:
            return .zenTextPrimary
        }
    }

    private var sizeToFont: Font {
        switch size {
        case .xs: return .zen(.group)
        case .sm: return .zenBody2
        case .base: return .zenBody
        case .lg: return .zenDisplayS
        }
    }

}

#Preview("ZenText") {
    VStack(alignment: .leading, spacing: ZenSpacing.small) {
        ZenText("Heading 1", variant: .heading1)
        ZenText("Heading 2", variant: .heading2)
        ZenText("Heading 3", variant: .heading3)
        ZenText("Body text", variant: .body)
        ZenText("Secondary text", variant: .secondary)
        ZenText("Success text", variant: .success)
        ZenText("Danger text", variant: .danger)
        ZenText("Monospaced text", variant: .mono)
    }
    .padding()
    .background(Color.zenBackground)
}
