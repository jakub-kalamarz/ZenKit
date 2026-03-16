import SwiftUI
import ZenKit

struct StepperShowcaseScreen: View {
    @State private var quantity = 1
    @State private var pages = 10
    @State private var temperature = 20.0
    @State private var rating = 3.5

    var body: some View {
        ShowcaseScreen(title: "Stepper") {
            ZenCard(title: "Integer", subtitle: "Whole number increment") {
                VStack(spacing: ZenSpacing.small) {
                    ZenStepper("Quantity", value: $quantity, in: 1...20)
                    ZenStepper("Pages", subtitle: "Max 100", value: $pages, in: 1...100, step: 5)
                }
            }

            ZenCard(title: "Decimal", subtitle: "Float point values") {
                VStack(spacing: ZenSpacing.small) {
                    ZenStepper(
                        "Temperature",
                        subtitle: "Degrees Celsius",
                        value: $temperature,
                        in: -10...40,
                        step: 0.5
                    )
                    ZenStepper(
                        "Rating",
                        value: $rating,
                        in: 0...5,
                        step: 0.5
                    )
                }
            }
        }
    }
}
