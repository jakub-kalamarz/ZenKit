# Nested Corner Radius Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add partially automatic nested corner radius resolution across ZenKit components using theme roles and SwiftUI environment propagation.

**Architecture:** `ZenTheme` becomes the source of truth for standalone and nested corner roles. Semantic containers publish their resolved corner radius through environment so nested components can derive their own radius without hardcoded local arithmetic.

**Tech Stack:** Swift Package Manager, SwiftUI, swift-testing

---

### Task 1: Add failing theme tests for nested corner roles

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitThemeTests.swift`

**Step 1: Write the failing test**

Add tests for:
- nested roles falling back to standalone values with no parent radius
- nested roles shrinking from parent radius with insets
- nested values clamping to parent and zero

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitThemeTests`

Expected: FAIL because nested role API does not exist yet

**Step 3: Write minimal implementation**

Add semantic corner role APIs and nested-resolution helpers in theme code.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitThemeTests`

Expected: PASS

### Task 2: Add corner radius environment context

**Files:**
- Create: `Sources/ZenKit/Foundation/ZenCornerRadiusContext.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Add a smoke test that composes nested containers and controls using the new shared helpers.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`

Expected: FAIL because the helper or environment API does not exist yet

**Step 3: Write minimal implementation**

Add the environment key and internal helper for publishing resolved corner radius.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`

Expected: PASS

### Task 3: Migrate components to semantic radius roles

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiCard.swift`
- Modify: `Sources/ZenKit/Components/ZenshiSheetContainer.swift`
- Modify: `Sources/ZenKit/Components/ZenshiSegmentedControl.swift`
- Modify: `Sources/ZenKit/Components/ZenshiTextInput.swift`
- Modify: `Sources/ZenKit/Components/ZenshiToggle.swift`
- Modify: `Sources/ZenKit/Components/ZenshiStatusBanner.swift`
- Modify: `Sources/ZenKit/Components/ZenshiInfoCard.swift`
- Modify: `Sources/ZenKit/Components/ZenshiNavigationRow.swift`
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`
- Modify: `Sources/ZenKit/Components/ZenshiOverlayRoot.swift`
- Modify: `Sources/ZenKit/Components/ZenshiToastHost.swift`

**Step 1: Write the failing test**

Add or extend smoke tests to compose nested containers using the migrated components.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`

Expected: FAIL or compile error while components still use old radius logic

**Step 3: Write minimal implementation**

Replace local radius arithmetic and direct fixed-radius resolution with role-based resolution plus environment propagation where the component is a semantic container.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`

Expected: PASS

### Task 4: Run full verification

**Files:**
- Verify only

**Step 1: Run package tests**

Run: `swift test`

Expected: PASS

**Step 2: Inspect diff**

Run: `git diff --stat`

Expected: only intended files changed
