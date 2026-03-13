import Foundation
import SwiftUI
import Testing
@testable import ZenKit

struct ZenKitDropdownMenuTests {
    @Test
    func menuIconComposesInsideLabelBasedMenuRows() {
        let view = Label {
            Text("Profile")
        } icon: {
            ZenMenuIcon(assetName: "User")
        }

        _ = view
    }

    @Test
    func menuComposesTriggerItemsAndNestedContent() {
        let view = ZenMenu {
            ZenMenuTrigger {
                Text("Open")
            }
        } content: {
            ZenMenuContent {
                ZenMenuItem("Profile") {}
                ZenMenu {
                    ZenMenuItem("Team") {}
                } label: {
                    Text("More")
                }
                ZenMenuSeparator()
                ZenMenuItem("Delete", variant: .destructive) {}
            }
        }

        _ = view
    }
}
