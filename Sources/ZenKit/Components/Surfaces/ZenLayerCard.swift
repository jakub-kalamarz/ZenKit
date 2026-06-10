import SwiftUI

public struct ZenLayerCard<Secondary: View, Primary: View>: View {
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
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        let cornerRadius = ZenTheme.current.resolvedCornerRadius

        VStack(spacing: 0) {
            if let secondary {
                secondary
                    .padding(ZenSpacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.zenSurfaceMuted)

                Divider()
                    .foregroundStyle(Color.zenBorderSubtle)
            }

            primary
                .padding(ZenSpacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.zenSurface)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.zenBorderSubtle, lineWidth: 1)
        )
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
