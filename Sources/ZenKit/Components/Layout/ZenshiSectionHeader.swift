import SwiftUI

public struct ZenSectionHeader<Title: View, Subtitle: View>: View {
    private let title: () -> Title
    private let subtitle: () -> Subtitle
    private let showsSubtitle: Bool

    public init(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder subtitle: @escaping () -> Subtitle
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showsSubtitle = true
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            title()
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            if showsSubtitle {
                subtitle()
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .textCase(nil)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ZenSpacing.small)
        .padding(.top, ZenSpacing.small)
    }
}

public extension ZenSectionHeader where Subtitle == EmptyView {
    init(@ViewBuilder title: @escaping () -> Title) {
        self.title = title
        self.subtitle = { EmptyView() }
        self.showsSubtitle = false
    }
}

#Preview {
    ZenSection {
        Text("Row")
    } header: {
        ZenSectionHeader {
            Text("Workspace")
        } subtitle: {
            Text("Shared settings")
        }
    }
    .padding()
    .background(Color.zenBackground)
}
