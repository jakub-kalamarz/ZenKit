# Zen Onboarding Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a reusable full-screen `ZenOnboarding` primitive with animated mesh background, grain overlay, configurable transitions, and a showcase flow that demonstrates both subtle and expressive motion profiles.

**Architecture:** The feature should expose a single public full-screen onboarding container with a hybrid API while hiding most visual implementation details behind style types. Implementation should split into small SwiftUI-focused files so background rendering, transition behavior, and step modeling can evolve without breaking the public API.

**Tech Stack:** SwiftUI, Swift Testing, XCTest, Swift Package Manager, Tuist showcase app

---

### Task 1: Add public onboarding API smoke coverage

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Reference: `Sources/ZenKit/Components/ZenOnboardingCard.swift`
- Reference: `Sources/ZenKit/Components/ZenPageIndicator.swift`

**Step 1: Write the failing test**

Add a new smoke test that instantiates both supported entry points:

```swift
@Test
func zenOnboardingComposesModelAndBuilderVariants() {
    struct DemoPage: Identifiable, Equatable {
        let id: String
        let title: String
    }

    let pages = [
        DemoPage(id: "welcome", title: "Welcome"),
        DemoPage(id: "focus", title: "Focus"),
    ]

    let modelDriven = ZenOnboarding(
        pages: pages,
        selection: .constant("welcome"),
        backgroundStyle: .animatedMesh(),
        transitionStyle: .default
    ) { page in
        Text(page.title)
    }

    let builderDriven = ZenOnboarding(selection: .constant("welcome")) {
        ZenOnboardingStep(id: "welcome") {
            Text("Welcome")
        }
        ZenOnboardingStep(id: "focus") {
            Text("Focus")
        }
    }

    _ = modelDriven
    _ = builderDriven
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingComposesModelAndBuilderVariants`

Expected: FAIL with missing `ZenOnboarding`, `ZenOnboardingStep`, `animatedMesh`, or `transitionStyle` symbols.

**Step 3: Write minimal implementation**

Create the public type shells and the smallest compiling initializers:

```swift
public struct ZenOnboarding<Page, Content>: View where Page: Identifiable, Content: View {
    public init(
        pages: [Page],
        selection: Binding<Page.ID>,
        backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
        transitionStyle: ZenOnboardingTransitionStyle = .default,
        @ViewBuilder content: @escaping (Page) -> Content
    ) { ... }
}

public struct ZenOnboardingStep<ID, Content>: Identifiable where ID: Hashable, Content: View {
    public let id: ID
    public init(id: ID, @ViewBuilder content: () -> Content) { ... }
}
```

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingComposesModelAndBuilderVariants`

Expected: PASS

**Step 5: Commit**

```bash
git add Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift Sources/ZenKit/Components/ZenOnboarding.swift
git commit -m "feat: add zen onboarding public surface"
```

### Task 2: Implement step modeling and shared container layout

**Files:**
- Create: `Sources/ZenKit/Components/ZenOnboarding.swift`
- Create: `Sources/ZenKit/Components/ZenOnboardingStep.swift`
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Reference: `Sources/ZenKit/Components/ZenshiScreen.swift`

**Step 1: Write the failing test**

Add assertions that the builder variant can compile with multiple steps and that step IDs remain externally controlled:

```swift
@Test
func zenOnboardingUsesExternalSelectionBinding() {
    let selection = Binding.constant("focus")

    let view = ZenOnboarding(selection: selection) {
        ZenOnboardingStep(id: "welcome") { Text("Welcome") }
        ZenOnboardingStep(id: "focus") { Text("Focus") }
    }

    _ = view
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingUsesExternalSelectionBinding`

Expected: FAIL because the builder-based initializer is incomplete or step collection logic is missing.

**Step 3: Write minimal implementation**

Implement:

```swift
public init<ID, Steps>(
    selection: Binding<ID>,
    backgroundStyle: ZenOnboardingBackgroundStyle = .animatedMesh(),
    transitionStyle: ZenOnboardingTransitionStyle = .default,
    @ZenOnboardingStepBuilder content: () -> Steps
) where Page == ZenOnboardingStep<ID, AnyView>, Page.ID == ID
```

Core behavior:

- normalize builder-provided steps into an ordered collection
- resolve the selected step from the bound ID
- render a full-screen `ZStack` with background behind content
- keep page indicator placement in the shared container, not in each step

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingUsesExternalSelectionBinding`

Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenOnboarding.swift Sources/ZenKit/Components/ZenOnboardingStep.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: add zen onboarding step container"
```

### Task 3: Add background and transition style types

**Files:**
- Create: `Sources/ZenKit/Components/ZenOnboardingBackgroundStyle.swift`
- Create: `Sources/ZenKit/Components/ZenOnboardingTransitionStyle.swift`
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Add a smoke test for public presets:

```swift
@Test
func zenOnboardingStylesExposeSubtleAndExpressivePresets() {
    let subtle = ZenOnboardingBackgroundStyle.animatedMesh()
    let expressive = ZenOnboardingTransitionStyle.expressive

    _ = subtle
    _ = expressive
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingStylesExposeSubtleAndExpressivePresets`

Expected: FAIL due to missing style presets.

**Step 3: Write minimal implementation**

Define public style wrappers with limited public knobs:

```swift
public struct ZenOnboardingBackgroundStyle: Sendable {
    public static func animatedMesh(intensity: ZenOnboardingMotionIntensity = .subtle) -> Self { ... }
}

public struct ZenOnboardingTransitionStyle: Sendable {
    public static let `default`: Self = ...
    public static let expressive: Self = ...
}
```

Hide implementation-specific gradient control points and grain mechanics behind internal storage.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingStylesExposeSubtleAndExpressivePresets`

Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenOnboardingBackgroundStyle.swift Sources/ZenKit/Components/ZenOnboardingTransitionStyle.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: add zen onboarding style presets"
```

### Task 4: Implement animated mesh background and grain overlay

**Files:**
- Create: `Sources/ZenKit/Components/ZenOnboardingBackgroundView.swift`
- Create: `Sources/ZenKit/Components/ZenOnboardingGrainOverlay.swift`
- Modify: `Sources/ZenKit/Components/ZenOnboarding.swift`
- Reference: `Sources/ZenKit/Tokens/ZenshiColor.swift`
- Reference: `Sources/ZenKit/Tokens/ZenshiMetrics.swift`

**Step 1: Write the failing test**

Add a smoke test that forces the background view to render with a style:

```swift
@Test
func zenOnboardingBackgroundComposesAnimatedMeshStyle() {
    let view = ZenOnboardingBackgroundView(
        pageIndex: 0,
        style: .animatedMesh()
    )

    _ = view
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingBackgroundComposesAnimatedMeshStyle`

Expected: FAIL because the internal background view does not exist or cannot be constructed.

**Step 3: Write minimal implementation**

Implement the background rendering as layered shapes and overlay:

```swift
struct ZenOnboardingBackgroundView: View {
    let pageIndex: Int
    let style: ZenOnboardingBackgroundStyle

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                meshLayer(date: timeline.date)
                ZenOnboardingGrainOverlay(...)
            }
        }
    }
}
```

Guidelines:

- use deterministic page presets, not random values per frame
- animate between neighboring presets when page changes
- keep blur count and opacity low enough for mobile performance

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingBackgroundComposesAnimatedMeshStyle`

Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenOnboardingBackgroundView.swift Sources/ZenKit/Components/ZenOnboardingGrainOverlay.swift Sources/ZenKit/Components/ZenOnboarding.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: add zen onboarding animated background"
```

### Task 5: Implement page transitions and Reduce Motion fallback

**Files:**
- Modify: `Sources/ZenKit/Components/ZenOnboarding.swift`
- Modify: `Sources/ZenKit/Components/ZenOnboardingTransitionStyle.swift`
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Add a smoke test that composes both transition presets:

```swift
@Test
func zenOnboardingComposesDefaultAndExpressiveTransitions() {
    let pages = [
        DemoPage(id: "welcome", title: "Welcome"),
        DemoPage(id: "focus", title: "Focus"),
    ]

    let subtle = ZenOnboarding(
        pages: pages,
        selection: .constant("welcome"),
        backgroundStyle: .animatedMesh(),
        transitionStyle: .default
    ) { page in
        Text(page.title)
    }

    let expressive = ZenOnboarding(
        pages: pages,
        selection: .constant("focus"),
        backgroundStyle: .animatedMesh(.expressive),
        transitionStyle: .expressive
    ) { page in
        Text(page.title)
    }

    _ = subtle
    _ = expressive
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingComposesDefaultAndExpressiveTransitions`

Expected: FAIL because motion intensity variants or transition presets are incomplete.

**Step 3: Write minimal implementation**

Implement transition application inside the container:

```swift
content
    .transition(.asymmetric(
        insertion: .opacity.combined(with: .scale(scale: 0.98)),
        removal: .opacity
    ))
```

Then layer on:

- subtle blur/offset for default
- stronger offset/scale for expressive
- `@Environment(\.accessibilityReduceMotion)` fallback to opacity-first motion

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingComposesDefaultAndExpressiveTransitions`

Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenOnboarding.swift Sources/ZenKit/Components/ZenOnboardingTransitionStyle.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: add zen onboarding transitions"
```

### Task 6: Integrate page indicator and full-screen layout polish

**Files:**
- Modify: `Sources/ZenKit/Components/ZenOnboarding.swift`
- Reference: `Sources/ZenKit/Components/ZenPageIndicator.swift`
- Reference: `Sources/ZenKit/Tokens/ZenshiTypography.swift`
- Reference: `Sources/ZenKit/Tokens/ZenshiMetrics.swift`

**Step 1: Write the failing test**

Extend the existing onboarding smoke test to instantiate a three-page flow where the selected index is valid and the container includes indicator support.

```swift
@Test
func zenOnboardingSupportsMultiPageFlow() {
    let pages = [
        DemoPage(id: "welcome", title: "Welcome"),
        DemoPage(id: "focus", title: "Focus"),
        DemoPage(id: "sync", title: "Sync"),
    ]

    let view = ZenOnboarding(
        pages: pages,
        selection: .constant("focus")
    ) { page in
        Text(page.title)
    }

    _ = view
}
```

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingSupportsMultiPageFlow`

Expected: FAIL if index resolution or indicator integration is still broken.

**Step 3: Write minimal implementation**

Finalize container layout:

- content centered or bottom-aligned within safe area aware frame
- page indicator anchored in a stable footer region
- background fills full screen with ignored safe areas
- container uses theme spacing instead of magic numbers

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests/zenOnboardingSupportsMultiPageFlow`

Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ZenKit/Components/ZenOnboarding.swift
git commit -m "feat: polish zen onboarding layout"
```

### Task 7: Add showcase screen and catalog registration

**Files:**
- Create: `App/ZenKitShowcase/Sources/Screens/Surfaces/OnboardingShowcaseScreen.swift`
- Modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift`
- Modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`
- Modify: `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift`
- Modify: `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift`

**Step 1: Write the failing test**

Add a new showcase smoke test:

```swift
func test_surfaces_section_contains_onboarding_demo() {
    let surfaces = ShowcaseSection.defaultSections.first(where: { $0.id == "surfaces" })
    XCTAssertTrue(surfaces?.entries.contains(where: { $0.screenID == .onboarding }) == true)
}
```

**Step 2: Run test to verify it fails**

Run: `swift test`

Expected: FAIL because `.onboarding` is not yet registered in the catalog.

**Step 3: Write minimal implementation**

Implement a showcase screen that demonstrates:

- subtle profile with slow-moving mesh and light transitions
- expressive profile with stronger page changes
- at least three pages with large typographic content and CTA placeholders

Minimal shape:

```swift
struct OnboardingShowcaseScreen: View {
    @State private var subtleSelection = "welcome"
    @State private var expressiveSelection = "welcome"

    var body: some View {
        ShowcaseScreen(title: "Onboarding") {
            // two demos rendered in cards or previews
        }
    }
}
```

Register the screen in the catalog and root destination switch.

**Step 4: Run test to verify it passes**

Run: `swift test`

Expected: PASS for the new showcase smoke assertion.

**Step 5: Commit**

```bash
git add App/ZenKitShowcase/Sources/Screens/Surfaces/OnboardingShowcaseScreen.swift App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift
git commit -m "feat: add zen onboarding showcase"
```

### Task 8: Run package and showcase verification

**Files:**
- No source changes required
- Reference: `LLM.md`

**Step 1: Run package tests**

Run: `swift test`

Expected: PASS

**Step 2: Run showcase build**

Run: `xcodebuild -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'generic/platform=iOS Simulator' build`

Expected: `BUILD SUCCEEDED`

**Step 3: Perform manual motion verification**

Check in the showcase app:

- subtle profile does not feel noisy
- expressive profile is visibly stronger but still readable
- Reduce Motion keeps the flow usable
- background remains smooth while paging

**Step 4: Commit verification-safe final state**

```bash
git add Sources/ZenKit/Components/ZenOnboarding.swift Sources/ZenKit/Components/ZenOnboardingStep.swift Sources/ZenKit/Components/ZenOnboardingBackgroundStyle.swift Sources/ZenKit/Components/ZenOnboardingTransitionStyle.swift Sources/ZenKit/Components/ZenOnboardingBackgroundView.swift Sources/ZenKit/Components/ZenOnboardingGrainOverlay.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift App/ZenKitShowcase/Sources/Screens/Surfaces/OnboardingShowcaseScreen.swift App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift
git commit -m "feat: add zen onboarding primitives"
```
