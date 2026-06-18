import SwiftUI

/// A card whose primary surface overlaps a muted secondary panel,
/// leaving a thin strip of the secondary peeking out below.
public struct ZenLayerCard<Secondary: View, Primary: View>: View {
    /// How far the secondary panel peeks out beneath the primary surface.
    private static var peek: CGFloat { ZenSpacing.large + 4 }

    private let secondary: Secondary?
    private let primary: Primary

    public init(
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.primary = primary()
        self.secondary = secondary()
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let secondary {
                secondary
                    .padding(ZenSpacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, Self.peek)
                    .zenLayerSurface(Color.zenSurfaceMuted)
            }

            primary
                .padding(ZenSpacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .zenLayerSurface(Color.zenSurface)
                .padding(.top, secondary == nil ? 0 : -Self.peek)
        }
    }
}

private extension View {
    /// Fills the view with `background`, clips it to the themed corner radius,
    /// and draws the subtle border used by layered card surfaces.
    func zenLayerSurface(_ background: Color) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: ZenTheme.current.resolvedCornerRadius,
            style: .continuous
        )
        return self
            .background(background)
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.zenBorderSubtle, lineWidth: 1))
    }
}

extension ZenLayerCard where Secondary == EmptyView {
    public init(@ViewBuilder primary: () -> Primary) {
        self.primary = primary()
        self.secondary = nil
    }
}

#Preview("ZenLayerCard") {
    VStack(spacing: ZenSpacing.medium) {
        ZenLayerCard {
            Text("Primary content")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        } secondary: {
            Text("Secondary header")
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextMuted)
        }

        ZenLayerCard {
            Text("Simple card without secondary section")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
