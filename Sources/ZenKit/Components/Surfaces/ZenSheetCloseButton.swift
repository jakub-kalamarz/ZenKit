import SwiftUI

/// The close control for a `ZenSheetContainer`'s leading toolbar slot, so every sheet
/// dismisses with the same glyph, weight and hit area.
public struct ZenSheetCloseButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        ZenButton(variant: .plain, size: .icon, action: action) {
            ZenIcon(icon: .xmark, size: 17)
                .foregroundStyle(Color.zenTextPrimary)
        }
        .accessibilityLabel(Text("Close", bundle: .module))
    }
}

#Preview {
    Color.zenBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ZenSheetContainer(
                title: "Share workspace",
                toolbarLeading: {
                    ZenSheetCloseButton {}
                },
                toolbarTrailing: {
                    EmptyView()
                }
            ) {
                Text("Sheet content")
                    .font(.zenBody2)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
}
