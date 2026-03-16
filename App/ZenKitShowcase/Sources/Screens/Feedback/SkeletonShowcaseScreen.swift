import SwiftUI
import ZenKit

struct SkeletonShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Skeleton") {
            ZenCard(title: "Sizes", subtitle: "Different widths and heights") {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenSkeleton(width: 120, height: 14)
                    ZenSkeleton(height: 44)
                    ZenSkeleton(width: 200, height: 14)
                    ZenSkeleton(height: 44)
                }
            }

            ZenCard(title: "Corner Radius", subtitle: "Pill and rounded shapes") {
                HStack(spacing: ZenSpacing.small) {
                    ZenSkeleton(width: 80, height: 28, cornerRadius: 14)
                    ZenSkeleton(width: 64, height: 28, cornerRadius: 14)
                    ZenSkeleton(width: 96, height: 28, cornerRadius: 14)
                }
            }

            ZenCard(title: "List Skeleton", subtitle: "Simulated list loading state") {
                VStack(spacing: ZenSpacing.medium) {
                    ForEach(0..<3) { _ in
                        HStack(spacing: ZenSpacing.small) {
                            ZenSkeleton(width: 38, height: 38, cornerRadius: 10)
                            VStack(alignment: .leading, spacing: 6) {
                                ZenSkeleton(width: 140, height: 13)
                                ZenSkeleton(width: 100, height: 11)
                            }
                            Spacer()
                            ZenSkeleton(width: 48, height: 13)
                        }
                    }
                }
            }
        }
    }
}
