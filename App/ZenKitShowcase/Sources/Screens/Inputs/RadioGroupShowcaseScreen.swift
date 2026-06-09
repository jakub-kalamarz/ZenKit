import SwiftUI
import ZenKit

struct RadioGroupShowcaseScreen: View {
    @State private var plan = "pro"
    @State private var frequency = "monthly"

    private let planOptions: [ZenRadioOption<String>] = [
        .init(value: "free", label: "Free", description: "Up to 3 projects"),
        .init(value: "pro", label: "Pro", description: "Unlimited projects"),
        .init(value: "enterprise", label: "Enterprise", description: "Custom limits"),
    ]

    private let frequencyOptions: [ZenRadioOption<String>] = [
        .init(value: "monthly", label: "Monthly"),
        .init(value: "yearly", label: "Yearly"),
    ]

    var body: some View {
        ShowcaseScreen(title: "Radio Group") {
            ZenCard(title: "Default", subtitle: "Standard radio buttons") {
                ZenRadioGroup(selection: $frequency, options: frequencyOptions)
            }

            ZenCard(title: "Card Appearance", subtitle: "Radio as selectable cards") {
                ZenRadioGroup(selection: $plan, appearance: .card, options: planOptions)
            }
        }
    }
}
