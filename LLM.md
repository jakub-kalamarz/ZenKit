# LLM Implementation Notes

## Purpose

This repository exposes reusable SwiftUI primitives for ZenKit plus a showcase app. When implementing new UI surfaces, prefer composable primitives over string-heavy convenience APIs.

## Directory Structure

`Sources/ZenKit/Components/` is organized by category:

- **DataDisplay/**: Components that present data (Avatar, Badge, ProgressBar, Metrics, etc.)
- **Feedback/**: Components that provide feedback (Alerts, Loading, Skeleton, etc.)
- **Inputs/**: Form controls and interactive elements (Buttons, Text Inputs, Pickers, etc.)
- **Layout/**: Foundational layout components (ZenScreen, ListScreen, Sections, etc.)
- **Navigation/**: Components for app navigation (Menus, Rows, etc.)
- **Surfaces/**: Containers and structural elements (Cards, Sheets, Settings, etc.)
- **System/**: Infrastructure components (Overlays, Toasts, etc.)

## Section Guidance

- Use `ZenSection` for sectioned layout primitives.
- Do not build new grouped surfaces on top of native `SwiftUI.Section` unless system behavior is explicitly required.
- Prefer `ZenSectionHeader` and `ZenSectionFooter` for standard title, subtitle, and helper copy.
- Keep `ZenSection` composable: accept arbitrary `ViewBuilder` content instead of `String` or `LocalizedStringKey` shortcuts.
- `ZenSection` should own its grouped chrome through theme tokens such as `Color.zenSurface`, `Color.zenBorder`, resolved corner radius, and Zen spacing values.

## Showcase Guidance

- Add reusable surface demos under `App/ZenKitShowcase/Sources/Screens/Surfaces`.
- Register every new showcase screen in:
  - `ShowcaseScreenID.swift`
  - `ShowcaseSection.swift`
  - `ShowcaseRootView.swift`
- Add or update a smoke test in `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift` when a new catalog entry is introduced.

## Testing Guidance

- For package-level component API coverage, update `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`.
- Run `swift test` after changing package sources.
- Run `xcodebuild -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'generic/platform=iOS Simulator' build` after changing the showcase app.

## Git Hygiene

- Do not revert unrelated local changes in the worktree.
- Prefer additive, isolated component files for new primitives.
- If a primitive replaces an older API, migrate call sites and remove the superseded component files in the same change.
