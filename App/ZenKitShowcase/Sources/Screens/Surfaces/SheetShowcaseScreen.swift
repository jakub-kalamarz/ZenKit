import SwiftUI
import ZenKit

struct SheetShowcaseScreen: View {
    @State private var isPresented = false
    @State private var email = "alex@example.com"

    var body: some View {
        ShowcaseScreen(title: "Sheet") {
            ZenCard(
                title: "Sheet",
                subtitle: "The sheet uses a detent selected for its content."
            ) {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    Text("Open the sheet to preview a compact form presentation.")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)

                    ZenButton("Open sheet", fullWidth: true) {
                        isPresented = true
                    }
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            ZenSheetContainer(
                title: "Invite collaborator",
                subtitle: "Add teammates by email",
                toolbarLeading: {
                    ZenButton("Cancel", variant: .glass, size: .sm) {
                        isPresented = false
                    }
                },
                toolbarTrailing: {
                    ZenButton("Send", variant: .glassProminent, size: .sm) {}
                }
            ) {
                ZenFieldGroup {
                    ZenField(label: "Email", message: "We'll send the invite here.") {
                        ZenTextInput(text: $email, prompt: "Email")
                    }
                }
            }
            .presentationDetents([.height(330)])
            .presentationBackground(Color.zenBackground)
        }
    }
}
