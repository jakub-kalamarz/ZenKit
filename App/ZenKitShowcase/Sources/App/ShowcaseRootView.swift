import SwiftUI
import ZenKit

struct ShowcaseRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            ShowcaseSidebarLayout()
        } else {
            ShowcaseListLayout()
        }
    }
}

// MARK: - iPad Sidebar Layout

private struct ShowcaseSidebarLayout: View {
    @State private var selectedId: String?
    @State private var isCollapsed = false

    private var sidebarGroups: [ZenSidebarGroup] {
        ShowcaseSection.defaultSections.map { section in
            ZenSidebarGroup(
                id: section.id,
                label: section.title,
                items: section.entries.map { entry in
                    ZenSidebarItem(
                        id: entry.screenID.rawValue,
                        label: entry.title
                    )
                }
            )
        }
    }

    private var selectedScreenID: ShowcaseScreenID? {
        guard let selectedId else { return nil }
        return ShowcaseScreenID(rawValue: selectedId)
    }

    var body: some View {
        HStack(spacing: 0) {
            ZenSidebar(
                groups: sidebarGroups,
                selectedId: $selectedId,
                isCollapsed: $isCollapsed
            ) {
                HStack {
                    if !isCollapsed {
                        Text("ZenKit")
                            .font(.zen(.body, weight: .semibold))
                            .foregroundStyle(Color.zenTextStrong)
                    }
                    Spacer()
                    ZenSidebarToggle(isCollapsed: $isCollapsed)
                }
            } footer: {
                EmptyView()
            }

            NavigationStack {
                if let screenID = selectedScreenID {
                    ShowcaseDestination(screenID: screenID)
                } else {
                    ContentUnavailableView(
                        "Select a Component",
                        systemImage: "square.grid.2x2",
                        description: Text("Choose a component from the sidebar")
                    )
                    .foregroundStyle(Color.zenTextMuted)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.zenBackground)
        .tint(Color.zenPrimary)
    }
}

// MARK: - iPhone List Layout

private struct ShowcaseListLayout: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ZenSpacing.medium) {
                    ForEach(ShowcaseSection.defaultSections) { section in
                        ZenLayerCard {
                            VStack(spacing: 0) {
                                ForEach(Array(section.entries.enumerated()), id: \.element.id) { index, entry in
                                    NavigationLink {
                                        ShowcaseDestination(screenID: entry.screenID)
                                    } label: {
                                        HStack {
                                            Text(entry.title)
                                                .font(.zenBody)
                                                .foregroundStyle(Color.zenTextPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.zen(.group, weight: .semibold))
                                                .foregroundStyle(Color.zenTextMuted)
                                        }
                                        .padding(.horizontal, ZenSpacing.medium)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)

                                    if index < section.entries.count - 1 {
                                        Divider()
                                            .foregroundStyle(Color.zenBorderSubtle)
                                            .padding(.leading, ZenSpacing.medium)
                                    }
                                }
                            }
                        } secondary: {
                            Text(section.title)
                                .font(.zen(.body2, weight: .medium))
                                .foregroundStyle(Color.zenTextMuted)
                        }
                    }
                }
                .padding(ZenSpacing.medium)
            }
            .background(Color.zenBackground)
            .navigationTitle("ZenKit")
            .tint(Color.zenPrimary)
        }
        .tint(Color.zenPrimary)
    }
}

// MARK: - Shared Destination

struct ShowcaseDestination: View {
    let screenID: ShowcaseScreenID

    var body: some View {
        switch screenID {
        case .theme:
            ThemePreviewScreen()
        case .buttons:
            ButtonShowcaseScreen()
        case .login:
            LoginShowcaseScreen()
        case .textInput:
            TextInputShowcaseScreen()
        case .toggle:
            ToggleShowcaseScreen()
        case .segmentedControl:
            SegmentedControlShowcaseScreen()
        case .pickerRow:
            PickerRowShowcaseScreen()
        case .multiSelect:
            MultiSelectShowcaseScreen()
        case .selectCard:
            SelectCardShowcaseScreen()
        case .stepper:
            StepperShowcaseScreen()
        case .searchBar:
            SearchBarShowcaseScreen()
        case .tagInput:
            TagInputShowcaseScreen()
        case .datePicker:
            DatePickerShowcaseScreen()
        case .label:
            LabelShowcaseScreen()
        case .radioGroup:
            RadioGroupShowcaseScreen()
        case .sensitiveInput:
            SensitiveInputShowcaseScreen()
        case .inputGroup:
            InputGroupShowcaseScreen()
        case .autocomplete:
            AutocompleteShowcaseScreen()
        case .combobox:
            ComboboxShowcaseScreen()
        case .spinner:
            SpinnerShowcaseScreen()
        case .statusBanner:
            StatusBannerShowcaseScreen()
        case .alert:
            AlertShowcaseScreen()
        case .skeleton:
            SkeletonShowcaseScreen()
        case .emptyState:
            EmptyStateShowcaseScreen()
        case .popover:
            PopoverShowcaseScreen()
        case .tooltip:
            TooltipShowcaseScreen()
        case .navigationRow:
            NavigationRowShowcaseScreen()
        case .menu:
            MenuShowcaseScreen()
        case .swipeRow:
            SwipeRowShowcaseScreen()
        case .link:
            LinkShowcaseScreen()
        case .breadcrumbs:
            BreadcrumbsShowcaseScreen()
        case .pagination:
            PaginationShowcaseScreen()
        case .menubar:
            MenubarShowcaseScreen()
        case .sidebar:
            SidebarShowcaseScreen()
        case .commandPalette:
            CommandPaletteShowcaseScreen()
        case .tableOfContents:
            TableOfContentsShowcaseScreen()
        case .card:
            CardShowcaseScreen()
        case .section:
            SectionShowcaseScreen()
        case .field:
            FieldShowcaseScreen()
        case .settings:
            SettingsShowcaseScreen()
        case .disclosure:
            DisclosureShowcaseScreen()
        case .sheet:
            SheetShowcaseScreen()
        case .layerCard:
            LayerCardShowcaseScreen()
        case .grid:
            GridShowcaseScreen()
        case .badge:
            BadgeShowcaseScreen()
        case .progressBar:
            ProgressBarShowcaseScreen()
        case .avatar:
            AvatarShowcaseScreen()
        case .metrics:
            MetricsShowcaseScreen()
        case .rating:
            RatingShowcaseScreen()
        case .pageIndicator:
            PageIndicatorShowcaseScreen()
        case .colorSwatch:
            ColorSwatchShowcaseScreen()
        case .timeline:
            TimelineShowcaseScreen()
        case .buttonLabel:
            ButtonLabelShowcaseScreen()
        case .text:
            TextShowcaseScreen()
        case .meter:
            MeterShowcaseScreen()
        case .clipboardText:
            ClipboardTextShowcaseScreen()
        case .codeBlock:
            CodeBlockShowcaseScreen()
        case .table:
            TableShowcaseScreen()
        }
    }
}
