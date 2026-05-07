import SwiftUI
import ZenKit

struct SheetShowcaseScreen: View {
    @State private var isPresented = false
    @State private var email = "alex@example.com"
    @State private var includeMessage = false
    @State private var message = "Excited to collaborate on the next release."

    var body: some View {
        ShowcaseScreen(title: "Sheet") {
            ZenCard(
                title: "Auto-sizing Sheet",
                subtitle: "The sheet grows and shrinks to match its current content."
            ) {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    Text("Open the sheet, then toggle the extra message field to watch the detent update.")
                        .font(.zenTextBase)
                        .foregroundStyle(Color.zenTextMuted)

                    ZenButton("Open auto-sizing sheet", fullWidth: true) {
                        isPresented = true
                    }
                }
            }
        }
        .zenAutoSizingSheet(isPresented: $isPresented) {
            ZenSheetContainer(
                title: "Invite collaborator",
                subtitle: "Adjust the content while the sheet is open."
            ) {
                ZenFieldGroup {
                    ZenField(label: "Email", message: "We’ll send the invite here.") {
                        ZenTextInput(text: $email, prompt: "Email")
                    }

                    ZenToggle("Include a personal note", isOn: $includeMessage)

                    if includeMessage {
                        ZenField(
                            label: "Message",
                            message: "This additional field demonstrates dynamic height changes."
                        ) {
                            ZenTextInput(text: $message, prompt: "Optional note")
                        }
                    }
                }
            } footer: {
                HStack(spacing: ZenSpacing.small) {
                    ZenButton("Cancel", variant: .secondary) {
                        isPresented = false
                    }
                    ZenButton("Send invite") {}
                }
            }
        }
    }
}
