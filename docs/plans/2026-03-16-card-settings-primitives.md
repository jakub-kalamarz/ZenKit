# Card Settings Primitives Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add composable card and settings primitives to ZenKit so applications can build settings surfaces without overloading `ZenCard`.

**Architecture:** Keep `ZenCard` as a neutral surface and introduce four small public components: `ZenCardHeader`, `ZenSettingGroup`, `ZenSettingRow`, and `ZenPickerRow`. Reuse existing Zen typography, colors, spacing, and nested corner-radius logic so the new primitives align with `ZenToggle` and `ZenNavigationRow`.

**Tech Stack:** SwiftUI, Swift Testing, ZenKit design tokens

---

### Task 1: Lock the public surface with a failing smoke test

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Add a smoke test that composes:

- `ZenCardHeader`
- `ZenSettingGroup`
- `ZenSettingRow`
- `ZenPickerRow`

inside a `ZenCard`.

**Step 2: Run test to verify it fails**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests
```

Expected: FAIL because the new types do not exist yet.

**Step 3: Write minimal implementation**

Create the missing components with the smallest public API that satisfies the test.

**Step 4: Run test to verify it passes**

Run the same command and confirm PASS.

### Task 2: Implement the reusable settings primitives

**Files:**
- Create: `Sources/ZenKit/Components/ZenshiCardHeader.swift`
- Create: `Sources/ZenKit/Components/ZenshiSettingGroup.swift`
- Create: `Sources/ZenKit/Components/ZenshiSettingRow.swift`
- Create: `Sources/ZenKit/Components/ZenshiPickerRow.swift`

**Step 1: Write the failing test**

If needed, extend the smoke test to assert composition variants:

- row with subtitle and icon
- row with trailing custom content
- picker row with a visible selected value

**Step 2: Run test to verify it fails**

Run the focused `swift test` command again.

**Step 3: Write minimal implementation**

Implement each primitive using:

- `ZenTheme.current`
- `ZenSpacing`
- Zen semantic colors
- nested control corner-radius resolution

**Step 4: Run test to verify it passes**

Run the focused `swift test` command again and confirm PASS.

### Task 3: Regression verification

**Files:**
- Modify: `docs/plans/2026-03-16-card-settings-primitives-design.md`
- Modify: `docs/plans/2026-03-16-card-settings-primitives.md`

**Step 1: Run full ZenKit tests**

Run:

```bash
swift test
```

Expected: PASS for the full ZenKit package.
