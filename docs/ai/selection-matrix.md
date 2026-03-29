# ZenKit Selection Matrix

Use this matrix to narrow choices before opening the full component catalog.

## Screen Shell

- Whole page with shared chrome: `ZenScreen`
- Whole page that behaves like a list: `ZenScreen(containerStyle: .list, ...)`
- Existing code still on deprecated API: `ZenListScreen`
- Background only, not a full shell: `ZenBackground`

## Grouping And Containers

- Flexible content block with title/subtitle/footer: `ZenCard`
- Grouped section in a screen: `ZenSection`
- Form-specific grouped fields: `ZenFieldSection`
- Settings group: `ZenSettingGroup`
- Modal sheet body with footer: `ZenSheetContainer`
- Collapsible content: `ZenDisclosure`

## Actions

- Primary or secondary CTA: `ZenButton`
- Compact auxiliary action inside content: `ZenInlineAction`
- Multiple adjacent actions: `ZenControlGroup`
- Swipe affordances on rows: `ZenSwipeRow` + `ZenSwipeAction`

## Text And Form Input

- Single line or secure text field: `ZenTextInput`
- Labeled form row with helper text: `ZenField` around an input
- Single selection from a short list: `ZenPickerRow`
- Single selection from a short visible card list: `ZenSelectCard`
- Multiple selection from a short list: `ZenMultiSelect`
- Segmented choice: `ZenSegmentedControl`
- Range toggle with two bounds: `ZenSegmentedRangePicker`
- Search affordance: `ZenSearchBar`
- Tag entry: `ZenTagInput`
- Increment/decrement numeric value: `ZenStepper`
- Toggle boolean setting: `ZenToggle`
- Date selection: `ZenDatePicker`

## Menus And Navigation

- Context menu or action overflow: `ZenMenu`
- Navigable list-style row: `ZenNavigationRow`
- Navigation driven by a destination builder: `ZenNavigationLink`

## Feedback And State

- Lightweight indeterminate loading: `ZenSpinner`
- Loading surface with title/message: `ZenLoading` or `ZenLoadingStateView`
- Placeholder content while layout is known: `ZenSkeleton`
- Inline status tone: `ZenStatusBanner`
- Empty state with media and CTA: `ZenEmpty`
- Blocking decision alert: `ZenAlert`
- Confirmation with multiple actions: `ZenConfirmationDialog`

## Data Display

- Avatar or initials: `ZenAvatar`
- Badge or small status pill: `ZenBadge`
- Decorated icon token: `ZenIcon` or `ZenIconBadge`
- Progress indicator: `ZenProgressBar`
- Ratings display: `ZenRating`
- Metric strip summary: `ZenMetricStrip`
- Tabular metrics: `ZenMetricsTable`
- Timeline event list: `ZenTimeline` or `ZenTimelineItem`
- Pagination dots: `ZenPageIndicator`
- Color chip: `ZenColorSwatch`

## Native SwiftUI Is Better When

- the need is highly platform-specific and ZenKit has no primitive
- the dataset is large enough to require search-heavy or virtualized selection
- the design intentionally breaks ZenKit visual language
- the required interaction is lower level than the catalog supports
