import SwiftUI
import ZenKit

struct EmptyStateShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Empty State") {
            ZenCard(title: "With Icon", subtitle: "Icon, title, description, and action") {
                ZenEmpty {
                    ZenEmptyHeader {
                        ZenEmptyMedia(variant: .icon) {
                            ZenIcon(systemName: "magnifyingglass", size: 24)
                        }
                        ZenEmptyTitle {
                            Text("No results found")
                        }
                        ZenEmptyDescription {
                            Text("Try adjusting your search or filter to find what you're looking for.")
                        }
                    }
                    ZenEmptyContent {
                        ZenButton("Clear filters") {}
                    }
                }
                .padding(.vertical, ZenSpacing.medium)
            }

            ZenCard(title: "Error State", subtitle: "Critical empty state with retry") {
                ZenEmpty {
                    ZenEmptyHeader {
                        ZenEmptyMedia(variant: .icon) {
                            ZenIcon(systemName: "exclamationmark.triangle.fill", size: 24)
                        }
                        ZenEmptyTitle {
                            Text("Something went wrong")
                        }
                        ZenEmptyDescription {
                            Text("We couldn't load your data. Please try again.")
                        }
                    }
                    ZenEmptyContent {
                        ZenButton("Retry") {}
                    }
                }
                .padding(.vertical, ZenSpacing.medium)
            }

            ZenCard(title: "No Content", subtitle: "Empty state prompting action") {
                ZenEmpty {
                    ZenEmptyHeader {
                        ZenEmptyMedia(variant: .icon) {
                            ZenIcon(systemName: "plus.circle", size: 24)
                        }
                        ZenEmptyTitle {
                            Text("No projects yet")
                        }
                        ZenEmptyDescription {
                            Text("Create your first project to get started.")
                        }
                    }
                    ZenEmptyContent {
                        ZenButton("Create project") {}
                    }
                }
                .padding(.vertical, ZenSpacing.medium)
            }
        }
    }
}
