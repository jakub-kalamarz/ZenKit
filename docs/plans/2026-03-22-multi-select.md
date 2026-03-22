# Multi Select Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a lightweight `ZenMultiSelect` primitive for short multi-option lists with hybrid selection summary and configurable immediate/deferred behavior.

**Architecture:** Add a new SwiftUI component backed by `Menu` and a controlled `Binding<Set<Option>>`, with a small mode enum and summary helper to keep the public API compact. Lock the public API with smoke tests first, then implement the component and wire a showcase screen into the existing catalog.

**Tech Stack:** Swift 5.9, SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Lock the public API with a failing smoke test

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Add a smoke test that composes the new component in both immediate and deferred modes:

```swift
@Test
func zenMultiSelectComposesImmediateAndDeferredModes() {
    enum Column: String, CaseIterable, Hashable {
        case name = "Name"
        case owner = "Owner"
        case status = "Status"
    }

    let view = VStack {
        ZenMultiSelect(
            title: "Columns",
            selection: .constant([.name, .status]),
            options: Column.allCases
        ) { option in
            Text(option.rawValue)
        }

        ZenMultiSelect(
            title: "Filters",
            selection: .constant([.owner]),
            options: Column.allCases,
            mode: .deferred
        ) { option in
            Text(option.rawValue)
        }
    }

    _ = view
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests/zenMultiSelectComposesImmediateAndDeferredModes
```

Expected: FAIL with compile errors because `ZenMultiSelect` and its mode type do not exist yet.

### Task 2: Implement the minimal `ZenMultiSelect`

**Files:**
- Create: `Sources/ZenKit/Components/ZenshiMultiSelect.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the minimal implementation**

Add:

- `ZenMultiSelectMode` with `.immediate` and `.deferred`
- `ZenMultiSelect<Option, OptionLabel, SummaryLabel>`
- a default summary builder showing placeholder, up to 2 selected labels, then `+N`
- `Menu` content with toggling actions and optional `Clear` / `Apply`

Use `Set<Option>` for selection storage and preserve display order through `options`.

**Step 2: Run tests to verify the smoke test passes**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests/zenMultiSelectComposesImmediateAndDeferredModes
```

Expected: PASS.

### Task 3: Add API convention coverage and summary helper assertions

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitAPIConventionsTests.swift`
- Test: `Tests/ZenKitTests/ZenKitAPIConventionsTests.swift`

**Step 1: Add focused API test**

Add a lightweight composition test that instantiates the new primitive with custom summary content:

```swift
@Test
func multiSelectPrimitiveExposesComposableBuilderAPI() {
    enum Filter: String, CaseIterable, Hashable {
        case today = "Today"
        case overdue = "Overdue"
    }

    let view = ZenMultiSelect(
        title: "Filters",
        selection: .constant([.today]),
        options: Filter.allCases,
        mode: .immediate
    ) { option in
        Text(option.rawValue)
    } summaryLabel: { selected in
        Text("\(selected.count) selected")
    }

    _ = view
}
```

**Step 2: Run tests to verify it passes**

Run:

```bash
swift test --filter ZenKitAPIConventionsTests/multiSelectPrimitiveExposesComposableBuilderAPI
```

Expected: PASS.

### Task 4: Add showcase coverage

**Files:**
- Create: `App/ZenKitShowcase/Sources/Screens/Inputs/MultiSelectShowcaseScreen.swift`
- Modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift`
- Modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`
- Modify: `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift`

**Step 1: Add showcase screen**

Create a screen showing:

- immediate column selection
- deferred filter selection
- summary behavior with 0, 1-2, and 3+ items

**Step 2: Wire it into the catalog**

Add the new screen ID, navigation destination, and inputs entry.

**Step 3: Run broad verification**

Run:

```bash
swift test
```

Expected: PASS for the full package test suite.
