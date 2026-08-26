import SwiftUI
import ZenKit

struct LoginShowcaseScreen: View {
    enum LoginMethod: String, CaseIterable, Identifiable {
        case emailPassword = "Email + Password"
        case magicLink = "Magic Link"

        var id: Self { self }
    }

    @State private var loginMethod: LoginMethod = .emailPassword
    @State private var email = ""
    @State private var password = ""
    @State private var didSubmit = false

    var body: some View {
        ShowcaseScreen(title: "Login") {
            ZenCard(
                title: "Authentication",
                subtitle: "Choose how you want to sign in"
            ) {
                ZenFieldSection {
                    ZenFieldGroup {
                        ZenField(label: "Login method") {
                            Picker("Login method", selection: $loginMethod) {
                                ForEach(LoginMethod.allCases) { method in
                                    Text(method.rawValue).tag(method)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        if loginMethod == .emailPassword {
                            ZenField(label: "Email") {
                                ZenTextInput(
                                    text: $email,
                                    prompt: "Email",
                                    leadingIcon: .hugeIcon(.envelope)
                                )
                            }

                            ZenField(label: "Password") {
                                ZenTextInput(
                                    text: $password,
                                    prompt: "Password",
                                    leadingIcon: .hugeIcon(.lock),
                                    kind: .secure
                                )
                            }

                            ZenButton("Login", fullWidth: true) {
                                didSubmit = true
                            }
                        } else {
                            ZenStatusBanner(tone: .warning, message: "Switch to Email + Password to sign in with a password.")

                            ZenButton("Send Magic Link", variant: .secondary, fullWidth: true) {
                                didSubmit = false
                            }
                        }
                    }
                }
            }

            if didSubmit, loginMethod == .emailPassword {
                ZenStatusBanner(
                    tone: .success,
                    message: "Ready to sign in."
                )
            }
        }
    }
}
