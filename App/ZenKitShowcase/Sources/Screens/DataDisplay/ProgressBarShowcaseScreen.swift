import SwiftUI
import ZenKit

struct ProgressBarShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Progress Bar") {
            ZenCard(title: "Progress Values", subtitle: "Various fill amounts") {
                VStack(alignment: .leading, spacing: ZenSpacing.medium) {
                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Empty")
                            .font(.zenTextXS)
                            .foregroundStyle(Color.zenTextMuted)
                        ZenProgressBar(progress: 0)
                    }

                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Uploading — 35%")
                            .font(.zenTextXS)
                            .foregroundStyle(Color.zenTextMuted)
                        ZenProgressBar(progress: 0.35)
                    }

                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Processing — 68%")
                            .font(.zenTextXS)
                            .foregroundStyle(Color.zenTextMuted)
                        ZenProgressBar(progress: 0.68)
                    }

                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Complete — 100%")
                            .font(.zenTextXS)
                            .foregroundStyle(Color.zenTextMuted)
                        ZenProgressBar(progress: 1)
                    }
                }
            }

            ZenCard(title: "In Context", subtitle: "Progress bar with surrounding labels") {
                VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                    HStack {
                        Text("Syncing workspace")
                            .font(.zenTextSM.weight(.medium))
                            .foregroundStyle(Color.zenTextPrimary)
                        Spacer()
                        Text("68%")
                            .font(.zenTextXS)
                            .foregroundStyle(Color.zenTextMuted)
                    }
                    ZenProgressBar(progress: 0.68)
                    Text("Estimated time remaining: 12s")
                        .font(.zenTextXS)
                        .foregroundStyle(Color.zenTextMuted)
                }
            }
        }
    }
}
