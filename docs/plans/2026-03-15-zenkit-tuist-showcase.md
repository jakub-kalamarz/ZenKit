# ZenKit Tuist Showcase Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Tuist-managed workspace around the existing `ZenKit` Swift package and create a `ZenKitShowcase` iOS app for developing and presenting components.

**Architecture:** Keep `Package.swift` as the source of truth for the reusable `ZenKit` library. Add Tuist manifests that generate a workspace containing an iOS showcase app which depends on the local package. Keep all catalog, demo, and sample-data code in the showcase app so the package remains clean and reusable.

**Tech Stack:** Swift 5.9, SwiftUI, Swift Package Manager, Tuist, XCTest

---

### Task 1: Add Tuist workspace manifests around the existing package

**Files:**
- Create: `Workspace.swift`
- Create: `Project.swift`
- Create: `Tuist/Package.swift`
- Modify: `README.md`

**Step 1: Write the failing configuration expectation**

Document the expected workspace shape in `README.md` before adding manifests:

```md
## Local Development Workspace

Use Tuist to generate a workspace that contains:
- the `ZenKitShowcase` app
- `ZenKitShowcaseTests`
- the local `ZenKit` package as a dependency
```

**Step 2: Run Tuist command to verify manifests are missing**

Run: `tuist generate`

Expected: FAIL with an error indicating that `Workspace.swift` or `Project.swift` does not exist.

**Step 3: Write minimal Tuist manifests**

Create `Workspace.swift`:

```swift
import ProjectDescription

let workspace = Workspace(
    name: "ZenKit",
    projects: ["."],
)
```

Create `Project.swift`:

```swift
import ProjectDescription

let project = Project(
    name: "ZenKit",
    packages: [
        .local(path: "."),
    ],
    targets: [
        .target(
            name: "ZenKitShowcase",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.zenshi.ZenKitShowcase",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
            ]),
            sources: ["App/ZenKitShowcase/Sources/**"],
            resources: ["App/ZenKitShowcase/Resources/**"],
            dependencies: [
                .package(product: "ZenKit"),
            ]
        ),
        .target(
            name: "ZenKitShowcaseTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.zenshi.ZenKitShowcaseTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["App/ZenKitShowcase/Tests/**"],
            dependencies: [
                .target(name: "ZenKitShowcase"),
            ]
        ),
    ]
)
```

Create `Tuist/Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZenKitTuist",
    dependencies: [
        .package(url: "https://github.com/tuist/tuist.git", from: "4.0.0"),
    ]
)
```

**Step 4: Run Tuist generate to verify manifests work**

Run: `tuist generate`

Expected: PASS and a generated workspace containing `ZenKitShowcase`.

**Step 5: Commit**

```bash
git add Workspace.swift Project.swift Tuist/Package.swift README.md
git commit -m "build: add tuist workspace for showcase app"
```

### Task 2: Scaffold the showcase app shell and first smoke test

**Files:**
- Create: `App/ZenKitShowcase/Sources/ZenKitShowcaseApp.swift`
- Create: `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift`
- Create: `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`
- Create: `App/ZenKitShowcase/Sources/Catalog/ShowcaseEntry.swift`
- Create: `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift`

**Step 1: Write the failing smoke test**

Create `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift`:

```swift
import XCTest
@testable import ZenKitShowcase

final class ZenKitShowcaseSmokeTests: XCTestCase {
    func test_catalog_contains_foundations_section() {
        XCTAssertTrue(ShowcaseSection.defaultSections.contains(where: { $0.title == "Foundations" }))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ZenKitShowcaseTests/ZenKitShowcaseSmokeTests`

Expected: FAIL because showcase app sources do not exist yet.

**Step 3: Write minimal app shell and catalog model**

Create `App/ZenKitShowcase/Sources/ZenKitShowcaseApp.swift`:

```swift
import SwiftUI

@main
struct ZenKitShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            ShowcaseRootView()
        }
    }
}
```

Create `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift`:

```swift
import SwiftUI

struct ShowcaseRootView: View {
    var body: some View {
        NavigationStack {
            List(ShowcaseSection.defaultSections) { section in
                Section(section.title) {
                    ForEach(section.entries) { entry in
                        NavigationLink(entry.title) {
                            Text(entry.title)
                        }
                    }
                }
            }
            .navigationTitle("ZenKit")
        }
    }
}
```

Create `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`:

```swift
struct ShowcaseSection: Identifiable, Equatable {
    let id: String
    let title: String
    let entries: [ShowcaseEntry]

    static let defaultSections: [ShowcaseSection] = [
        .init(id: "foundations", title: "Foundations", entries: []),
        .init(id: "inputs", title: "Inputs", entries: []),
        .init(id: "feedback", title: "Feedback", entries: []),
        .init(id: "navigation", title: "Navigation", entries: []),
        .init(id: "surfaces", title: "Surfaces", entries: []),
        .init(id: "data-display", title: "Data Display", entries: []),
    ]
}
```

Create `App/ZenKitShowcase/Sources/Catalog/ShowcaseEntry.swift`:

```swift
struct ShowcaseEntry: Identifiable, Equatable {
    let id: String
    let title: String
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ZenKitShowcaseTests/ZenKitShowcaseSmokeTests`

Expected: PASS

**Step 5: Commit**

```bash
git add App/ZenKitShowcase/Sources App/ZenKitShowcase/Tests
git commit -m "feat: scaffold showcase app shell"
```

### Task 3: Add reusable demo screen infrastructure and first real ZenKit demos

**Files:**
- Create: `App/ZenKitShowcase/Sources/Support/ShowcaseScreen.swift`
- Create: `App/ZenKitShowcase/Sources/Screens/Foundations/ThemePreviewScreen.swift`
- Create: `App/ZenKitShowcase/Sources/Screens/Inputs/ButtonShowcaseScreen.swift`
- Modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`
- Modify: `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift`
- Modify: `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift`

**Step 1: Write the failing smoke coverage**

Extend `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift`:

```swift
func test_inputs_section_contains_buttons_demo() {
    let inputs = ShowcaseSection.defaultSections.first(where: { $0.id == "inputs" })
    XCTAssertEqual(inputs?.entries.map(\.title), ["Buttons"])
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ZenKitShowcaseTests/ZenKitShowcaseSmokeTests/test_inputs_section_contains_buttons_demo`

Expected: FAIL because no entries exist yet.

**Step 3: Write minimal showcase screen infrastructure**

Create `App/ZenKitShowcase/Sources/Support/ShowcaseScreen.swift`:

```swift
import SwiftUI

struct ShowcaseScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content
            }
            .padding(20)
        }
        .navigationTitle(title)
    }
}
```

Create `App/ZenKitShowcase/Sources/Screens/Foundations/ThemePreviewScreen.swift`:

```swift
import SwiftUI
import ZenKit

struct ThemePreviewScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Theme") {
            ZenshiThemePreview()
        }
    }
}
```

Create `App/ZenKitShowcase/Sources/Screens/Inputs/ButtonShowcaseScreen.swift`:

```swift
import SwiftUI
import ZenKit

struct ButtonShowcaseScreen: View {
    var body: some View {
        ShowcaseScreen(title: "Buttons") {
            VStack(alignment: .leading, spacing: 16) {
                ZenshiButton("Primary") {}
                ZenshiButton("Secondary", role: .secondary) {}
                ZenshiButton("Disabled") {}
                    .disabled(true)
            }
        }
    }
}
```

Update `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift` to include entries for `Theme` and `Buttons`.

Update `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift` so each entry routes to a dedicated screen instead of `Text(entry.title)`.

**Step 4: Run test to verify it passes**

Run: `xcodebuild test -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ZenKitShowcaseTests/ZenKitShowcaseSmokeTests`

Expected: PASS

**Step 5: Commit**

```bash
git add App/ZenKitShowcase/Sources App/ZenKitShowcase/Tests
git commit -m "feat: add first showcase demo screens"
```

### Task 4: Document local workflow and verify package plus showcase together

**Files:**
- Modify: `README.md`

**Step 1: Write the failing documentation expectation**

Add a short checklist section to `README.md` that describes the intended local developer flow:

```md
## Development Flow

1. Run package tests for `ZenKit`
2. Generate the Tuist workspace
3. Launch `ZenKitShowcase`
4. Add or update a demo screen for every public component change
```

**Step 2: Run package tests**

Run: `swift test`

Expected: PASS

**Step 3: Run workspace verification**

Run: `tuist generate`

Expected: PASS

Run: `xcodebuild test -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: describe tuist showcase workflow"
```

### Task 5: Final verification

**Files:**
- Verify: `Package.swift`
- Verify: `Workspace.swift`
- Verify: `Project.swift`
- Verify: `Tuist/Package.swift`
- Verify: `App/ZenKitShowcase/Sources/**`
- Verify: `App/ZenKitShowcase/Tests/**`
- Verify: `README.md`
- Verify: `docs/plans/2026-03-15-zenkit-tuist-showcase-design.md`
- Verify: `docs/plans/2026-03-15-zenkit-tuist-showcase.md`

**Step 1: Verify package tests**

Run: `swift test`

Expected: PASS

**Step 2: Verify Tuist generation**

Run: `tuist generate`

Expected: PASS

**Step 3: Verify showcase tests**

Run: `xcodebuild test -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'platform=iOS Simulator,name=iPhone 16'`

Expected: PASS

**Step 4: Inspect resulting diff**

Run: `git diff -- Package.swift Workspace.swift Project.swift Tuist/Package.swift App/ZenKitShowcase README.md docs/plans/2026-03-15-zenkit-tuist-showcase-design.md docs/plans/2026-03-15-zenkit-tuist-showcase.md`

Expected: diff only for the planned workspace, showcase, docs, and no accidental changes in package internals.

**Step 5: Create final commit**

```bash
git add Package.swift Workspace.swift Project.swift Tuist/Package.swift App/ZenKitShowcase README.md docs/plans/2026-03-15-zenkit-tuist-showcase-design.md docs/plans/2026-03-15-zenkit-tuist-showcase.md
git commit -m "feat: add tuist showcase workspace for zenkit"
```
