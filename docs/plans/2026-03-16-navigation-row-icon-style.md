# Navigation Row Icon Style Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a subtle rounded background behind `ZenNavigationRow` leading icons while preserving the existing muted icon treatment and row layout.

**Architecture:** Keep the implementation local to `ZenNavigationRow`. Introduce a tiny internal style constant only if needed for testability, then update the leading icon view to render inside a small rounded background badge with muted surface styling.

**Tech Stack:** SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Verify the style contract

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Modify: `Sources/ZenKit/Components/ZenshiNavigationRow.swift`

**Step 1: Write the failing test**

Add a focused test that asserts the new internal style constants for the navigation row icon badge exist and match the intended lighter treatment.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/navigationRowUsesSubtleLeadingIconBadgeStyling`
Expected: FAIL because the style hook does not exist yet.

**Step 3: Write minimal implementation**

Add the internal style constants and use them to render the leading icon inside a subtle rounded background.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/navigationRowUsesSubtleLeadingIconBadgeStyling`
Expected: PASS.

**Step 5: Commit**

Skip commit in this workspace unless requested because the tree already contains unrelated user changes.

### Task 2: Verify package compatibility

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiNavigationRow.swift`
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Run targeted package tests**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS.

**Step 2: Review previews and smoke coverage**

Confirm existing previews and smoke tests still compile with no API changes.

**Step 3: Commit**

Skip commit in this workspace unless requested because the tree already contains unrelated user changes.
