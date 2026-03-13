import SwiftUI

public struct ZenNavigationLink<Destination: View, Label: View>: View {
    @Environment(\.zenScreenNavigationContext) private var navigationContext

    private let destination: () -> Destination
    private let label: () -> Label

    public init(
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.destination = destination
        self.label = label
    }

    public var body: some View {
        NavigationLink {
            destination()
                .zenScreenNavigationContext(title: navigationContext.title)
        } label: {
            label()
        }
    }
}
