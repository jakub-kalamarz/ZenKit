import SwiftUI
import ZenKit

struct ShowcaseRootView: View {
    var body: some View {
        NavigationStack {
            List(ShowcaseSection.defaultSections) { section in
                Section(section.title) {
                    ForEach(section.entries) { entry in
                        NavigationLink(entry.title) {
                            destination(for: entry.screenID)
                        }
                        .font(.zenBody)
                        .foregroundStyle(Color.zenTextPrimary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.zenBackground)
            .navigationTitle("ZenKit")
            .tint(Color.zenPrimary)
        }
        .tint(Color.zenPrimary)
    }

    @ViewBuilder
    func destination(for screenID: ShowcaseScreenID) -> some View {
        switch screenID {
        // Foundations
        case .theme:
            ThemePreviewScreen()
        // Inputs
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
        // Feedback
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
        // Navigation
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
        // Surfaces
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
        // Data Display
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
