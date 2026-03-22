# Metric Strip Compact Style Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extend `ZenMetricStrip` with a compact icon-plus-value style and configurable 2-column grid or single-row layouts.

**Architecture:** Preserve `ZenMetricValue` and the existing default rendering path. Add `ZenMetricStripStyle` and `ZenMetricStripLayout` so the same component can switch between the current detailed tile and the new compact presentation without duplicating tint, spacing, or tile chrome logic.

**Tech Stack:** SwiftUI, Swift Testing, ZenKit tokens

---

### Task 1: Lock the new API with failing tests

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitDashboardComponentTests.swift`
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`

**Step 1: Write the failing test**

Add coverage that expects:
- `ZenMetricStripStyle.default` and `.compact`
- `ZenMetricStripLayout.grid(columns: 2)` and `.row`
- `ZenMetricStrip` to default to `.default` style with `.grid(columns: 2)`

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: FAIL because the new style/layout API does not exist yet.

**Step 3: Write minimal implementation**

Add the public enums and store them on `ZenMetricStrip` with default arguments.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: PASS

### Task 2: Implement compact rendering and layouts

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`
- Modify: `App/ZenKitShowcase/Sources/Screens/DataDisplay/MetricsShowcaseScreen.swift`

**Step 1: Implement the compact style**

Render:
- `default`: current label/value layout
- `compact`: horizontal `icon | value`, no label

Layout:
- `.grid(columns: 2)` uses a `LazyVGrid`
- `.row` uses a horizontal stack or scroll-free row with equal tile widths

**Step 2: Verify dashboard component tests**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: PASS

**Step 3: Refresh showcase coverage**

Add cards for:
- compact 2x2
- compact 1x4

**Step 4: Verify smoke coverage**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS
