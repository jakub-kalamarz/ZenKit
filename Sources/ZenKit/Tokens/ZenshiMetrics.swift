import CoreGraphics
import SwiftUI

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
    public static let xSmall: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 14
    public static let large: CGFloat = 20
    public static let xLarge: CGFloat = 32
}

public enum ZenRadius {
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
}

public enum ZenShadow {
    public static let xs: (color: SwiftUI.Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (.black.opacity(0.04), 1, 0, 1)
    public static let sm: (color: SwiftUI.Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (.black.opacity(0.06), 3, 0, 2)
    public static let md: (color: SwiftUI.Color, radius: CGFloat, x: CGFloat, y: CGFloat) =
        (.black.opacity(0.08), 8, 0, 4)
}
