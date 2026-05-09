import SwiftUI

struct ZenContentHugging: Layout {
    var horizontal: Bool = true
    var vertical: Bool = true

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let child = subviews.first else { return .zero }
        let ideal = child.sizeThatFits(.unspecified)
        return CGSize(
            width: horizontal ? min(ideal.width, proposal.width ?? .infinity) : (proposal.width ?? ideal.width),
            height: vertical ? min(ideal.height, proposal.height ?? .infinity) : (proposal.height ?? ideal.height)
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let child = subviews.first else { return }
        child.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
    }
}

extension View {
    func zenContentHugging(horizontal: Bool = true, vertical: Bool = true) -> some View {
        ZenContentHugging(horizontal: horizontal, vertical: vertical) { self }
    }
}
