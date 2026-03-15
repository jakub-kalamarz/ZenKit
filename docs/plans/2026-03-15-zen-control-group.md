# ZenControlGroup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a public ZenKit control-group wrapper with horizontal, vertical, and adaptive layout support built on SwiftUI `ControlGroup`.

**Architecture:** Introduce a small public `ZenControlGroup` wrapper and a testable layout model that resolves adaptive presentation from available width. Keep the visual layer lightweight by implementing a ZenKit `ControlGroupStyle` that arranges child controls using spacing tokens without imposing heavy container styling.

**Tech Stack:** Swift 5.9, SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Add failing tests for layout behavior

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitButtonTests.swift`
- Create: none
- Test: `Tests/ZenKitTests/ZenKitButtonTests.swift`

**Step 1: Write the failing test**

```swift
@Test
func controlGroupLayoutResolvesAdaptiveThresholds() {
    #expect(ZenControlGroupLayout.horizontal.resolvedLayout(forWidth: 200) == .horizontal)
    #expect(ZenControlGroupLayout.vertical.resolvedLayout(forWidth: 200) == .vertical)
    #expect(ZenControlGroupLayout.adaptive.resolvedLayout(forWidth: 420) == .horizontal)
    #expect(ZenControlGroupLayout.adaptive.resolvedLayout(forWidth: 260) == .vertical)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter controlGroupLayoutResolvesAdaptiveThresholds`
Expected: FAIL because `ZenControlGroupLayout` does not exist yet.

**Step 3: Write minimal implementation**

```swift
public enum ZenControlGroupLayout {
    case horizontal
    case vertical
    case adaptive

    func resolvedLayout(forWidth width: CGFloat?) -> Self { ... }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter controlGroupLayoutResolvesAdaptiveThresholds`
Expected: PASS

**Step 5: Commit**

```bash
git add Tests/ZenKitTests/ZenKitButtonTests.swift Sources/ZenKit/Components/ZenControlGroup.swift
git commit -m "feat: add control group layout model"
```

### Task 2: Add failing smoke coverage for public component composition

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Create: none
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

```swift
@Test
func zenControlGroupComposesWithButtons() {
    let view = ZenControlGroup(layout: .adaptive) {
        ZenButton("Edit") {}
        ZenButton("Duplicate", variant: .secondary) {}
    } label: {
        Text("Actions")
    }

    _ = view
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter zenControlGroupComposesWithButtons`
Expected: FAIL because `ZenControlGroup` does not exist yet.

**Step 3: Write minimal implementation**

```swift
public struct ZenControlGroup<Content: View, Label: View>: View { ... }
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter zenControlGroupComposesWithButtons`
Expected: PASS

**Step 5: Commit**

```bash
git add Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift Sources/ZenKit/Components/ZenControlGroup.swift
git commit -m "feat: add public ZenControlGroup wrapper"
```

### Task 3: Implement ZenKit style and adaptive layout rendering

**Files:**
- Create: `Sources/ZenKit/Components/ZenControlGroup.swift`
- Modify: `Tests/ZenKitTests/ZenKitButtonTests.swift`
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Test: `Tests/ZenKitTests/ZenKitButtonTests.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

```swift
@Test
func controlGroupLayoutUsesExpectedDefaultSpacingAndBreakpoint() {
    #expect(ZenControlGroupLayoutMetrics.defaultSpacing == ZenSpacing.small)
    #expect(ZenControlGroupLayoutMetrics.adaptiveBreakpoint == 320)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter controlGroupLayoutUsesExpectedDefaultSpacingAndBreakpoint`
Expected: FAIL because metrics/supporting types do not exist yet.

**Step 3: Write minimal implementation**

```swift
struct ZenControlGroupLayoutMetrics {
    static let defaultSpacing = ZenSpacing.small
    static let adaptiveBreakpoint: CGFloat = 320
}
```

Implement:
- ZenKit `ControlGroupStyle`
- horizontal and vertical arrangement
- adaptive width-based switching
- preview demonstrating common button compositions

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitButtonTests`
Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenControlGroup.swift Tests/ZenKitTests/ZenKitButtonTests.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: add ZenKit control group style"
```

### Task 4: Final verification

**Files:**
- Modify: none
- Test: `Tests/ZenKitTests/ZenKitButtonTests.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Run targeted tests**

Run: `swift test --filter ZenKitButtonTests`
Expected: PASS

**Step 2: Run smoke coverage**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS

**Step 3: Run full package verification**

Run: `swift test`
Expected: PASS

**Step 4: Review git diff**

Run: `git diff -- Sources/ZenKit/Components/ZenControlGroup.swift Tests/ZenKitTests/ZenKitButtonTests.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift docs/plans/2026-03-15-zen-control-group-design.md docs/plans/2026-03-15-zen-control-group.md`
Expected: Diff only contains planned feature work and plan docs.

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenControlGroup.swift Tests/ZenKitTests/ZenKitButtonTests.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift docs/plans/2026-03-15-zen-control-group-design.md docs/plans/2026-03-15-zen-control-group.md
git commit -m "feat: add ZenControlGroup"
```
