import SwiftUI
import ZenKit

struct CodeBlockShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Code Block") {
            ZenCard(title: "Basic", subtitle: "Code with language label and copy") {
                ZenCodeBlock("""
                let greeting = "Hello, World!"
                print(greeting)
                """, language: "Swift")
            }

            ZenCard(title: "Line Numbers", subtitle: "With numbered lines") {
                ZenCodeBlock("""
                struct ContentView: View {
                    @State private var count = 0

                    var body: some View {
                        Button("Count: \\(count)") {
                            count += 1
                        }
                    }
                }
                """, language: "Swift", showLineNumbers: true)
            }

            ZenCard(title: "No Language", subtitle: "Plain code block") {
                ZenCodeBlock("curl -X GET https://api.example.com/v1/users")
            }
        }
    }
}
