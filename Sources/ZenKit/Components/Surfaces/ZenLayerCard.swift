import SwiftUI

/// A card whose primary surface overlaps muted secondary/footer panels,
/// leaving a thin strip of each peeking out above and/or below.
public struct ZenLayerCard<Secondary: View, Primary: View, Footer: View>: View {
    /// How far a muted panel peeks out beyond the primary surface.
    private static var peek: CGFloat { ZenSpacing.large + 4 }

    private let secondary: Secondary?
    private let primary: Primary
    private let footer: Footer?

    public init(
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary,
        @ViewBuilder footer: () -> Footer
    ) {
        self.primary = primary()
        self.secondary = secondary()
        self.footer = footer()
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let secondary {
                secondary
                    .padding(.horizontal, ZenSpacing.medium)
                    .padding(.top, ZenSpacing.small + 2)
                    .padding(.bottom, ZenSpacing.small + Self.peek)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zenLayerSurface(Color.zenSurfaceMuted)
            }

            primary
                .padding(.horizontal, ZenSpacing.medium)
                .padding(.vertical, ZenSpacing.xSmall)
                .frame(maxWidth: .infinity, alignment: .leading)
                .zenLayerSurface(Color.zenSurface)
                .padding(.top, secondary == nil ? 0 : -Self.peek)
                .zIndex(1)

            if let footer {
                footer
                    .padding(.horizontal, ZenSpacing.medium)
                    .padding(.top, ZenSpacing.small + Self.peek)
                    .padding(.bottom, ZenSpacing.small + 2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .zenLayerSurface(Color.zenSurfaceMuted)
                    .padding(.top, -Self.peek)
            }
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

// MARK: - Convenience initializers

extension ZenLayerCard where Footer == EmptyView {
    /// Primary surface with a peeking secondary panel above.
    public init(
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.primary = primary()
        self.secondary = secondary()
        self.footer = nil
    }
}

extension ZenLayerCard where Secondary == EmptyView {
    /// Primary surface with a peeking footer panel below.
    public init(
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder footer: () -> Footer
    ) {
        self.primary = primary()
        self.secondary = nil
        self.footer = footer()
    }
}

extension ZenLayerCard where Secondary == EmptyView, Footer == EmptyView {
    /// A plain single-surface card.
    public init(@ViewBuilder primary: () -> Primary) {
        self.primary = primary()
        self.secondary = nil
        self.footer = nil
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
            Text("Primary content")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        } footer: {
            Text("Footer note")
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
        }

        ZenLayerCard {
            Text("Primary content")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        } secondary: {
            Text("Secondary header")
                .font(.zenBody2)
                .foregroundStyle(Color.zenTextMuted)
        } footer: {
            Text("Footer note")
                .font(.zenGroup)
                .foregroundStyle(Color.zenTextMuted)
        }

        ZenLayerCard {
            Text("Simple card without panels")
                .font(.zenBody)
                .foregroundStyle(Color.zenTextPrimary)
        }
    }
    .padding()
    .background(Color.zenBackground)
}
