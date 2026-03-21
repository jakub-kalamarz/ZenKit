# Metric Strip Icon Refinement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refine `ZenMetricStrip` so per-metric icons read as subtle supporting badges and the metric typography has a clearer hierarchy.

**Architecture:** Keep the existing `ZenMetricValue.iconSource` API and adjust only the tile layout in `ZenMetricStrip`. Introduce small internal layout constants for badge sizing and spacing so the typography and icon rhythm are explicit and testable.

**Tech Stack:** SwiftUI, Swift Testing, ZenKit design tokens

---

### Task 1: Lock the intended layout metrics

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`
- Test: `Tests/ZenKitTests/ZenKitDashboardComponentTests.swift`

**Step 1: Write the failing test**

Add a test that references the new layout constants and expects:
- badge size `22`
- badge icon size `12`
- badge corner radius `8`
- content spacing `10`

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: FAIL because the constants do not exist yet.

**Step 3: Write minimal implementation**

Add the constants to `ZenMetricStrip` and use them in the tile layout.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: PASS

### Task 2: Refine tile hierarchy

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`
- Modify: `App/ZenKitShowcase/Sources/Screens/DataDisplay/MetricsShowcaseScreen.swift`

**Step 1: Implement the layout update**

Change the metric tile so:
- the icon sits in a subtle `zenSurface` rounded badge on the left
- the icon tint uses the metric tint or muted text color
- the label becomes less aggressive
- the value remains the dominant visual element

**Step 2: Verify package tests**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: PASS

**Step 3: Verify public surface smoke coverage**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS
