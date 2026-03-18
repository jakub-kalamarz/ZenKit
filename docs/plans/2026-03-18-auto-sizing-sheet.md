# Auto-Sizing Sheet Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a reusable `zenAutoSizingSheet` API that presents SwiftUI sheets at their measured content height.

**Architecture:** Introduce a `View` extension backed by a private modifier that measures the presented content, persists the height in state, and applies it through `.presentationDetents([.height(...)])`. Update the `ZenSheetContainer` preview to demonstrate the new API.

**Tech Stack:** SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Add the failing API smoke test

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Validate: `swift test`

**Step 1: Write the failing test**

Add a smoke test that composes:

```swift
Text("Host")
    .zenAutoSizingSheet(isPresented: .constant(false)) {
        Text("Sheet")
    }
```

**Step 2: Run test to verify it fails**

Run: `swift test`
Expected: compile failure because `zenAutoSizingSheet` does not exist yet.

### Task 2: Implement the reusable modifier

**Files:**
- Create: `Sources/ZenKit/Components/ZenAutoSizingSheet.swift`
- Validate: `swift test`

**Step 1: Add the public API**

Create a `View` extension exposing:

```swift
public func zenAutoSizingSheet<SheetContent: View>(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> SheetContent
) -> some View
```

**Step 2: Add the private modifier and measurement helper**

Implement a private `ViewModifier` that:
- stores the measured height in `@State`
- measures the presented content with a preference-backed `GeometryReader`
- presents the real `.sheet`
- applies `.presentationDetents([.height(measuredHeight)])`

**Step 3: Keep height updates stable**

Clamp the height to a small minimum, ignore invalid values, and animate meaningful height changes so dynamic content updates stay smooth.

**Step 4: Run tests to verify it passes**

Run: `swift test`
Expected: package tests pass.

### Task 3: Update the component preview

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiSheetContainer.swift`
- Validate: `swift test`

**Step 1: Switch the preview wrapper to the new API**

Replace the direct `.sheet(isPresented:)` usage with `.zenAutoSizingSheet(isPresented:)`.

**Step 2: Keep the sample content unchanged**

Preserve the current sheet example so the preview still demonstrates `ZenSheetContainer`.

**Step 3: Re-run validation**

Run: `swift test`
Expected: package tests remain green after the preview update.
