struct ShowcaseSection: Identifiable, Equatable {
    let id: String
    let title: String
    let entries: [ShowcaseEntry]

    static let defaultSections: [ShowcaseSection] = [
        .init(
            id: "foundations",
            title: "Foundations",
            entries: [
                .init(id: "theme", title: "Theme", screenID: .theme)
            ]
        ),
        .init(
            id: "inputs",
            title: "Inputs",
            entries: [
                .init(id: "buttons", title: "Buttons", screenID: .buttons),
                .init(id: "text-input", title: "Text Input", screenID: .textInput),
                .init(id: "toggle", title: "Toggle", screenID: .toggle),
                .init(id: "segmented-control", title: "Segmented Control", screenID: .segmentedControl),
                .init(id: "picker-row", title: "Picker Row", screenID: .pickerRow),
                .init(id: "multi-select", title: "Multi Select", screenID: .multiSelect),
                .init(id: "stepper", title: "Stepper", screenID: .stepper),
                .init(id: "search-bar", title: "Search Bar", screenID: .searchBar),
                .init(id: "tag-input", title: "Tag Input", screenID: .tagInput),
                .init(id: "date-picker", title: "Date Picker", screenID: .datePicker)
            ]
        ),
        .init(
            id: "feedback",
            title: "Feedback",
            entries: [
                .init(id: "spinner", title: "Spinner", screenID: .spinner),
                .init(id: "status-banner", title: "Status Banner", screenID: .statusBanner),
                .init(id: "alert", title: "Alert", screenID: .alert),
                .init(id: "skeleton", title: "Skeleton", screenID: .skeleton),
                .init(id: "empty-state", title: "Empty State", screenID: .emptyState)
            ]
        ),
        .init(
            id: "navigation",
            title: "Navigation",
            entries: [
                .init(id: "navigation-row", title: "Navigation Row", screenID: .navigationRow),
                .init(id: "menu", title: "Menu", screenID: .menu),
                .init(id: "swipe-row", title: "Swipe Row", screenID: .swipeRow)
            ]
        ),
        .init(
            id: "surfaces",
            title: "Surfaces",
            entries: [
                .init(id: "card", title: "Card", screenID: .card),
                .init(id: "section", title: "Section", screenID: .section),
                .init(id: "field", title: "Field", screenID: .field),
                .init(id: "settings", title: "Settings", screenID: .settings),
                .init(id: "disclosure", title: "Disclosure", screenID: .disclosure),
                .init(id: "sheet", title: "Sheet", screenID: .sheet)
            ]
        ),
        .init(
            id: "data-display",
            title: "Data Display",
            entries: [
                .init(id: "badge", title: "Badge", screenID: .badge),
                .init(id: "progress-bar", title: "Progress Bar", screenID: .progressBar),
                .init(id: "avatar", title: "Avatar", screenID: .avatar),
                .init(id: "metrics", title: "Metrics", screenID: .metrics),
                .init(id: "rating", title: "Rating", screenID: .rating),
                .init(id: "page-indicator", title: "Page Indicator", screenID: .pageIndicator),
                .init(id: "color-swatch", title: "Color Swatch", screenID: .colorSwatch),
                .init(id: "timeline", title: "Timeline", screenID: .timeline)
            ]
        )
    ]
}
