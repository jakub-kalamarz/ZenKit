# Metric Strip Rebuild Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild `ZenMetricStrip` so each tile has a clean icon-left, label-top, value-bottom layout, with no empty icon column when a metric has no icon.

**Architecture:** Keep the existing `ZenMetricValue` model and `iconSource` API. Rework each tile into two explicit layout branches: a compact `HStack(alignment: .top)` when an icon exists and a direct text stack when it does not. Typography should emphasize the value and keep the label subdued.

**Tech Stack:** SwiftUI, Swift Testing, ZenKit tokens

---

### Task 1: Lock the rebuilt layout metrics

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitDashboardComponentTests.swift`
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`

**Step 1: Write the failing test**

Expect these public layout constants:
- `iconBadgeSize == 24`
- `iconBadgeIconSize == 12`
- `iconBadgeCornerRadius == 10`
- `contentSpacing == 12`
- `textSpacing == 2`

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: FAIL because the layout contract does not exist yet.

**Step 3: Write minimal implementation**

Add the constants and use them in the tile layout.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: PASS

### Task 2: Rebuild the tile structure

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiMetricStrip.swift`
- Modify: `App/ZenKitShowcase/Sources/Screens/DataDisplay/MetricsShowcaseScreen.swift`

**Step 1: Implement the rebuilt layout**

Create:
- icon branch: badge on the left, text stack on the right
- no-icon branch: text stack only

Typography:
- label muted and secondary
- value strong and primary
- `monospacedDigit()` on the value

**Step 2: Verify component tests**

Run: `swift test --filter ZenKitDashboardComponentTests`
Expected: PASS

**Step 3: Verify smoke coverage**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS
