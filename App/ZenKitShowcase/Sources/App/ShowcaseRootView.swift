import SwiftUI

struct ShowcaseRootView: View {
    var body: some View {
        NavigationStack {
            List(ShowcaseSection.defaultSections) { section in
                Section(section.title) {
                    ForEach(section.entries) { entry in
                        NavigationLink(entry.title) {
                            destination(for: entry.screenID)
                        }
                    }
                }
            }
            .navigationTitle("ZenKit")
        }
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
        // Navigation
        case .navigationRow:
            NavigationRowShowcaseScreen()
        case .menu:
            MenuShowcaseScreen()
        case .swipeRow:
            SwipeRowShowcaseScreen()
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
        }
    }

}
