import SwiftUI

public enum ZenSpinnerSize {
    case small
    case medium
    case large

    fileprivate var diameter: CGFloat {
        switch self {
        case .small:
            return 14
        case .medium:
            return 18
        case .large:
            return 28
        }
    }

    fileprivate var lineWidth: CGFloat {
        switch self {
        case .small:
            return 2
        case .medium:
            return 2.5
        case .large:
            return 3
        }
    }
}

public struct ZenSpinner: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let size: ZenSpinnerSize
    public let tint: Color
    public let showsTrack: Bool

    @State private var isRotating = false
    @State private var isMorphing = false

    public init(
        size: ZenSpinnerSize = .medium,
        tint: Color = .zenPrimary,
        showsTrack: Bool = true
    ) {
        self.size = size
        self.tint = tint
        self.showsTrack = showsTrack
    }

    public var body: some View {
        let spinnerCornerRadius = size.diameter / 2

        ZStack {
            if showsTrack {
                RoundedRectangle(cornerRadius: spinnerCornerRadius, style: .continuous)
                    .stroke(tint.opacity(0.18), style: strokeStyle)
            }

            RoundedRectangle(cornerRadius: spinnerCornerRadius, style: .continuous)
                .trim(from: trimStart, to: trimEnd)
                .stroke(tint, style: strokeStyle)
                .rotationEffect(rotation)
        }
        .frame(width: size.diameter, height: size.diameter)
        .accessibilityHidden(true)
        .onAppear(perform: startAnimating)
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: size.lineWidth, lineCap: .round)
    }

    private var trimStart: CGFloat {
        guard !reduceMotion else {
            return 0.16
        }

        return isMorphing ? 0.18 : 0.04
    }

    private var trimEnd: CGFloat {
        guard !reduceMotion else {
            return 0.78
        }

        return isMorphing ? 0.96 : 0.58
    }

    private var rotation: Angle {
        .degrees(isRotating ? 360 : 0)
    }

    private func startAnimating() {
        guard !isRotating else {
            return
        }

        withAnimation(rotationAnimation) {
            isRotating = true
        }

        guard !reduceMotion else {
            return
        }

        withAnimation(morphAnimation) {
            isMorphing = true
        }
    }

    private var rotationAnimation: Animation {
        if reduceMotion {
            return .linear(duration: 1.2).repeatForever(autoreverses: false)
        }

        return .linear(duration: 0.95).repeatForever(autoreverses: false)
    }

    private var morphAnimation: Animation {
        .easeInOut(duration: 0.72).repeatForever(autoreverses: true)
    }
}

#Preview {
    VStack(spacing: ZenSpacing.medium) {
        HStack(spacing: ZenSpacing.medium) {
            ZenSpinner(size: .small)
            ZenSpinner()
            ZenSpinner(size: .large)
        }

        HStack(spacing: ZenSpacing.medium) {
            ZenSpinner(tint: .zenTextPrimary)
            ZenSpinner(size: .large, tint: .zenPrimary, showsTrack: false)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
