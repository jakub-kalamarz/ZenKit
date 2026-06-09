import SwiftUI
import ZenKit

struct SidebarShowcaseScreen: View {
    @State private var selectedId: String? = "dashboard"
    @State private var isCollapsed = false

    var body: some View {
        ShowcaseScreen(title: "Sidebar") {
            ZenCard(title: "Basic", subtitle: "Collapsible navigation sidebar") {
                HStack(spacing: 0) {
                    ZenSidebar(
                        items: [
                            .init(id: "dashboard", label: "Dashboard", icon: "square.grid.2x2"),
                            .init(id: "analytics", label: "Analytics", icon: "chart.bar", badge: "New"),
                            .init(id: "settings", label: "Settings", icon: "gearshape", children: [
                                .init(id: "general", label: "General"),
                                .init(id: "security", label: "Security"),
                            ]),
                            .init(id: "team", label: "Team", icon: "person.2", badge: "3"),
                        ],
                        selectedId: $selectedId,
                        isCollapsed: $isCollapsed
                    )

                    VStack {
                        Button(isCollapsed ? "Expand" : "Collapse") {
                            withAnimation { isCollapsed.toggle() }
                        }
                        .font(.zenBody2)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.zenBackground)
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
