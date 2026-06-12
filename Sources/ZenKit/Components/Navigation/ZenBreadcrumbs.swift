import SwiftUI

public struct ZenBreadcrumbItem: Identifiable {
    public let id: String
    public let label: String
    public let icon: String?
    public let action: (() -> Void)?

    public init(id: String = UUID().uuidString, label: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.id = id
        self.label = label
        self.icon = icon
        self.action = action
    }
}

public struct ZenBreadcrumbs: View {
    private let items: [ZenBreadcrumbItem]

    public init(items: [ZenBreadcrumbItem]) {
        self.items = items
    }

    public var body: some View {
        #if DEBUG
        #endif
        HStack(spacing: ZenSpacing.xSmall) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.zenTextMuted)
                }

                if let action = item.action, index < items.count - 1 {
                    Button(action: action) {
                        breadcrumbLabel(item: item, isCurrent: false)
                    }
                    .buttonStyle(.plain)
                } else {
                    breadcrumbLabel(item: item, isCurrent: index == items.count - 1)
                }
            }
        }
    }

    private func breadcrumbLabel(item: ZenBreadcrumbItem, isCurrent: Bool) -> some View {
        HStack(spacing: 4) {
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.zenGroup)
            }
            Text(item.label)
                .font(.zenBody2)
        }
        .foregroundStyle(isCurrent ? Color.zenTextPrimary : Color.zenTextMuted)
    }
}

#Preview("ZenBreadcrumbs") {
    ZenBreadcrumbs(items: [
        .init(label: "Home", icon: "house", action: {}),
        .init(label: "Settings", action: {}),
        .init(label: "Account")
    ])
    .padding()
    .background(Color.zenBackground)
}
