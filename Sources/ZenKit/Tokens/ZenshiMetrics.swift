import CoreGraphics

public struct ZenResolvedMetrics: Equatable, Sendable {
    public let controlHeight: CGFloat
    public var controlHeightMedium: CGFloat { controlHeight }
    public let controlHeightSmall: CGFloat
    public let controlHeightLarge: CGFloat
    public let cardPadding: CGFloat
    public let fieldVerticalPadding: CGFloat

    public init(
        controlHeight: CGFloat,
        controlHeightSmall: CGFloat,
        controlHeightLarge: CGFloat,
        cardPadding: CGFloat,
        fieldVerticalPadding: CGFloat
    ) {
        self.controlHeight = controlHeight
        self.controlHeightSmall = controlHeightSmall
        self.controlHeightLarge = controlHeightLarge
        self.cardPadding = cardPadding
        self.fieldVerticalPadding = fieldVerticalPadding
    }
}

public enum ZenSpacing {
    public static let xSmall: CGFloat = 6
    public static let small: CGFloat = 10
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
    public static let xLarge: CGFloat = 32
}

public enum ZenRadius {
    public static let small: CGFloat = 10
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
}
