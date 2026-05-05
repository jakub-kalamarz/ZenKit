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
            trailingIcon: .system("checkmark.circle.fill"),
            submitLabel: .next
        )

        _ = view
    }

    @Test
    func inputBarSupportsReturnSubmitAndLoadingState() {
        let view = VStack {
            ZenInputBar(
                text: .constant("Draft message"),
                prompt: "Ask anything",
                submitsOnReturn: true
            ) {}

            ZenInputBar(
                text: .constant("Sending message"),
                prompt: "Reply",
                isLoading: true
            ) {}

            ZenInputBar(
                text: .constant("Draft\nmessage"),
                prompt: "Reply",
                lineLimit: 1...3
            ) {}
        }

        _ = view
    }
}
