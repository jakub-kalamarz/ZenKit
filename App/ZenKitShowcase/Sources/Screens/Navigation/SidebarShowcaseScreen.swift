import SwiftUI
import ZenKit

struct SidebarShowcaseScreen: View {
    @State private var selectedId: String? = "dashboard"
    @State private var isCollapsed = false

    @State private var groupSelectedId: String? = "overview"
    @State private var groupCollapsed = false

    private var sampleGroups: [ZenSidebarGroup] {
        [
            ZenSidebarGroup(label: "Main", items: [
                .init(id: "dashboard", label: "Dashboard", icon: "square.grid.2x2"),
                .init(id: "analytics", label: "Analytics", icon: "chart.bar", badge: "New"),
                .init(id: "domains", label: "Domains", icon: "globe"),
            ]),
            ZenSidebarGroup(label: "Configure", items: [
                .init(id: "settings", label: "Settings", icon: "gearshape", children: [
                    .init(id: "general", label: "General"),
                    .init(id: "security", label: "Security"),
                    .init(id: "billing", label: "Billing"),
                ]),
                .init(id: "team", label: "Team", icon: "person.2", badge: "3"),
            ]),
        ]
    }

    var body: some View {
        ShowcaseScreen(title: "Sidebar") {
            ZenCard(title: "Flat Items", subtitle: "Simple sidebar with flat item list") {
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
                        ZenSidebarToggle(isCollapsed: $isCollapsed)
                        Text("Selected: \(selectedId ?? "none")")
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.zenBackground)
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            ZenCard(title: "Groups + Header/Footer", subtitle: "Sidebar with labeled groups, header, and footer") {
                HStack(spacing: 0) {
                    ZenSidebar(
                        groups: sampleGroups,
                        selectedId: $groupSelectedId,
                        isCollapsed: $groupCollapsed
                    ) {
                        HStack {
                            if !groupCollapsed {
                                Text("Workspace")
                                    .font(.zen(.body, weight: .semibold))
                                    .foregroundStyle(Color.zenTextStrong)
                            }
                            Spacer()
                            ZenSidebarToggle(isCollapsed: $groupCollapsed)
                        }
                    } footer: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.zenDisplayS)
                                .foregroundStyle(Color.zenTextMuted)
                            if !groupCollapsed {
                                Text("Account")
                                    .font(.zenBody2)
                                    .foregroundStyle(Color.zenTextPrimary)
                            }
                        }
                    }

                    VStack {
                        Text("Selected: \(groupSelectedId ?? "none")")
                            .font(.zenBody2)
                            .foregroundStyle(Color.zenTextMuted)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.zenBackground)
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
