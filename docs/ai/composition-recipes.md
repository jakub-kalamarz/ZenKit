# ZenKit Composition Recipes

These recipes are the first stop when the user wants more than a component name and less than a full app architecture.

Each recipe follows the schema:

- `problem`
- `recommended_components`
- `state_shape`
- `example_composition`
- `common_mistakes`

## Account Form

- `problem`: editable profile or account settings form with labels, helper copy, and submit actions
- `recommended_components`: `ZenScreen`, `ZenCard`, `ZenFieldSection`, `ZenFieldGroup`, `ZenField`, `ZenTextInput`, `ZenButton`
- `state_shape`: text bindings, validation state per field, submit/loading flag
- `example_composition`: screen shell -> one or more cards -> field section -> field group -> field rows -> submit actions
- `common_mistakes`: using raw `TextField` without `ZenField`, pushing labels into placeholders, using custom stacks instead of `ZenCard`
- `reference_paths`: `App/ZenKitShowcase/Sources/Screens/Inputs/TextInputShowcaseScreen.swift`, `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

## List Screen

- `problem`: list-like page with navigation title, rows, and optional toolbar actions
- `recommended_components`: `ZenScreen(containerStyle: .list, ...)`, `ZenNavigationRow`, `ZenSwipeRow`, `ZenStatusBanner`, `ZenEmpty`
- `state_shape`: list items, optional selection/filter state, loading/empty state
- `example_composition`: `ZenScreen(containerStyle: .list, ...)` with rows and optional banners or empty state
- `common_mistakes`: using deprecated `ZenListScreen` for new work, mixing raw `Section` chrome with ZenKit surfaces, custom row tap handling when `ZenNavigationRow` is enough
- `reference_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreen.swift`, `App/ZenKitShowcase/Sources/Screens/Navigation/NavigationRowShowcaseScreen.swift`, `App/ZenKitShowcase/Sources/Screens/Navigation/SwipeRowShowcaseScreen.swift`

## Dashboard Surface

- `problem`: summary page with metrics, cards, trend indicators, and lightweight actions
- `recommended_components`: `ZenScreen`, `ZenCard`, `ZenMetricStrip`, `ZenMetricsTable`, `ZenProgressBar`, `ZenButton`, `ZenInlineAction`
- `state_shape`: immutable view state or async-loaded dashboard model
- `example_composition`: top-level `ZenScreen` with stacked `ZenCard` surfaces for stat blocks and charts
- `common_mistakes`: rebuilding stat rows manually, mixing unrelated card chrome, overusing custom typography instead of Zen tokens
- `reference_paths`: `App/ZenKitShowcase/Sources/Screens/DataDisplay/MetricsShowcaseScreen.swift`, `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`, `Sources/ZenKit/Components/Surfaces/ZenshiCard.swift`

## Settings Screen

- `problem`: grouped account, preference, or security settings with navigable rows and toggles
- `recommended_components`: `ZenScreen`, `ZenSettingGroup`, `ZenSettingRow`, `ZenToggle`, `ZenNavigationRow`, `ZenStatusBanner`
- `state_shape`: toggle bindings, navigation destinations, optional status message
- `example_composition`: screen shell -> one or more setting groups -> setting rows or toggles
- `common_mistakes`: styling raw `List` cells manually, mixing form fields and settings rows without hierarchy, using buttons where a navigation row is clearer
- `reference_paths`: `App/ZenKitShowcase/Sources/Screens/Surfaces/SettingsShowcaseScreen.swift`, `Sources/ZenKit/Components/Surfaces/ZenshiSettingGroup.swift`, `Sources/ZenKit/Components/Surfaces/ZenshiSettingRow.swift`

## Empty Or Loading State

- `problem`: loading, no-results, or first-run state with optional CTA
- `recommended_components`: `ZenLoading`, `ZenLoadingStateView`, `ZenSkeleton`, `ZenEmpty`, `ZenStatusBanner`, `ZenButton`
- `state_shape`: enum-like view state plus optional retry/create callbacks
- `example_composition`: switch over state -> loading/skeleton/empty/success content
- `common_mistakes`: mixing loading and error chrome in one component, placing CTA outside the empty surface, building ad hoc spinner wrappers
- `reference_paths`: `App/ZenKitShowcase/Sources/Screens/Feedback/EmptyStateShowcaseScreen.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/SpinnerShowcaseScreen.swift`, `Sources/ZenKit/Components/Feedback/ZenshiLoadingStateView.swift`

## Sheet And Filter Flow

- `problem`: bottom sheet or popover flow for filters, review-and-apply choices, or secondary actions
- `recommended_components`: `ZenSheetContainer`, `ZenMultiSelect`, `ZenMenu`, `ZenPickerRow`, `ZenButton`, `ZenConfirmationDialog`
- `state_shape`: presentation flag, selection state, optional draft/apply flow
- `example_composition`: trigger -> sheet container -> fields or selectors -> footer actions
- `common_mistakes`: using `ZenMenu` for long-form editing flows, using `ZenMultiSelect` for search-heavy datasets, skipping apply semantics when deferred state matters
- `reference_paths`: `App/ZenKitShowcase/Sources/Screens/Inputs/MultiSelectShowcaseScreen.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/SheetShowcaseScreen.swift`, `Sources/ZenKit/Components/Inputs/ZenshiPickerRow.swift`
