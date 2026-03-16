import SwiftUI
import ZenKit

struct RatingShowcaseScreen: View {
    @State private var reviewRating = 4
    @State private var qualityRating = 3
    @State private var easeRating = 5

    var body: some View {
        ShowcaseScreen(title: "Rating") {
            ZenCard(title: "Interactive", subtitle: "Tap stars to rate") {
                VStack(spacing: ZenSpacing.small) {
                    ZenRatingRow("Overall", value: $reviewRating)
                    ZenRatingRow("Quality", value: $qualityRating)
                    ZenRatingRow("Ease of use", value: $easeRating)
                }
            }

            ZenCard(title: "Display Only", subtitle: "Read-only star display") {
                VStack(spacing: ZenSpacing.small) {
                    HStack {
                        ZenRating(value: 5)
                        Spacer()
                        Text("Excellent")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                    HStack {
                        ZenRating(value: 3)
                        Spacer()
                        Text("Average")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                    HStack {
                        ZenRating(value: 1)
                        Spacer()
                        Text("Poor")
                            .font(.zenCaption)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                }
            }

            ZenCard(title: "Custom Scale", subtitle: "3-star scale") {
                ZenRatingRow("Priority", value: $qualityRating, maximum: 3)
            }
        }
    }
}
