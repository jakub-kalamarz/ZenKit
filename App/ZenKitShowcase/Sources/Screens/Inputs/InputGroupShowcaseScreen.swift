import SwiftUI
import ZenKit

struct InputGroupShowcaseScreen: View {
    @State private var url = ""
    @State private var amount = ""

    var body: some View {
        ShowcaseScreen(title: "Input Group") {
            ZenCard(title: "Leading Addon", subtitle: "Text prefix before input") {
                ZenInputGroup(text: $url, placeholder: "example.com") {
                    Text("https://")
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.leading, 12)
                } trailing: {
                    EmptyView()
                }
            }

            ZenCard(title: "Trailing Addon", subtitle: "Button after input") {
                ZenInputGroup(text: $amount, placeholder: "0.00") {
                    Text("$")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.leading, 12)
                } trailing: {
                    Text("USD")
                        .font(.zenBody2)
                        .foregroundStyle(Color.zenTextMuted)
                        .padding(.trailing, 12)
                }
            }
        }
    }
}
