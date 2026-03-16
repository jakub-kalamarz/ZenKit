import SwiftUI
import ZenKit

struct MenuShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Menu") {
            ZenCard(title: "Basic Menu", subtitle: "Standard items with separator and destructive action") {
                HStack {
                    ZenMenu {
                        ZenMenuTrigger {
                            ZenButton("Open menu", variant: .outline) {}
                                .allowsHitTesting(false)
                        }
                    } content: {
                        ZenMenuContent {
                            ZenMenuItem("Edit") {}
                            ZenMenuItem("Duplicate") {}
                            ZenMenuSeparator()
                            ZenMenuItem("Delete", variant: .destructive) {}
                        }
                    }
                    Spacer()
                }
            }

            ZenCard(title: "Avatar Trigger", subtitle: "Menu triggered from an avatar") {
                HStack {
                    ZenMenu {
                        ZenMenuTrigger {
                            ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 40)
                        }
                    } content: {
                        ZenMenuContent {
                            ZenMenuItem("Profile") {}
                            ZenMenuItem("Settings") {}
                            ZenMenuSeparator()
                            ZenMenuItem("Sign out", variant: .destructive) {}
                        }
                    }
                    Spacer()
                }
            }

            ZenCard(title: "Icon Button Trigger", subtitle: "Ellipsis menu trigger") {
                HStack {
                    ZenMenu {
                        ZenMenuTrigger {
                            ZenButton("Mama", action: {})
                            .allowsHitTesting(false)
                        }
                    } content: {
                        ZenMenuContent {
                            ZenMenuItem("Rename") {}
                            ZenMenuItem("Move") {}
                            ZenMenuSeparator()
                            ZenMenuItem("Archive", variant: .destructive) {}
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
