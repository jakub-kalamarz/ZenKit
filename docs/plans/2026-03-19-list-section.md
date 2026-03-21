# List Section Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a theme-driven `ZenListSection` that preserves SwiftUI `Section` semantics, adds ZenKit grouped styling to section body, and exposes composable header/footer primitives instead of string-based APIs.

**Architecture:** Replace the current `VStack`-based `ZenListSection` with a `SwiftUI.Section` wrapper that hosts a lightweight grouped body container. Add dedicated `ZenListSectionHeader` and `ZenListSectionFooter` primitives for the recommended title/subtitle and helper-text presentation, then migrate smoke tests and showcase usage to the new builder-based API.

**Tech Stack:** Swift 5.9, SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Lock the new public API with failing smoke tests

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Replace the old string-based `ZenListSection` usages in the smoke tests with builder-based composition and add coverage for the new primitives:

```swift
ZenListSection {
    ZenNavigationRow(
        title: "Members",
        subtitle: "Manage access",
        leadingIconAsset: "UsersThree"
    )
} header: {
    ZenListSectionHeader {
        Text("Workspace")
    } subtitle: {
        Text("Shared settings")
    }
} footer: {
    ZenListSectionFooter {
        Text("Admins can update access.")
    }
}
```

Also update the simpler catalog-style usage to avoid `title:` initializers:

```swift
ZenListSection {
    ZenField(label: "Email") {
        ZenTextInput(text: .constant(""), prompt: "Email")
    }
} header: {
    ZenListSectionHeader {
        Text("Inputs")
    }
}
```

**Step 2: Run test to verify it fails**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests
```

Expected: FAIL with compile errors because `ZenListSectionHeader`, `ZenListSectionFooter`, and the new `ZenListSection` overloads do not exist yet.

**Step 3: Commit the failing test changes**

```bash
git add Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "test: define list section primitive API"
```

### Task 2: Implement `ZenListSection` as a themed `Section` primitive

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiListSection.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the minimal implementation**

Replace the current `VStack` implementation with a `Section`-based component that accepts view-builder content, header, and footer. Add overloads for:

- `content` only
- `content + header`
- `content + header + footer`

Target shape:

```swift
public struct ZenListSection<Content: View, Header: View, Footer: View>: View {
    private let content: () -> Content
    private let header: () -> Header
    private let footer: () -> Footer

    public var body: some View {
        Section {
            ZenListSectionBody {
                content()
            }
        } header: {
            header()
        } footer: {
            footer()
        }
    }
}
```

Inside the same file, add a private grouped body wrapper that applies the visual chrome:

```swift
private struct ZenListSectionBody<Content: View>: View {
    @Environment(\.zenContainerCornerRadius) private var parentCornerRadius
    private let content: () -> Content

    var body: some View {
        let theme = ZenTheme.current
        let cornerRadius = theme.resolvedCornerRadius(for: .nestedContainer, parentRadius: parentCornerRadius)

        VStack(spacing: 0) {
            content()
        }
        .padding(.vertical, ZenSpacing.xSmall)
        .background(Color.zenSurface)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.zenBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .zenContainerCornerRadius(cornerRadius)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
}
```

Keep this body intentionally lighter than `ZenCard`: no card title API, no footer divider, no broad `cardPadding`.

**Step 2: Run tests to verify the public surface passes**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests
```

Expected: PASS for the smoke tests updated in Task 1.

**Step 3: Commit the minimal section implementation**

```bash
git add Sources/ZenKit/Components/ZenshiListSection.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: rebuild list section as themed section primitive"
```

### Task 3: Add reusable header and footer primitives

**Files:**
- Create: `Sources/ZenKit/Components/ZenshiListSectionHeader.swift`
- Create: `Sources/ZenKit/Components/ZenshiListSectionFooter.swift`
- Test: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the minimal primitive implementations**

Create a composable header primitive with title and optional subtitle slots:

```swift
public struct ZenListSectionHeader<Title: View, Subtitle: View>: View {
    private let title: () -> Title
    private let subtitle: () -> Subtitle
    private let showsSubtitle: Bool

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            title()
                .font(.zenTitle)
                .foregroundStyle(Color.zenTextPrimary)

            if showsSubtitle {
                subtitle()
                    .font(.zenCaption)
                    .foregroundStyle(Color.zenTextMuted)
            }
        }
        .textCase(nil)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
        .padding(.bottom, ZenSpacing.xSmall)
    }
}
```

Create a footer primitive for helper or meta copy:

```swift
public struct ZenListSectionFooter<Content: View>: View {
    private let content: () -> Content

    public var body: some View {
        content()
            .font(.zenCaption)
            .foregroundStyle(Color.zenTextMuted)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, ZenSpacing.xSmall)
            .padding(.horizontal, 2)
    }
}
```

Add ergonomic initializers for header-without-subtitle and standard footer content.

**Step 2: Run tests to verify the new primitives compose**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests
```

Expected: PASS with the new builder-based examples.

**Step 3: Commit the primitive files**

```bash
git add Sources/ZenKit/Components/ZenshiListSectionHeader.swift Sources/ZenKit/Components/ZenshiListSectionFooter.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift
git commit -m "feat: add list section header and footer primitives"
```

### Task 4: Add API convention coverage for the replacement surface

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitAPIConventionsTests.swift`
- Test: `Tests/ZenKitTests/ZenKitAPIConventionsTests.swift`

**Step 1: Add a focused API conventions smoke check**

Add a lightweight test that instantiates the new section primitives together so regressions in generic initializers or visibility show up clearly:

```swift
@Test
func listSectionPrimitivesExposeComposableBuilderAPI() {
    let view = ZenListSection {
        Text("Row")
    } header: {
        ZenListSectionHeader {
            Text("Title")
        } subtitle: {
            Text("Subtitle")
        }
    } footer: {
        ZenListSectionFooter {
            Text("Footnote")
        }
    }

    _ = view
}
```

**Step 2: Run the targeted conventions test**

Run:

```bash
swift test --filter ZenKitAPIConventionsTests/listSectionPrimitivesExposeComposableBuilderAPI
```

Expected: PASS and no new legacy `Zenshi`-prefixed public declarations.

**Step 3: Commit the conventions coverage**

```bash
git add Tests/ZenKitTests/ZenKitAPIConventionsTests.swift
git commit -m "test: cover list section builder conventions"
```

### Task 5: Showcase the new section primitives in the app catalog

**Files:**
- Modify: `App/ZenKitShowcase/Sources/Screens/Surfaces/SettingsShowcaseScreen.swift`
- Optionally modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`
- Optionally modify: `App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift`

**Step 1: Replace at least one card-based grouping example with list-section composition**

Update `SettingsShowcaseScreen` to demonstrate the new section mental model directly:

```swift
ShowcaseScreen(title: "Settings") {
    ZenListScreen(navigationTitle: "Settings") {
        ZenListSection {
            ZenSettingRow(
                title: "Account",
                subtitle: "Manage your plan",
                leadingIconSystemName: "person.crop.circle.fill",
                iconColor: .blue,
                accessory: .chevron
            )
            ZenSettingRow(
                title: "Language",
                subtitle: "Used for notifications",
                leadingIconSystemName: "globe",
                iconColor: .cyan
            ) {
                Text("English")
            }
        } header: {
            ZenListSectionHeader {
                Text("Workspace")
            } subtitle: {
                Text("Shared settings and access")
            }
        } footer: {
            ZenListSectionFooter {
                Text("Only admins can change billing details.")
            }
        }
    }
}
```

If a full screen migration feels too disruptive, add a focused surface showcase block that still demonstrates header-only, header+footer, and custom-header usage.

**Step 2: Run the full test suite**

Run:

```bash
swift test
```

Expected: PASS for all package tests after the API migration.

**Step 3: Commit the showcase update**

```bash
git add App/ZenKitShowcase/Sources/Screens/Surfaces/SettingsShowcaseScreen.swift App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift
git commit -m "feat: showcase themed list section primitives"
```

### Task 6: Final verification before handoff

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiListSection.swift`
- Modify: `Sources/ZenKit/Components/ZenshiListSectionHeader.swift`
- Modify: `Sources/ZenKit/Components/ZenshiListSectionFooter.swift`
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Modify: `Tests/ZenKitTests/ZenKitAPIConventionsTests.swift`
- Modify: `App/ZenKitShowcase/Sources/Screens/Surfaces/SettingsShowcaseScreen.swift`

**Step 1: Run focused verification commands**

Run:

```bash
swift test --filter ZenKitPublicSurfaceSmokeTests
swift test --filter ZenKitAPIConventionsTests
swift test
```

Expected: PASS on all three commands.

**Step 2: Review the final diff**

Run:

```bash
git diff --stat HEAD~6..HEAD
git status --short
```

Expected: only the planned list-section files differ, aside from any pre-existing unrelated local edits already in the worktree.

**Step 3: Commit any final polish**

```bash
git add Sources/ZenKit/Components/ZenshiListSection.swift Sources/ZenKit/Components/ZenshiListSectionHeader.swift Sources/ZenKit/Components/ZenshiListSectionFooter.swift Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift Tests/ZenKitTests/ZenKitAPIConventionsTests.swift App/ZenKitShowcase/Sources/Screens/Surfaces/SettingsShowcaseScreen.swift
git commit -m "chore: finalize list section rollout"
```
