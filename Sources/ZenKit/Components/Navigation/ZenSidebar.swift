import SwiftUI

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

public struct ZenSidebar: View {
    private let items: [ZenSidebarItem]
    @Binding private var selectedId: String?
    @Binding private var isCollapsed: Bool

    public init(
        items: [ZenSidebarItem],
        selectedId: Binding<String?>,
        isCollapsed: Binding<Bool> = .constant(false)
    ) {
        self.items = items
        self._selectedId = selectedId
        self._isCollapsed = isCollapsed
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(items) { item in
                sidebarRow(item, depth: 0)
            }
        }
        .padding(ZenSpacing.small)
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(width: isCollapsed ? 52 : 240)
        .background(Color.zenSurface)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.zenBorderSubtle)
                .frame(width: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isCollapsed)
    }

    private func sidebarRow(_ item: ZenSidebarItem, depth: Int) -> AnyView {
        let isSelected = item.id == selectedId

        let row = Button {
            selectedId = item.id
        } label: {
            HStack(spacing: ZenSpacing.small) {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(isSelected ? Color.zenPrimary : Color.zenTextMuted)
                        .frame(width: 20)
                }

                if !isCollapsed {
                    Text(item.label)
                        .font(.zenBody2)
                        .foregroundStyle(isSelected ? Color.zenPrimary : Color.zenTextPrimary)
                        .lineLimit(1)

                    Spacer()

                    if let badge = item.badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.zenTextMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.zenSurfaceMuted)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .padding(.leading, CGFloat(depth) * 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                    ? Color.zenPrimary.opacity(0.1)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        return AnyView(VStack(alignment: .leading, spacing: 2) {
            row
            if !isCollapsed {
                ForEach(item.children) { child in
                    sidebarRow(child, depth: depth + 1)
                }
            }
        })
    }
}

#Preview("ZenSidebar") {
    struct SidebarPreview: View {
        @State private var selectedId: String? = "dashboard"
        @State private var collapsed = false

        var body: some View {
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
                    isCollapsed: $collapsed
                )

                VStack {
                    Button(collapsed ? "Expand" : "Collapse") {
                        collapsed.toggle()
                    }
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
