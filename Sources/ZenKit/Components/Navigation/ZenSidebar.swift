import SwiftUI

// MARK: - Data Models

public struct ZenSidebarItem: Identifiable {
    public let id: String
    public let label: String
    public let icon: String?
    public let badge: String?
    public let children: [ZenSidebarItem]

    public init(
        id: String,
        label: String,
        icon: String? = nil,
        badge: String? = nil,
        children: [ZenSidebarItem] = []
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.badge = badge
        self.children = children
    }
}

public struct ZenSidebarGroup: Identifiable {
    public let id: String
    public let label: String?
    public let items: [ZenSidebarItem]

    public init(id: String = UUID().uuidString, label: String? = nil, items: [ZenSidebarItem]) {
        self.id = id
        self.label = label
        self.items = items
    }
}

// MARK: - Sidebar

public struct ZenSidebar<Header: View, Footer: View>: View {
    private let groups: [ZenSidebarGroup]
    @Binding private var selectedId: String?
    @Binding private var isCollapsed: Bool
    private let header: Header?
    private let footer: Footer?

    @State private var expandedSections: Set<String> = []

    private let expandedWidth: CGFloat = 260
    private let collapsedWidth: CGFloat = 57

    public init(
        groups: [ZenSidebarGroup],
        selectedId: Binding<String?>,
        isCollapsed: Binding<Bool> = .constant(false),
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.groups = groups
        self._selectedId = selectedId
        self._isCollapsed = isCollapsed
        self.header = header()
        self.footer = footer()
    }

    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        VStack(spacing: 0) {
            if let header {
                header
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 58)
                    .padding(.horizontal, isCollapsed ? 8 : 14)
                    .clipped()
            }

            Divider().foregroundStyle(Color.zenBorderSubtle)

            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(groups) { group in
                        sidebarGroup(group)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, isCollapsed ? 8 : 10)
            }

            if let footer {
                Divider().foregroundStyle(Color.zenBorderSubtle)

                footer
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 48)
                    .padding(.horizontal, isCollapsed ? 8 : 14)
                    .clipped()
            }
        }
        .frame(width: isCollapsed ? collapsedWidth : expandedWidth)
        .frame(maxHeight: .infinity)
        .background(Color.zenSurface)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.zenBorderSubtle)
                .frame(width: 1)
        }
        .animation(.easeInOut(duration: 0.25), value: isCollapsed)
    }

    // MARK: - Group

    @ViewBuilder
    private func sidebarGroup(_ group: ZenSidebarGroup) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            if let label = group.label, !isCollapsed {
                Text(label)
                    .font(.zen(.group, weight: .medium))
                    .foregroundStyle(Color.zenTextMuted)
                    .padding(.horizontal, 10)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
            }

            ForEach(group.items) { item in
                menuItem(item, depth: 0)
            }
        }
    }

    // MARK: - Menu Item

    private func menuItem(_ item: ZenSidebarItem, depth: Int) -> AnyView {
        let isSelected = item.id == selectedId
        let hasChildren = !item.children.isEmpty
        let isExpanded = expandedSections.contains(item.id)

        let row = Button {
            if hasChildren {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded {
                        expandedSections.remove(item.id)
                    } else {
                        expandedSections.insert(item.id)
                    }
                }
            } else {
                selectedId = item.id
            }
        } label: {
            HStack(spacing: ZenSpacing.small) {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(isSelected ? Color.zenPrimary : Color.zenTextMuted)
                        .frame(width: 22, height: 22)
                }

                if !isCollapsed {
                    Text(item.label)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(isSelected ? Color.zenPrimary : Color.zenTextPrimary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    if let badge = item.badge {
                        Text(badge)
                            .font(.zen(.tab, weight: .medium))
                            .foregroundStyle(Color.zenTextStrong)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.zenSurfaceMuted)
                            .clipShape(Capsule())
                    }

                    if hasChildren {
                        Image(systemName: "chevron.right")
                            .font(.zen(.tab, weight: .semibold))
                            .foregroundStyle(Color.zenTextMuted)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .padding(.leading, isCollapsed ? 0 : CGFloat(depth) * 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? Color.zenSurfaceTint : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)

        return AnyView(VStack(alignment: .leading, spacing: 1) {
            row

            if hasChildren && isExpanded && !isCollapsed {
                ForEach(item.children) { child in
                    menuItem(child, depth: depth + 1)
                }
            }
        })
    }
}

// MARK: - Convenience Inits

extension ZenSidebar where Header == EmptyView, Footer == EmptyView {
    public init(
        groups: [ZenSidebarGroup],
        selectedId: Binding<String?>,
        isCollapsed: Binding<Bool> = .constant(false)
    ) {
        self.groups = groups
        self._selectedId = selectedId
        self._isCollapsed = isCollapsed
        self.header = nil
        self.footer = nil
    }
}

extension ZenSidebar where Footer == EmptyView {
    public init(
        groups: [ZenSidebarGroup],
        selectedId: Binding<String?>,
        isCollapsed: Binding<Bool> = .constant(false),
        @ViewBuilder header: () -> Header
    ) {
        self.groups = groups
        self._selectedId = selectedId
        self._isCollapsed = isCollapsed
        self.header = header()
        self.footer = nil
    }
}

extension ZenSidebar where Header == EmptyView {
    public init(
        groups: [ZenSidebarGroup],
        selectedId: Binding<String?>,
        isCollapsed: Binding<Bool> = .constant(false),
        @ViewBuilder footer: () -> Footer
    ) {
        self.groups = groups
        self._selectedId = selectedId
        self._isCollapsed = isCollapsed
        self.header = nil
        self.footer = footer()
    }
}

// MARK: - Flat items convenience

extension ZenSidebar where Header == EmptyView, Footer == EmptyView {
    public init(
        items: [ZenSidebarItem],
        selectedId: Binding<String?>,
        isCollapsed: Binding<Bool> = .constant(false)
    ) {
        self.groups = [ZenSidebarGroup(items: items)]
        self._selectedId = selectedId
        self._isCollapsed = isCollapsed
        self.header = nil
        self.footer = nil
    }
}

// MARK: - Toggle Button

public struct ZenSidebarToggle: View {
    @Binding private var isCollapsed: Bool

    public init(isCollapsed: Binding<Bool>) {
        self._isCollapsed = isCollapsed
    }

    public var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isCollapsed.toggle()
            }
        } label: {
            Image(systemName: "sidebar.left")
                .font(.zen(.body2, weight: .medium))
                .foregroundStyle(Color.zenTextMuted)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCollapsed ? "Expand sidebar" : "Collapse sidebar")
    }
}

// MARK: - Preview

#Preview("ZenSidebar") {
    struct SidebarPreview: View {
        @State private var selectedId: String? = "dashboard"
        @State private var collapsed = false

        var body: some View {
            HStack(spacing: 0) {
                ZenSidebar(
                    groups: [
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
                    ],
                    selectedId: $selectedId,
                    isCollapsed: $collapsed
                ) {
                    HStack {
                        if !collapsed {
                            Text("Workspace")
                                .font(.zen(.body, weight: .semibold))
                                .foregroundStyle(Color.zenTextStrong)
                        }
                        Spacer()
                        ZenSidebarToggle(isCollapsed: $collapsed)
                    }
                } footer: {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.zenDisplayS)
                            .foregroundStyle(Color.zenTextMuted)
                        if !collapsed {
                            Text("Account")
                                .font(.zenBody2)
                                .foregroundStyle(Color.zenTextPrimary)
                        }
                    }
                }

                VStack {
                    Text("Selected: \(selectedId ?? "none")")
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.zenBackground)
            }
        }
    }

    return SidebarPreview()
}
