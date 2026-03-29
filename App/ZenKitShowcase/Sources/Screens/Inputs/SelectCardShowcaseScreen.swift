import SwiftUI
import ZenKit

struct SelectCardShowcaseScreen: View {
    private enum Feature: String, CaseIterable {
        case payments = "Payments"
        case invoices = "Invoices"
        case billing = "Billing"
        case reports = "Reports"

        var subtitle: String {
            switch self {
            case .payments:
                "Receive payments from your customers"
            case .invoices:
                "Create and send invoices to your customers"
            case .billing:
                "Manage your billing and subscriptions"
            case .reports:
                "View your reports and analytics"
            }
        }

        var icon: String {
            switch self {
            case .payments:
                "CursorClick"
            case .invoices:
                "PaperPlane"
            case .billing:
                "CreditCard"
            case .reports:
                "ChartBar"
            }
        }
    }

    private enum Plan: String, CaseIterable {
        case free = "Free"
        case pro = "Pro"
        case enterprise = "Enterprise"

        var price: String {
            switch self {
            case .free:
                "$0/mo"
            case .pro:
                "$19/mo"
            case .enterprise:
                "$49/mo"
            }
        }

        var subtitle: String {
            switch self {
            case .free:
                "For personal projects and experiments."
            case .pro:
                "For professionals and small teams."
            case .enterprise:
                "For organizations with advanced needs."
            }
        }
    }

    private enum PaymentMethod: String, CaseIterable {
        case visa = "Visa ending in 4242"
        case mastercard = "Mastercard ending in 8888"

        var subtitle: String {
            switch self {
            case .visa:
                "Expires 12/26"
            case .mastercard:
                "Expires 09/25"
            }
        }

        var icon: String {
            switch self {
            case .visa:
                "CreditCard"
            case .mastercard:
                "CreditCard"
            }
        }

        var iconColor: Color {
            switch self {
            case .visa:
                .blue
            case .mastercard:
                .orange
            }
        }
    }

    @State private var selectedPlanCard = "Plus"
    @State private var selectedFeature: Feature = .payments
    @State private var selectedPricingPlan: Plan = .pro
    @State private var selectedPaymentMethod: PaymentMethod = .visa

    private let featureColumns = [
        GridItem(.flexible(), spacing: ZenSpacing.medium),
        GridItem(.flexible(), spacing: ZenSpacing.medium),
    ]

    var body: some View {
        ShowcaseScreen(title: "Select Card") {
            ZenCard(title: "Vertical Plans", subtitle: "Simple single-choice cards for short plan lists") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenSelectCard(
                        title: "Plus",
                        subtitle: "For individuals and small teams.",
                        isSelected: selectedPlanCard == "Plus"
                    ) {
                        selectedPlanCard = "Plus"
                    }

                    ZenSelectCard(
                        title: "Pro",
                        subtitle: "For growing businesses.",
                        isSelected: selectedPlanCard == "Pro"
                    ) {
                        selectedPlanCard = "Pro"
                    }
                }
            }

            ZenCard(title: "Feature Grid", subtitle: "Use with a regular grid when options should stay visible") {
                LazyVGrid(columns: featureColumns, spacing: ZenSpacing.medium) {
                    ForEach(Feature.allCases, id: \.self) { feature in
                        ZenSelectCard(
                            title: feature.rawValue,
                            subtitle: feature.subtitle,
                            leadingIconSource: .asset(feature.icon),
                            isSelected: selectedFeature == feature
                        ) {
                            selectedFeature = feature
                        }
                    }
                }
            }

            ZenCard(title: "Pricing", subtitle: "Longer labels still read clearly in stacked radio-card layouts") {
                VStack(spacing: ZenSpacing.medium) {
                    ForEach(Plan.allCases, id: \.self) { plan in
                        ZenSelectCard(
                            title: "\(plan.rawValue)  \(plan.price)",
                            subtitle: plan.subtitle,
                            isSelected: selectedPricingPlan == plan
                        ) {
                            selectedPricingPlan = plan
                        }
                    }
                }
            }

            ZenCard(title: "Payment Methods", subtitle: "Rich cards and a compact CTA row can share the same primitive") {
                VStack(spacing: ZenSpacing.medium) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        ZenSelectCard(
                            title: method.rawValue,
                            subtitle: method.subtitle,
                            leadingIconSource: .asset(method.icon),
                            iconColor: method.iconColor,
                            isSelected: selectedPaymentMethod == method
                        ) {
                            selectedPaymentMethod = method
                        }
                    }

                    ZenSelectCard(
                        title: "Add new payment method",
                        leadingIconSource: .asset("Plus"),
                        variant: .inline,
                        isSelected: false
                    ) {}
                }
            }
        }
    }
}
