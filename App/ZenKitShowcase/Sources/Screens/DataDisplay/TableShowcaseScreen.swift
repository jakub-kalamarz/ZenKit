import SwiftUI
import ZenKit

private struct User: Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String
}

struct TableShowcaseScreen: View {
    @State private var selection: Set<Int> = []

    private let users = [
        User(id: 1, name: "Alice Johnson", email: "alice@example.com", role: "Admin"),
        User(id: 2, name: "Bob Smith", email: "bob@example.com", role: "Editor"),
        User(id: 3, name: "Charlie Lee", email: "charlie@example.com", role: "Viewer"),
        User(id: 4, name: "Diana Park", email: "diana@example.com", role: "Editor"),
    ]

    var body: some View {
        ShowcaseScreen(title: "Table") {
            ZenCard(title: "Selectable Table", subtitle: "With checkbox selection") {
                ZenTable(
                    rows: users,
                    columns: [
                        ZenTableColumn(id: "name", title: "Name") { user in
                            Text(user.name)
                                .font(.zenBody)
                                .foregroundStyle(Color.zenTextPrimary)
                        },
                        ZenTableColumn(id: "email", title: "Email") { user in
                            Text(user.email)
                                .font(.zenBody)
                                .foregroundStyle(Color.zenTextMuted)
                        },
                        ZenTableColumn(id: "role", title: "Role", width: .fixed(100)) { user in
                            ZenBadge(LocalizedStringKey(user.role))
                        },
                    ],
                    selectable: true,
                    selection: $selection
                )
            }

            ZenCard(title: "Read-Only Table", subtitle: "Without selection") {
                ZenTable(
                    rows: Array(users.prefix(3)),
                    columns: [
                        ZenTableColumn(id: "name", title: "Name") { user in
                            Text(user.name)
                                .font(.zenBody)
                                .foregroundStyle(Color.zenTextPrimary)
                        },
                        ZenTableColumn(id: "role", title: "Role", width: .fixed(100)) { user in
                            Text(user.role)
                                .font(.zenBody2)
                                .foregroundStyle(Color.zenTextMuted)
                        },
                    ]
                )
            }
        }
    }
}
