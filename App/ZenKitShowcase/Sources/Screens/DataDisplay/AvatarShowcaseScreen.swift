import SwiftUI
import ZenKit

struct AvatarShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Avatar") {
            ZenCard(title: "Generated", subtitle: "Beam avatars from name seed") {
                HStack(spacing: ZenSpacing.medium) {
                    ZenAvatar(name: "Alex Morgan", imageURL: nil)
                    ZenAvatar(name: "Jamie Lee", imageURL: nil)
                    ZenAvatar(name: "Sam Rivera", imageURL: nil)
                    ZenAvatar(name: "Zen", imageURL: nil)
                }
            }

            ZenCard(title: "Sizes", subtitle: "Small, medium, and large") {
                HStack(alignment: .bottom, spacing: ZenSpacing.medium) {
                    ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 28)
                    ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 40)
                    ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 52)
                    ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 64)
                }
            }

            ZenCard(title: "In Context", subtitle: "Avatar in a list row") {
                VStack(spacing: ZenSpacing.small) {
                    ForEach([
                        ("Alex Morgan", "alex@example.com"),
                        ("Jamie Lee", "jamie@example.com"),
                        ("Sam Rivera", "sam@example.com")
                    ], id: \.0) { name, email in
                        HStack(spacing: ZenSpacing.small) {
                            ZenAvatar(name: name, imageURL: nil, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name)
                                    .font(.zenTextSM.weight(.medium))
                                    .foregroundStyle(Color.zenTextPrimary)
                                Text(email)
                                    .font(.zenTextXS)
                                    .foregroundStyle(Color.zenTextMuted)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
