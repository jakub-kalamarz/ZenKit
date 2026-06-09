import SwiftUI
import ZenKit

struct BreadcrumbsShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Breadcrumbs") {
            ZenCard(title: "Basic", subtitle: "Navigation path with separators") {
                ZenBreadcrumbs(items: [
                    .init(label: "Home", icon: "house", action: {}),
                    .init(label: "Settings", action: {}),
                    .init(label: "Account")
                ])
            }

            ZenCard(title: "Long Path", subtitle: "Multiple levels deep") {
                ZenBreadcrumbs(items: [
                    .init(label: "Dashboard", action: {}),
                    .init(label: "Projects", action: {}),
                    .init(label: "ZenKit", action: {}),
                    .init(label: "Components", action: {}),
                    .init(label: "Breadcrumbs")
                ])
            }
        }
    }
}
