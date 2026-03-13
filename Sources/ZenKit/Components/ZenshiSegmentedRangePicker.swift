import SwiftUI

public struct ZenSegmentedRangePicker: View {
    private let title: String?
    @Binding private var selection: String
    private let options: [String]

    public init(title: String? = nil, selection: Binding<String>, options: [String]) {
        self.title = title
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        ZenSegmentedControl(
            title: title,
            selection: $selection,
            segments: options
        )
    }
}
