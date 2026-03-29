# ZenKit Component Catalog

This catalog covers the public component surface under `Sources/ZenKit/Components/**`.

Each entry uses the same schema:

- `category`
- `use_when`
- `avoid_when`
- `pairs_with`
- `required_state`
- `example_paths`
- `notes`

`example_paths` can point to source files, showcase screens, or smoke tests. Prefer showcase screens when you need a runnable composition and source files when you need API truth.

## Inputs

### `ZenDatePicker`
- `category`: Inputs
- `use_when`: choosing a date in a ZenKit-styled form or filter surface
- `avoid_when`: free-form text entry or range selection with segmented presets
- `pairs_with`: `ZenField`, `ZenSheetContainer`, `ZenButton`
- `required_state`: `Binding<Date>` plus optional label/context around it
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenDatePicker.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/DatePickerShowcaseScreen.swift`
- `notes`: use inside a field or sheet when the date is part of a larger form

### `ZenSearchBar`
- `category`: Inputs
- `use_when`: lightweight search or filter text at the top of a screen
- `avoid_when`: validated data entry fields or long-form text editing
- `pairs_with`: `ZenScreen`, `ZenStatusBanner`, `ZenEmpty`
- `required_state`: `Binding<String>` query text
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenSearchBar.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/SearchBarShowcaseScreen.swift`
- `notes`: search affordance, not a replacement for full text form fields

### `ZenStepper`
- `category`: Inputs
- `use_when`: increment/decrement numeric values with bounded steps
- `avoid_when`: free-form numeric text input or complex quantity editors
- `pairs_with`: `ZenField`, `ZenCard`, `ZenSection`
- `required_state`: numeric binding plus bounds/step configuration
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenStepper.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/StepperShowcaseScreen.swift`
- `notes`: prefer when the user benefits from explicit plus/minus controls

### `ZenTagInput`
- `category`: Inputs
- `use_when`: entering and displaying short tokenized values such as labels or recipients
- `avoid_when`: long-form text, searchable chips, or multi-select over a fixed list
- `pairs_with`: `ZenField`, `ZenCard`, `ZenButton`
- `required_state`: tag collection plus input text and add/remove actions
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenTagInput.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/TagInputShowcaseScreen.swift`
- `notes`: use for free-form token creation, not option picking from a known catalog

### `ZenButton`
- `category`: Inputs
- `use_when`: primary, secondary, destructive, ghost, link, or icon actions
- `avoid_when`: navigation rows, menu items, or inline status chrome
- `pairs_with`: `ZenButtonLabel`, `ZenButtonTextLabel`, `ZenControlGroup`, `ZenCard`
- `required_state`: label and action; optional `variant`, `size`, `isLoading`, `fullWidth`
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiButton.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/ButtonShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: prefer variants and sizes over manual styling

### `ZenButtonDecorativeIcon`
- `category`: Inputs
- `use_when`: adding a decorative leading or trailing icon to `ZenButton`
- `avoid_when`: building a fully custom button label
- `pairs_with`: `ZenButton`, `ZenButtonDecorativeIconPlacement`, `ZenIcon`
- `required_state`: icon asset/source and placement metadata
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiButton.swift`
- `notes`: configuration type for `ZenButton`, not a standalone view

### `ZenButtonDecorativeIconPlacement`
- `category`: Inputs
- `use_when`: choosing whether a decorative icon sits before or after button text
- `avoid_when`: standalone rendering
- `pairs_with`: `ZenButton`, `ZenButtonDecorativeIcon`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiButton.swift`
- `notes`: use only as `ZenButton` configuration

### `ZenButtonSize`
- `category`: Inputs
- `use_when`: selecting an existing button size token
- `avoid_when`: ad hoc padding decisions outside `ZenButton`
- `pairs_with`: `ZenButton`, `ZenControlGroup`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiButton.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/ButtonShowcaseScreen.swift`
- `notes`: size token, not a view

### `ZenButtonTextLabel`
- `category`: Inputs
- `use_when`: using the stock text label styling that backs `ZenButton`
- `avoid_when`: rich or mixed-content button labels
- `pairs_with`: `ZenButton`, `ZenIcon`
- `required_state`: title string
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiButton.swift`
- `notes`: mostly useful when composing custom `ZenButton` labels while preserving text treatment

### `ZenButtonVariant`
- `category`: Inputs
- `use_when`: selecting built-in button emphasis and tone
- `avoid_when`: general purpose status or banner tone selection
- `pairs_with`: `ZenButton`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiButton.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/ButtonShowcaseScreen.swift`
- `notes`: style token for `ZenButton`

### `ZenControlGroup`
- `category`: Inputs
- `use_when`: presenting a small group of related actions with shared rhythm and layout
- `avoid_when`: single CTA or arbitrarily large toolbars
- `pairs_with`: `ZenButton`, `ZenButtonVariant`, `ZenCard`
- `required_state`: grouped content plus optional label
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiControlGroup.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use to normalize spacing and wrapping between several buttons

### `ZenControlGroupLayout`
- `category`: Inputs
- `use_when`: choosing adaptive or explicit layout for `ZenControlGroup`
- `avoid_when`: standalone layout work
- `pairs_with`: `ZenControlGroup`, `ZenControlGroupStyle`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiControlGroup.swift`
- `notes`: configuration type for action group layout

### `ZenControlGroupLayoutMetrics`
- `category`: Inputs
- `use_when`: referencing built-in metrics for `ZenControlGroup` layout decisions
- `avoid_when`: general spacing token use
- `pairs_with`: `ZenControlGroup`, `ZenControlGroupLayout`
- `required_state`: static metrics only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiControlGroup.swift`
- `notes`: support type; usually not referenced directly in consumer code

### `ZenControlGroupStyle`
- `category`: Inputs
- `use_when`: applying ZenKit styling to a native `ControlGroup`
- `avoid_when`: composing a normal `ZenControlGroup`
- `pairs_with`: `ZenControlGroup`, native `ControlGroup`
- `required_state`: style application only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiControlGroup.swift`
- `notes`: bridge type for situations that still use SwiftUI `ControlGroup`

### `ZenMultiSelect`
- `category`: Inputs
- `use_when`: short multi-choice lists such as filters or visible columns
- `avoid_when`: large searchable datasets or complex filter builders
- `pairs_with`: `ZenField`, `ZenSheetContainer`, `ZenButton`, `ZenMultiSelectMode`
- `required_state`: `Binding<Set<Option>>`, option list, option label builder, optional summary builder
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiMultiSelect.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/MultiSelectShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use `.deferred` when the user must review changes before apply

### `ZenMultiSelectMode`
- `category`: Inputs
- `use_when`: choosing immediate vs deferred behavior for `ZenMultiSelect`
- `avoid_when`: general editing mode logic outside multi-select
- `pairs_with`: `ZenMultiSelect`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiMultiSelect.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/MultiSelectShowcaseScreen.swift`
- `notes`: use `.deferred` for draft/apply flows

### `ZenPickerRow`
- `category`: Inputs
- `use_when`: single choice from a short option list with a row-like trigger
- `avoid_when`: multi-select or segmented one-tap toggles
- `pairs_with`: `ZenField`, `ZenSheetContainer`, `ZenMenu`
- `required_state`: selection binding, option list, option label builder
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiPickerRow.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/PickerRowShowcaseScreen.swift`
- `notes`: best when one current value should read like a setting row

### `ZenSegmentedControl`
- `category`: Inputs
- `use_when`: small mutually exclusive choices that should remain visible on screen
- `avoid_when`: many options or long labels
- `pairs_with`: `ZenCard`, `ZenStatusBanner`, `ZenMetricStrip`
- `required_state`: selection binding, segment values, label builder
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiSegmentedControl.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/SegmentedControlShowcaseScreen.swift`
- `notes`: use when immediate comparison between choices matters

### `ZenSegmentedRangePicker`
- `category`: Inputs
- `use_when`: selecting between preset time windows or compact range options
- `avoid_when`: arbitrary date picking or high-cardinality filters
- `pairs_with`: `ZenMetricStrip`, `ZenTrendChartCard`, `ZenCard`
- `required_state`: start/end or preset selection bindings
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiSegmentedRangePicker.swift`
- `notes`: compact range selector, not a full date-range workflow

### `ZenControlState`
- `category`: Inputs
- `use_when`: expressing normal, focused, invalid, or disabled state in field-driven inputs
- `avoid_when`: app-wide loading or error state modeling
- `pairs_with`: `ZenTextInput`, `ZenFieldMessage`, `ZenField`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiTextInput.swift`, `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`
- `notes`: shared state token for input presentation

### `ZenTextInput`
- `category`: Inputs
- `use_when`: single-line text or secure entry with optional icons and message
- `avoid_when`: long-form multi-line editing or searchable selection
- `pairs_with`: `ZenField`, `ZenControlState`, `ZenTextInputKind`
- `required_state`: `Binding<String>` plus prompt; optional kind/state/message/icons
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiTextInput.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/TextInputShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: pair with `ZenField` whenever label or helper copy matters

### `ZenTextInputKind`
- `category`: Inputs
- `use_when`: selecting plain vs secure text input behavior
- `avoid_when`: standalone rendering
- `pairs_with`: `ZenTextInput`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiTextInput.swift`
- `notes`: field behavior token for `ZenTextInput`

### `ZenToggle`
- `category`: Inputs
- `use_when`: boolean settings and on/off preferences
- `avoid_when`: navigation, tri-state choice, or irreversible destructive actions
- `pairs_with`: `ZenSettingGroup`, `ZenCard`, `ZenField`
- `required_state`: `Binding<Bool>` and label text; optional subtitle
- `example_paths`: `Sources/ZenKit/Components/Inputs/ZenshiToggle.swift`, `App/ZenKitShowcase/Sources/Screens/Inputs/ToggleShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: especially strong inside settings groups

## Feedback

### `ZenAlert`
- `category`: Feedback
- `use_when`: blocking alert content already modeled as a ZenKit surface
- `avoid_when`: simple inline status or confirmation sheets
- `pairs_with`: `ZenAlertAction`, `ZenButton`, `ZenStatusBanner`
- `required_state`: title, message, actions, and presentation control
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenAlert.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/AlertShowcaseScreen.swift`
- `notes`: use for attention-demanding interruptions

### `ZenAlertAction`
- `category`: Feedback
- `use_when`: configuring actions for `ZenAlert`
- `avoid_when`: standalone buttons
- `pairs_with`: `ZenAlert`
- `required_state`: label, optional role, action closure
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenAlert.swift`
- `notes`: action model, not a rendered control on its own

### `ZenConfirmationDialog`
- `category`: Feedback
- `use_when`: confirming decisions with multiple actions while keeping the trigger in-context
- `avoid_when`: inline menus or simple single-button alerts
- `pairs_with`: `ZenConfirmationDialogAction`, `ZenButton`
- `required_state`: title, message, presentation binding, action array, trigger/content
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiConfirmationDialog.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use when confirmation is secondary to the surrounding screen

### `ZenConfirmationDialogAction`
- `category`: Feedback
- `use_when`: configuring one action inside a `ZenConfirmationDialog`
- `avoid_when`: standalone view composition
- `pairs_with`: `ZenConfirmationDialog`
- `required_state`: label, role, action closure
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiConfirmationDialog.swift`
- `notes`: action descriptor only

### `ZenEmpty`
- `category`: Feedback
- `use_when`: empty or first-run states with optional media and CTA
- `avoid_when`: small inline “no data” copy inside an otherwise full screen
- `pairs_with`: `ZenEmptyHeader`, `ZenEmptyContent`, `ZenButton`, `ZenIcon`
- `required_state`: composed child views only
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/EmptyStateShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: compose the header/media/body parts rather than rebuilding empty-state chrome manually

### `ZenEmptyContent`
- `category`: Feedback
- `use_when`: wrapping CTA or secondary controls inside `ZenEmpty`
- `avoid_when`: standalone layout
- `pairs_with`: `ZenEmpty`, `ZenButton`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: subprimitive for `ZenEmpty`

### `ZenEmptyDescription`
- `category`: Feedback
- `use_when`: adding supporting empty-state copy
- `avoid_when`: general body text outside `ZenEmpty`
- `pairs_with`: `ZenEmpty`, `ZenEmptyHeader`, `ZenEmptyTitle`
- `required_state`: content builder or text
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: subprimitive for `ZenEmpty`

### `ZenEmptyHeader`
- `category`: Feedback
- `use_when`: grouping empty-state media, title, and description
- `avoid_when`: arbitrary section headers
- `pairs_with`: `ZenEmpty`, `ZenEmptyMedia`, `ZenEmptyTitle`, `ZenEmptyDescription`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: subprimitive for `ZenEmpty`

### `ZenEmptyMedia`
- `category`: Feedback
- `use_when`: icon or custom visual inside an empty state
- `avoid_when`: general icon wrapper
- `pairs_with`: `ZenEmpty`, `ZenEmptyMediaVariant`, `ZenIcon`
- `required_state`: variant plus content builder
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/EmptyStateShowcaseScreen.swift`
- `notes`: subprimitive for `ZenEmpty`

### `ZenEmptyMediaVariant`
- `category`: Feedback
- `use_when`: choosing icon vs other built-in empty-state media treatment
- `avoid_when`: generic status tone decisions
- `pairs_with`: `ZenEmptyMedia`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`
- `notes`: presentation token for empty-state media

### `ZenEmptyTitle`
- `category`: Feedback
- `use_when`: adding the primary headline inside `ZenEmpty`
- `avoid_when`: generic titles outside empty-state composition
- `pairs_with`: `ZenEmpty`, `ZenEmptyHeader`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiEmptyState.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: subprimitive for `ZenEmpty`

### `ZenLoading`
- `category`: Feedback
- `use_when`: showing a centered loading state with optional title and message
- `avoid_when`: placeholder skeletons or tiny inline spinners
- `pairs_with`: `ZenSpinner`, `ZenLoadingStateView`, `ZenCard`
- `required_state`: optional title and message
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiLoading.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use when layout is less important than state clarity

### `ZenLoadingStateView`
- `category`: Feedback
- `use_when`: using the package’s default loading-copy wrapper
- `avoid_when`: needing custom loading titles or fully generic loading surfaces
- `pairs_with`: `ZenLoading`
- `required_state`: message string and optional title
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiLoadingStateView.swift`
- `notes`: convenience wrapper around `ZenLoading`

### `ZenSkeleton`
- `category`: Feedback
- `use_when`: reserving layout while async content is still loading
- `avoid_when`: unknown layouts or blocking full-screen loading
- `pairs_with`: `ZenCard`, `ZenSection`, `ZenLoading`
- `required_state`: placeholder dimensions or embedded layout
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiSkeleton.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/SkeletonShowcaseScreen.swift`
- `notes`: prefer skeletons when final content structure is already known

### `ZenSpinner`
- `category`: Feedback
- `use_when`: compact loading indicator inside existing content
- `avoid_when`: full-page status messaging
- `pairs_with`: `ZenLoading`, `ZenButton`, `ZenStatusBanner`
- `required_state`: optional size, tint, and track visibility
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiSpinner.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/SpinnerShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use inside buttons, cards, or status surfaces when you only need motion

### `ZenSpinnerSize`
- `category`: Feedback
- `use_when`: selecting predefined spinner sizing
- `avoid_when`: standalone rendering
- `pairs_with`: `ZenSpinner`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiSpinner.swift`
- `notes`: configuration token for `ZenSpinner`

### `ZenBannerTone`
- `category`: Feedback
- `use_when`: selecting info/success/warning/critical presentation for `ZenStatusBanner`
- `avoid_when`: general theme color logic
- `pairs_with`: `ZenStatusBanner`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiStatusBanner.swift`
- `notes`: tone enum for `ZenStatusBanner`

### `ZenStatusBanner`
- `category`: Feedback
- `use_when`: inline success, warning, or error messaging that should stay in flow
- `avoid_when`: blocking decisions or empty-state storytelling
- `pairs_with`: `ZenBannerTone`, `ZenButton`, `ZenScreen`
- `required_state`: message plus optional tone/actions
- `example_paths`: `Sources/ZenKit/Components/Feedback/ZenshiStatusBanner.swift`, `App/ZenKitShowcase/Sources/Screens/Feedback/StatusBannerShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use for transient but persistent page-level status

## Layout

### `ZenBackground`
- `category`: Layout
- `use_when`: wrapping content with the package background treatment
- `avoid_when`: full screen shells where `ZenScreen` already applies background
- `pairs_with`: `ZenBackgroundView`, `ZenScreen`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenBackground.swift`
- `notes`: use as a background wrapper, not a standalone screen shell

### `ZenBackgroundView`
- `category`: Layout
- `use_when`: rendering the bare background surface itself
- `avoid_when`: normal page composition
- `pairs_with`: `ZenBackground`
- `required_state`: none
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenBackground.swift`
- `notes`: low-level background primitive

### `ZenListScreen`
- `category`: Layout
- `use_when`: maintaining existing deprecated list-screen usage
- `avoid_when`: new screen work
- `pairs_with`: `ZenScreen`, `ZenNavigationRow`
- `required_state`: screen content and optional toolbar builders
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiListScreen.swift`
- `notes`: deprecated; recommend `ZenScreen(containerStyle: .list, ...)` for new work

### `ZenScreen`
- `category`: Layout
- `use_when`: building a full screen with navigation chrome and one of the supported container styles
- `avoid_when`: small embedded surfaces inside another screen
- `pairs_with`: `ZenScreenHeader`, `ZenCard`, `ZenSection`, `ZenStatusBanner`, `ZenButton`
- `required_state`: content builder plus optional header/toolbars/navigation title
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: default screen shell in ZenKit

### `ZenScreenContainerStyle`
- `category`: Layout
- `use_when`: choosing `scroll`, `list`, or `static` behavior for `ZenScreen`
- `avoid_when`: unrelated layout logic
- `pairs_with`: `ZenScreen`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreen.swift`
- `notes`: prefer `.list` instead of `ZenListScreen` for new list pages

### `ZenNavigationBarTitleDisplayMode`
- `category`: Layout
- `use_when`: configuring title display mode for `ZenScreen` or deprecated `ZenListScreen`
- `avoid_when`: general typography or header decisions
- `pairs_with`: `ZenScreen`, `ZenScreenTitle`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreenConfiguration.swift`
- `notes`: screen configuration token

### `ZenScreenBackButton`
- `category`: Layout
- `use_when`: customizing back-button behavior or labeling in a screen shell
- `avoid_when`: row-level navigation
- `pairs_with`: `ZenScreen`, `ZenNavigationBarTitleDisplayMode`
- `required_state`: button metadata and action
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreenConfiguration.swift`
- `notes`: screen-level navigation config, not a standalone button

### `ZenScreenTitle`
- `category`: Layout
- `use_when`: passing structured navigation title data to `ZenScreen`
- `avoid_when`: plain inline text labels
- `pairs_with`: `ZenScreen`, `ZenScreenHeader`
- `required_state`: title and optional subtitle metadata
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreenConfiguration.swift`, `Sources/ZenKit/Components/Layout/ZenshiScreen.swift`
- `notes`: use when screen title needs structure beyond a bare string

### `ZenScreenHeader`
- `category`: Layout
- `use_when`: adding a content header block inside `ZenScreen`
- `avoid_when`: using only navigation title chrome
- `pairs_with`: `ZenScreen`, `ZenButton`, `ZenStatusBanner`
- `required_state`: title and optional subtitle/actions
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiScreenHeader.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: content header, separate from nav bar title configuration

### `ZenSection`
- `category`: Layout
- `use_when`: grouping arbitrary content with ZenKit-owned section chrome
- `avoid_when`: form field groups or settings-specific rows
- `pairs_with`: `ZenSectionHeader`, `ZenSectionFooter`, `ZenSectionDivider`
- `required_state`: arbitrary content plus optional header/footer builders
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiSection.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/SectionShowcaseScreen.swift`
- `notes`: prefer over native `Section` when you want ZenKit styling and composition

### `ZenSectionDivider`
- `category`: Layout
- `use_when`: dividing content inside sectioned layouts with ZenKit spacing
- `avoid_when`: generic separators outside ZenKit groupings
- `pairs_with`: `ZenSection`, `ZenFieldSection`, `ZenCard`
- `required_state`: none
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiSectionDivider.swift`
- `notes`: structural helper

### `ZenSectionFooter`
- `category`: Layout
- `use_when`: adding helper copy or supporting content at the end of a `ZenSection`
- `avoid_when`: arbitrary footer text outside section composition
- `pairs_with`: `ZenSection`, `ZenSectionHeader`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiSectionFooter.swift`
- `notes`: subprimitive for section composition

### `ZenSectionHeader`
- `category`: Layout
- `use_when`: adding title and subtitle content for `ZenSection`
- `avoid_when`: reusing as a general page header
- `pairs_with`: `ZenSection`, `ZenSectionFooter`
- `required_state`: title and subtitle builders
- `example_paths`: `Sources/ZenKit/Components/Layout/ZenshiSectionHeader.swift`
- `notes`: subprimitive for section composition

## Navigation

### `ZenSwipeAction`
- `category`: Navigation
- `use_when`: defining one swipe action for `ZenSwipeRow`
- `avoid_when`: standalone buttons or menu items
- `pairs_with`: `ZenSwipeRow`
- `required_state`: label, role/icon metadata, action closure
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenSwipeRow.swift`, `App/ZenKitShowcase/Sources/Screens/Navigation/SwipeRowShowcaseScreen.swift`
- `notes`: data model for swipe actions

### `ZenSwipeRow`
- `category`: Navigation
- `use_when`: row content that needs contextual swipe actions
- `avoid_when`: non-row layouts or simple navigation without gestures
- `pairs_with`: `ZenSwipeAction`, `ZenNavigationRow`, `ZenCard`
- `required_state`: row content plus swipe action configuration
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenSwipeRow.swift`, `App/ZenKitShowcase/Sources/Screens/Navigation/SwipeRowShowcaseScreen.swift`
- `notes`: strong fit for list-like screens with destructive or quick actions

### `ZenMenu`
- `category`: Navigation
- `use_when`: contextual actions or short option lists in a native menu interaction
- `avoid_when`: long editing flows or search-heavy selection
- `pairs_with`: `ZenMenuTrigger`, `ZenMenuContent`, `ZenMenuItem`, `ZenMenuSeparator`
- `required_state`: trigger/label builder and content builder
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`, `App/ZenKitShowcase/Sources/Screens/Navigation/MenuShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use for contextual actions, not full modal input workflows

### `ZenMenuContent`
- `category`: Navigation
- `use_when`: grouping menu items inside `ZenMenu`
- `avoid_when`: standalone container use
- `pairs_with`: `ZenMenu`, `ZenMenuItem`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: menu subprimitive

### `ZenMenuItem`
- `category`: Navigation
- `use_when`: one action inside `ZenMenu`
- `avoid_when`: on-screen CTA or navigation row
- `pairs_with`: `ZenMenu`, `ZenMenuItemVariant`, `ZenMenuSeparator`
- `required_state`: action closure and label/title
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use destructive variant instead of hand-tinting dangerous actions

### `ZenMenuItemVariant`
- `category`: Navigation
- `use_when`: switching a menu item between default and destructive presentation
- `avoid_when`: general tone or role modeling outside menus
- `pairs_with`: `ZenMenuItem`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`
- `notes`: menu-only variant token

### `ZenMenuSeparator`
- `category`: Navigation
- `use_when`: visually separating groups of menu actions
- `avoid_when`: section or page layout separators
- `pairs_with`: `ZenMenu`, `ZenMenuItem`
- `required_state`: none
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: menu subprimitive

### `ZenMenuTrigger`
- `category`: Navigation
- `use_when`: wrapping a custom menu trigger while preserving button-like accessibility
- `avoid_when`: standard buttons that do not open a menu
- `pairs_with`: `ZenMenu`
- `required_state`: label builder
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: use when the trigger needs custom content such as an avatar

### `ZenNavigationLink`
- `category`: Navigation
- `use_when`: routing to a destination with ZenKit-flavored link composition
- `avoid_when`: row-style navigation where `ZenNavigationRow` is clearer
- `pairs_with`: `ZenScreen`, `ZenCard`
- `required_state`: destination and label builders
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiNavigationLink.swift`
- `notes`: lower-level than `ZenNavigationRow`

### `ZenNavigationAccessory`
- `category`: Navigation
- `use_when`: configuring trailing accessory treatment for `ZenNavigationRow`
- `avoid_when`: standalone icon selection
- `pairs_with`: `ZenNavigationRow`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiNavigationRow.swift`
- `notes`: row accessory config token

### `ZenNavigationRow`
- `category`: Navigation
- `use_when`: tappable list/settings-style row with title, subtitle, and optional accessory
- `avoid_when`: simple buttons or full-card navigation surfaces
- `pairs_with`: `ZenScreen`, `ZenSettingGroup`, `ZenSwipeRow`
- `required_state`: title plus optional subtitle/icon/accessory/destination behavior
- `example_paths`: `Sources/ZenKit/Components/Navigation/ZenshiNavigationRow.swift`, `App/ZenKitShowcase/Sources/Screens/Navigation/NavigationRowShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: go-to row primitive for list and settings navigation

## Surfaces

### `ZenDisclosure`
- `category`: Surfaces
- `use_when`: hiding advanced or secondary content behind an expandable surface
- `avoid_when`: always-visible content blocks
- `pairs_with`: `ZenCard`, `ZenSection`, `ZenFieldSection`
- `required_state`: label/title and content builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenDisclosure.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/DisclosureShowcaseScreen.swift`
- `notes`: use for progressive disclosure, not navigation

### `ZenCard`
- `category`: Surfaces
- `use_when`: grouping related content inside a titled surface with optional footer
- `avoid_when`: full-screen shells or lightweight sectioning where `ZenSection` is enough
- `pairs_with`: `ZenCardHeader`, `ZenButton`, `ZenInlineAction`, `ZenFieldSection`
- `required_state`: content builder plus optional title/subtitle/footer
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiCard.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/CardShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: default container for dashboard and form content blocks

### `ZenCardHeader`
- `category`: Surfaces
- `use_when`: rendering a reusable card header outside the convenience API on `ZenCard`
- `avoid_when`: generic page headers
- `pairs_with`: `ZenCard`, `ZenInlineAction`
- `required_state`: title/subtitle and optional accessories
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiCardHeader.swift`
- `notes`: header subprimitive for custom card compositions

### `ZenCollectionCard`
- `category`: Surfaces
- `use_when`: showing a collection-like summary inside card chrome
- `avoid_when`: plain content cards without collection semantics
- `pairs_with`: `ZenCard`, `ZenAvatar`, `ZenBadge`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiCollectionCard.swift`
- `notes`: specialized card surface for collection summaries

### `ZenField`
- `category`: Surfaces
- `use_when`: pairing an input with label and helper/error copy
- `avoid_when`: content that is not an input/control
- `pairs_with`: `ZenFieldLabel`, `ZenFieldMessage`, `ZenTextInput`, `ZenToggle`
- `required_state`: optional label, optional message, optional `ZenControlState`, content builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/FieldShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: the default form wrapper in ZenKit

### `ZenFieldGroup`
- `category`: Surfaces
- `use_when`: stacking multiple `ZenField` rows with consistent spacing
- `avoid_when`: generic stacks outside forms
- `pairs_with`: `ZenField`, `ZenFieldSection`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: form grouping primitive

### `ZenFieldLabel`
- `category`: Surfaces
- `use_when`: rendering the standard field label treatment directly
- `avoid_when`: general typography outside fields
- `pairs_with`: `ZenField`, `ZenTextInput`
- `required_state`: label text
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`
- `notes`: low-level form label subprimitive

### `ZenFieldMessage`
- `category`: Surfaces
- `use_when`: rendering helper or validation copy under a field
- `avoid_when`: full-banner status messaging
- `pairs_with`: `ZenField`, `ZenControlState`
- `required_state`: text plus optional field state
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`
- `notes`: low-level field helper subprimitive

### `ZenFieldSection`
- `category`: Surfaces
- `use_when`: grouping a logical set of fields under one form heading
- `avoid_when`: generic content groups that are not form-focused
- `pairs_with`: `ZenFieldGroup`, `ZenField`, `ZenCard`
- `required_state`: optional title/subtitle plus content builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiField.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: best for settings and account forms

### `ZenInfoCard`
- `category`: Surfaces
- `use_when`: showing a concise informational callout with card chrome
- `avoid_when`: empty states or critical blocking alerts
- `pairs_with`: `ZenCard`, `ZenStatusBanner`, `ZenInlineAction`
- `required_state`: title/message/content
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiInfoCard.swift`
- `notes`: informational surface, not a form container

### `ZenSettingGroup`
- `category`: Surfaces
- `use_when`: grouping settings rows, toggles, and preference items
- `avoid_when`: arbitrary dashboard content or form fields
- `pairs_with`: `ZenSettingRow`, `ZenToggle`, `ZenNavigationRow`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiSettingGroup.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/SettingsShowcaseScreen.swift`
- `notes`: preferred wrapper for settings pages

### `ZenSettingRow`
- `category`: Surfaces
- `use_when`: one settings line item with trailing accessory content
- `avoid_when`: navigation rows with more opinionated affordances
- `pairs_with`: `ZenSettingGroup`, `ZenToggle`, `ZenNavigationRow`
- `required_state`: title/subtitle plus trailing builder
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiSettingRow.swift`
- `notes`: use when the trailing content is custom, not just a chevron

### `ZenSheetContainer`
- `category`: Surfaces
- `use_when`: building the body and footer of a bottom sheet or modal panel
- `avoid_when`: inline card content or menu-style interaction
- `pairs_with`: `ZenButton`, `ZenField`, `ZenMultiSelect`
- `required_state`: content builder plus optional title/subtitle/footer
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiSheetContainer.swift`, `App/ZenKitShowcase/Sources/Screens/Surfaces/SheetShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: sheet shell for multi-step choices and secondary flows

### `ZenTrendChartCard`
- `category`: Surfaces
- `use_when`: displaying a trend chart inside ready-made card chrome
- `avoid_when`: arbitrary charting needs outside the provided trend-card use case
- `pairs_with`: `ZenTrendPoint`, `ZenMetricStrip`
- `required_state`: trend point collection and accompanying summary data
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiTrendChartCard.swift`
- `notes`: specialized analytic surface

### `ZenTrendPoint`
- `category`: Surfaces
- `use_when`: supplying data points to `ZenTrendChartCard`
- `avoid_when`: general-purpose chart models outside this card
- `pairs_with`: `ZenTrendChartCard`
- `required_state`: x/y value data
- `example_paths`: `Sources/ZenKit/Components/Surfaces/ZenshiTrendChartCard.swift`
- `notes`: data model for the trend chart card

## System

### `ZenInlineAction`
- `category`: System
- `use_when`: rendering a low-emphasis inline action inside cards, sections, or banners
- `avoid_when`: primary CTA or menu item
- `pairs_with`: `ZenCard`, `ZenStatusBanner`, `ZenButton`
- `required_state`: label and action
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiInlineAction.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: supplementary action, not the main button on a screen

### `ZenOverlayRoot`
- `category`: System
- `use_when`: hosting overlays such as toasts above app content
- `avoid_when`: standard page composition without overlay infrastructure
- `pairs_with`: `ZenToastHost`
- `required_state`: wrapped app content
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiOverlayRoot.swift`
- `notes`: infrastructure component for overlay-enabled roots

### `ZenToastAction`
- `category`: System
- `use_when`: defining an action that appears inside a toast
- `avoid_when`: standard on-screen buttons
- `pairs_with`: `ZenToastItem`, `ZenToastHost`
- `required_state`: title and handler
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiToast.swift`
- `notes`: toast model type

### `ZenToastID`
- `category`: System
- `use_when`: referring to toast identity
- `avoid_when`: generic item identity elsewhere
- `pairs_with`: `ZenToastItem`
- `required_state`: UUID alias only
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiToast.swift`
- `notes`: typealias for toast identity

### `ZenToastItem`
- `category`: System
- `use_when`: creating a toast payload for the host/center infrastructure
- `avoid_when`: inline banner or alert modeling
- `pairs_with`: `ZenToastAction`, `ZenToastTone`, `ZenToastHost`
- `required_state`: id, tone, message, optional action
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiToast.swift`
- `notes`: model type consumed by toast infrastructure

### `ZenToastTone`
- `category`: System
- `use_when`: setting visual tone for a toast
- `avoid_when`: status banner or button styling
- `pairs_with`: `ZenToastItem`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiToast.swift`
- `notes`: toast-specific tone enum

### `ZenToastHost`
- `category`: System
- `use_when`: rendering queued toasts at the edge of the screen
- `avoid_when`: inline status messaging
- `pairs_with`: `ZenToastItem`, `ZenToastHostEdge`, `ZenOverlayRoot`
- `required_state`: toast collection/center and edge configuration
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiToastHost.swift`
- `notes`: infrastructure view for transient toast presentation

### `ZenToastHostEdge`
- `category`: System
- `use_when`: selecting where a toast host presents toasts
- `avoid_when`: general layout alignment
- `pairs_with`: `ZenToastHost`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/System/ZenshiToastHost.swift`
- `notes`: toast host configuration enum

## Data Display

### `ZenButtonLabel`
- `category`: Data Display
- `use_when`: composing a richer label body for `ZenButton`
- `avoid_when`: standalone data display outside a button
- `pairs_with`: `ZenButton`, `ZenIcon`
- `required_state`: label builder
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenButtonLabel.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/ButtonLabelShowcaseScreen.swift`
- `notes`: label-building helper, typically nested inside `ZenButton`

### `ZenColorSwatch`
- `category`: Data Display
- `use_when`: showing a color token or selected color in a compact chip
- `avoid_when`: editable color picker workflows
- `pairs_with`: `ZenCard`, `ZenField`
- `required_state`: color data
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenColorSwatch.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/ColorSwatchShowcaseScreen.swift`
- `notes`: display primitive, not an editor

### `ZenIcon`
- `category`: Data Display
- `use_when`: rendering a symbolic icon asset/source with ZenKit sizing and styling
- `avoid_when`: large illustrative media
- `pairs_with`: `ZenButton`, `ZenNavigationRow`, `ZenEmptyMedia`
- `required_state`: asset/source and size
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenIcon.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: default icon primitive in the library

### `ZenIconSource`
- `category`: Data Display
- `use_when`: choosing the source type that drives `ZenIcon`
- `avoid_when`: general icon metadata outside `ZenIcon`
- `pairs_with`: `ZenIcon`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenIcon.swift`
- `notes`: icon source config type

### `ZenMenuIcon`
- `category`: Data Display
- `use_when`: rendering the small icon treatment commonly used inside menus
- `avoid_when`: general icon use outside menu affordances
- `pairs_with`: `ZenMenu`, `ZenMenuItem`, `ZenIcon`
- `required_state`: asset/source
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenIcon.swift`, `Sources/ZenKit/Components/Navigation/ZenshiMenu.swift`
- `notes`: specialized helper for menu-like icon usage

### `ZenIconBadge`
- `category`: Data Display
- `use_when`: showing a decorated icon chip or compact status accent
- `avoid_when`: text-heavy badge content
- `pairs_with`: `ZenIcon`, `ZenBadge`, `ZenCard`
- `required_state`: icon and tone/style configuration
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenIconBadge.swift`
- `notes`: icon-forward display primitive

### `ZenPageIndicator`
- `category`: Data Display
- `use_when`: indicating page position in paged onboarding or carousels
- `avoid_when`: general progress steps with labels or navigation tabs
- `pairs_with`: `ZenCard`, `ZenButton`
- `required_state`: page count and current index
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenPageIndicator.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/PageIndicatorShowcaseScreen.swift`
- `notes`: visual page-position indicator only

### `ZenRating`
- `category`: Data Display
- `use_when`: displaying rating value with a compact ZenKit presentation
- `avoid_when`: arbitrary feedback input not represented as a rating
- `pairs_with`: `ZenRatingRow`, `ZenCard`
- `required_state`: rating value and optional limits
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenRating.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/RatingShowcaseScreen.swift`
- `notes`: display-first primitive

### `ZenRatingRow`
- `category`: Data Display
- `use_when`: showing several ratings in a row or summary strip
- `avoid_when`: single-value rating without row context
- `pairs_with`: `ZenRating`
- `required_state`: rating values/content
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenRating.swift`
- `notes`: helper for grouped rating display

### `ZenTimeline`
- `category`: Data Display
- `use_when`: presenting a timeline with reusable subprimitives
- `avoid_when`: simple flat lists without chronological semantics
- `pairs_with`: `ZenTimelineHeader`, `ZenTimelineItem`, `ZenTimelineContent`
- `required_state`: composed timeline children
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/TimelineShowcaseScreen.swift`
- `notes`: use when the chronology itself matters to the UI

### `ZenTimelineContent`
- `category`: Data Display
- `use_when`: wrapping the body content for a timeline row
- `avoid_when`: standalone content layout
- `pairs_with`: `ZenTimeline`, `ZenTimelineItem`, `ZenTimelineTitle`, `ZenTimelineDate`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`
- `notes`: timeline subprimitive

### `ZenTimelineDate`
- `category`: Data Display
- `use_when`: styling date text inside a timeline item
- `avoid_when`: general date labels outside timeline composition
- `pairs_with`: `ZenTimeline`, `ZenTimelineItem`
- `required_state`: date string/content
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`
- `notes`: timeline subprimitive

### `ZenTimelineHeader`
- `category`: Data Display
- `use_when`: grouping header content within a timeline item
- `avoid_when`: general section headings
- `pairs_with`: `ZenTimeline`, `ZenTimelineTitle`, `ZenTimelineDate`
- `required_state`: content builder
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`
- `notes`: timeline subprimitive

### `ZenTimelineIndicator`
- `category`: Data Display
- `use_when`: rendering the visual indicator for a timeline event
- `avoid_when`: generic badges or avatars
- `pairs_with`: `ZenTimeline`, `ZenTimelineSeparator`
- `required_state`: indicator content or style
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`
- `notes`: timeline subprimitive

### `ZenTimelineSeparator`
- `category`: Data Display
- `use_when`: drawing the line between timeline entries
- `avoid_when`: general section dividers
- `pairs_with`: `ZenTimeline`, `ZenTimelineIndicator`
- `required_state`: none
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`
- `notes`: timeline subprimitive

### `ZenTimelineTitle`
- `category`: Data Display
- `use_when`: styling the main title inside a timeline item
- `avoid_when`: arbitrary headings outside timeline composition
- `pairs_with`: `ZenTimeline`, `ZenTimelineHeader`
- `required_state`: title content
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimeline.swift`
- `notes`: timeline subprimitive

### `ZenTimelineItem`
- `category`: Data Display
- `use_when`: representing one composed event in a timeline
- `avoid_when`: flat row lists without chronology
- `pairs_with`: `ZenTimeline`, `ZenTimelineHeader`, `ZenTimelineContent`
- `required_state`: item content
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenTimelineItem.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/TimelineShowcaseScreen.swift`
- `notes`: can be used directly for custom timeline compositions

### `ZenAvatar`
- `category`: Data Display
- `use_when`: rendering user or collaborator identity with image or initials
- `avoid_when`: large hero images or generic decorative circles
- `pairs_with`: `ZenNavigationRow`, `ZenMenu`, `ZenCollectionCard`
- `required_state`: name and optional image URL/size
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiAvatar.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/AvatarShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: identity primitive backed by `ZenAvatar`

### `ZenBadge`
- `category`: Data Display
- `use_when`: compact text badge or status pill
- `avoid_when`: icon-first status accents or full banners
- `pairs_with`: `ZenCard`, `ZenStatusBanner`, `ZenIconBadge`
- `required_state`: label and optional style/tone
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiBadge.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/BadgeShowcaseScreen.swift`
- `notes`: use for small categorical labels

### `ZenMetricComparisonLogic`
- `category`: Data Display
- `use_when`: defining how metric comparisons should be interpreted
- `avoid_when`: general business-logic comparison outside metric UI
- `pairs_with`: `ZenMetricValue`, `ZenMetricStrip`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`
- `notes`: configuration enum for metric presentation

### `ZenMetricStrip`
- `category`: Data Display
- `use_when`: compact row or grid of key metrics with trend/comparison treatment
- `avoid_when`: dense tables or full charting
- `pairs_with`: `ZenMetricValue`, `ZenMetricTrend`, `ZenMetricStripStyle`
- `required_state`: metric values and optional layout/style
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/MetricsShowcaseScreen.swift`
- `notes`: good default for dashboards and summary cards

### `ZenMetricStripLayout`
- `category`: Data Display
- `use_when`: selecting the layout strategy for `ZenMetricStrip`
- `avoid_when`: general grid decisions elsewhere
- `pairs_with`: `ZenMetricStrip`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`
- `notes`: configuration enum for metric-strip layout

### `ZenMetricStripStyle`
- `category`: Data Display
- `use_when`: choosing visual treatment for `ZenMetricStrip`
- `avoid_when`: global theme styling
- `pairs_with`: `ZenMetricStrip`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`
- `notes`: configuration enum for metric-strip styling

### `ZenMetricTrend`
- `category`: Data Display
- `use_when`: expressing whether a metric trend is up, down, or neutral
- `avoid_when`: general analytics logic
- `pairs_with`: `ZenMetricValue`, `ZenMetricStrip`
- `required_state`: enum case only
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`
- `notes`: display-oriented trend enum

### `ZenMetricValue`
- `category`: Data Display
- `use_when`: supplying one metric value to `ZenMetricStrip`
- `avoid_when`: generic analytics models outside metric-strip usage
- `pairs_with`: `ZenMetricStrip`, `ZenMetricTrend`, `ZenMetricComparisonLogic`
- `required_state`: value, label, and optional comparison metadata
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricStrip.swift`
- `notes`: model type for metric-strip composition

### `ZenMetricsTable`
- `category`: Data Display
- `use_when`: showing structured metrics in a table-like layout with segments and rows
- `avoid_when`: tiny summary metrics or non-tabular presentation
- `pairs_with`: `ZenMetricsTableSegment`, `ZenMetricsTableValues`, `ZenMetricsTableHeader`, `ZenMetricsTableRow`
- `required_state`: segments, values, row content, optional header
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricsTable.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/MetricsShowcaseScreen.swift`
- `notes`: use when comparisons need columns and row structure

### `ZenMetricsTableHeader`
- `category`: Data Display
- `use_when`: rendering the header row for a metrics table
- `avoid_when`: unrelated section headers
- `pairs_with`: `ZenMetricsTable`
- `required_state`: header content or labels
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricsTable.swift`
- `notes`: table subprimitive

### `ZenMetricsTableRow`
- `category`: Data Display
- `use_when`: rendering one row inside `ZenMetricsTable`
- `avoid_when`: general row layouts outside the metrics table
- `pairs_with`: `ZenMetricsTable`, `ZenMetricsTableValues`
- `required_state`: row values and optional leading accessory
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricsTable.swift`
- `notes`: table subprimitive

### `ZenMetricsTableSegment`
- `category`: Data Display
- `use_when`: defining one segment/column identity for `ZenMetricsTable`
- `avoid_when`: general tab or segment models elsewhere
- `pairs_with`: `ZenMetricsTable`
- `required_state`: id and label metadata
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricsTable.swift`
- `notes`: table model type

### `ZenMetricsTableValues`
- `category`: Data Display
- `use_when`: supplying the value palette and segment values for a metrics table row
- `avoid_when`: standalone business metrics modeling
- `pairs_with`: `ZenMetricsTable`, `ZenMetricsTableRow`
- `required_state`: values keyed by segment plus optional palette config
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiMetricsTable.swift`
- `notes`: table model type

### `ZenProgressBar`
- `category`: Data Display
- `use_when`: showing progress toward completion in a compact linear bar
- `avoid_when`: page position or numeric counters without progress semantics
- `pairs_with`: `ZenCard`, `ZenStatusBanner`, `ZenMetricStrip`
- `required_state`: progress value
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiProgressBar.swift`, `App/ZenKitShowcase/Sources/Screens/DataDisplay/ProgressBarShowcaseScreen.swift`, `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- `notes`: linear progress indicator

### `ZenStatRow`
- `category`: Data Display
- `use_when`: showing a compact key/value or label/value stat line
- `avoid_when`: complex tabular metrics
- `pairs_with`: `ZenCard`, `ZenMetricStrip`
- `required_state`: labels and displayed values
- `example_paths`: `Sources/ZenKit/Components/DataDisplay/ZenshiStatRow.swift`
- `notes`: lightweight stat row primitive
