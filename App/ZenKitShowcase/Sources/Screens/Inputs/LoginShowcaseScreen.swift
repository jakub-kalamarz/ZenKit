import SwiftUI
import ZenKit

struct LoginShowcaseScreen: View {
    enum LoginMethod: String, CaseIterable, Identifiable {
        case emailPassword = "Email + Password"
        case magicLink = "Magic Link"

        var id: Self { self }
    }

    @State private var loginMethod: LoginMethod = .emailPassword
    @State private var email = "debug@example.com"
    @State private var password = "debug123"
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
                            ZenField(
                                label: "Email",
                                message: "Prefilled for the debug account."
                            ) {
                                ZenTextInput(
                                    text: $email,
                                    prompt: "Email",
                                    leadingIcon: .asset("Envelope")
                                )
                            }

                            ZenField(
                                label: "Password",
                                message: "Prefilled debug password."
                            ) {
                                ZenTextInput(
                                    text: $password,
                                    prompt: "Password",
                                    leadingIcon: .asset("LockClosed"),
                                    kind: .secure
                                )
                            }

                            ZenButton("Login", fullWidth: true) {
                                didSubmit = true
                            }
                        } else {
                            ZenStatusBanner(
                                tone: .warning,
                                message: "Switch to Email + Password to use the debug login: debug@example.com / debug123."
                            )

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
                    message: "Ready to sign in as debug@example.com."
                )
            }
        }
    }
}
