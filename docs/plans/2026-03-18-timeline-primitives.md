# Timeline Primitives Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the current monolithic timeline item with composable SwiftUI timeline primitives that support simple and advanced showcase layouts.

**Architecture:** Introduce a vertical `ZenTimeline` container plus focused slot-style subviews for item structure, header, indicator, separator, content, title, and date. Keep status logic, badges, avatars, and collapsible behavior outside the primitives so the timeline stays structural and reusable.

**Tech Stack:** SwiftUI, Swift Testing, XCTest, Swift Package Manager, xcodebuild

---

### Task 1: Lock the new public surface with failing tests

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Add public-surface assertions for:
- `ZenTimeline`
- `ZenTimelineItem`
- `ZenTimelineHeader`
- `ZenTimelineIndicator`
- `ZenTimelineSeparator`
- `ZenTimelineContent`
- `ZenTimelineTitle`
- `ZenTimelineDate`

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: FAIL because the new public timeline types do not exist yet.

**Step 3: Write minimal implementation**

Create the missing public types in `Sources/ZenKit/Components`.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS

**Step 5: Commit**

```bash
git add Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift Sources/ZenKit/Components/ZenTimeline*.swift
git commit -m "feat: add timeline primitives public surface"
```

### Task 2: Build the timeline primitives

**Files:**
- Create: `Sources/ZenKit/Components/ZenTimeline.swift`
- Modify or Delete/Replace: `Sources/ZenKit/Components/ZenTimelineItem.swift`

**Step 1: Write the failing test**

If existing component tests cover the old `ZenTimelineItem`, update or replace them with rendering-oriented assertions for the new primitives where practical.

**Step 2: Run targeted tests**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS for public symbols, with any new rendering tests failing until implementation is complete.

**Step 3: Write minimal implementation**

Implement:
- vertical container layout,
- left-axis item layout,
- reusable indicator slot,
- separator visibility handling,
- lightweight typographic wrappers for title/date/content.

Keep API small and avoid status enums or built-in badges.

**Step 4: Run tests**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenTimeline.swift Sources/ZenKit/Components/ZenTimelineItem.swift
git commit -m "feat: implement composable timeline primitives"
```

### Task 3: Migrate the showcase screen to the new primitives

**Files:**
- Modify: `App/ZenKitShowcase/Sources/Screens/DataDisplay/TimelineShowcaseScreen.swift`

**Step 1: Write the failing showcase expectation**

If there is no direct test for timeline content, define the target examples explicitly in code comments or preview parity before editing:
- simple activity feed,
- advanced pipeline-like example using custom indicator/content.

**Step 2: Implement the showcase migration**

Replace uses of the old monolithic timeline item with the new primitives and build two sections:
- a basic feed mirroring the current use case,
- a richer example demonstrating badges/cards-like composition using existing ZenKit primitives where available.

**Step 3: Run showcase smoke tests**

Run: `swift test --filter ZenKitShowcaseSmokeTests`
Expected: PASS if the showcase target remains covered by package tests, otherwise proceed to build verification.

**Step 4: Commit**

```bash
git add App/ZenKitShowcase/Sources/Screens/DataDisplay/TimelineShowcaseScreen.swift
git commit -m "feat: migrate timeline showcase to composable primitives"
```

### Task 4: Verify package and showcase build

**Files:**
- Verify only

**Step 1: Run package tests**

Run: `swift test`
Expected: PASS

**Step 2: Run showcase build**

Run: `xcodebuild -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 3: Commit final integration**

```bash
git add Sources/ZenKit/Components/ZenTimeline.swift Sources/ZenKit/Components/ZenTimelineItem.swift App/ZenKitShowcase/Sources/Screens/DataDisplay/TimelineShowcaseScreen.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift docs/plans/2026-03-18-timeline-primitives-design.md docs/plans/2026-03-18-timeline-primitives.md
git commit -m "feat: add composable timeline primitives"
```
