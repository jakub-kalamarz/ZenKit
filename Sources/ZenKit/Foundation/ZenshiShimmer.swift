import SwiftUI

public struct ZenshiShimmer: ViewModifier {
    public enum Mode {
        case mask
        case overlay(blendMode: BlendMode = .sourceAtop)
        case background
    }

    private let animation: Animation
    private let gradient: Gradient
    private let min, max: CGFloat
    private let mode: Mode
    @State private var isInitialState = true
    @Environment(\.layoutDirection) private var layoutDirection

    public init(
        animation: Animation = Self.defaultAnimation,
        gradient: Gradient = Self.defaultGradient,
        bandSize: CGFloat = 0.3,
        mode: Mode = .mask
    ) {
        self.animation = animation
        self.gradient = gradient
        self.min = 0 - bandSize
        self.max = 1 + bandSize
        self.mode = mode
    }

    public static let defaultAnimation = Animation.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false)
    public static let defaultGradient = Gradient(colors: [.black.opacity(0.3), .black, .black.opacity(0.3)])

    var startPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1)
        } else {
            isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1)
        }
    }

    var endPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max)
        } else {
            isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max)
        }
    }

    public func body(content: Content) -> some View {
        applyingGradient(to: content)
            .animation(animation, value: isInitialState)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    isInitialState = false
                }
            }
    }

    @ViewBuilder public func applyingGradient(to content: Content) -> some View {
        let gradient = LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
        switch mode {
        case .mask:
            content.mask(gradient)
        case let .overlay(blendMode: blendMode):
            content.overlay(gradient.blendMode(blendMode))
        case .background:
            content.background(gradient)
        }
    }
}

public extension View {
    @ViewBuilder func zenShimmering(
        active: Bool = true,
        animation: Animation = ZenshiShimmer.defaultAnimation,
        gradient: Gradient = ZenshiShimmer.defaultGradient,
        bandSize: CGFloat = 0.3,
        mode: ZenshiShimmer.Mode = .mask
    ) -> some View {
        if active {
            modifier(ZenshiShimmer(animation: animation, gradient: gradient, bandSize: bandSize, mode: mode))
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("Loading...")
            .font(.title)
            .zenShimmering()
        Text(String(repeating: "Shimmer ", count: 6))
            .redacted(reason: .placeholder)
            .zenShimmering()
        Text("Custom gradient")
            .font(.largeTitle).bold()
            .zenShimmering(
                gradient: Gradient(colors: [.clear, .orange, .white, .green, .clear]),
                bandSize: 0.5,
                mode: .overlay()
            )
    }
    .padding()
}
