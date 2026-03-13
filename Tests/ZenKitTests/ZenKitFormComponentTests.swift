import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitFormComponentTests {
    @Test
    func textInputCanShareFieldValidationState() {
        let view = ZenField(
            label: "Email",
            message: "Enter a valid email",
            state: .invalid
        ) {
            ZenTextInput(text: .constant("bad"), prompt: "Email", state: .invalid)
        }

        _ = view
    }

    @Test
    func textInputSupportsTrailingAccessoryAndSubmitLabel() {
        let view = ZenTextInput(
            text: .constant("alex@example.com"),
            prompt: "Email",
            trailingIconAsset: "CheckCircle",
            submitLabel: .next
        )

        _ = view
    }
}
