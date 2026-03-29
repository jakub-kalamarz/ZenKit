# ZenKit AI Entry Point

Use this file as the main entry point when an AI model or agent needs to help a developer consume or extend ZenKit.

## What ZenKit Is

ZenKit is a SwiftUI component library built around reusable primitives, shared tokens, and a showcase app. The library favors builder-driven composition over string-heavy convenience APIs.

## How To Work With ZenKit

Default workflow:

1. Classify the request into a ZenKit category.
2. Check the decision rules in [`docs/ai/selection-matrix.md`](docs/ai/selection-matrix.md).
3. Confirm the exact primitive in [`docs/ai/component-catalog.md`](docs/ai/component-catalog.md).
4. If the user wants a composed screen, open the closest recipe in [`docs/ai/composition-recipes.md`](docs/ai/composition-recipes.md).
5. Reference real source files and showcase screens when answering.

Default answer contract:

- recommend existing ZenKit primitives before proposing new ones
- cite 1-3 real repo paths
- provide a minimal SwiftUI skeleton when code is useful
- say explicitly when native SwiftUI is the better choice

## ZenKit Categories

`Sources/ZenKit/Components/` is organized by category:

- **DataDisplay/**: avatar, badges, progress, metrics, rating, timeline, icons
- **Feedback/**: alerts, loading, skeletons, empty states, banners
- **Inputs/**: buttons, text input, picker row, multi-select, segmented controls, toggles
- **Layout/**: screen shells, sections, background, screen header
- **Navigation/**: menus, navigation rows, swipe rows, navigation links
- **Surfaces/**: cards, field wrappers, settings groups, disclosure, sheets
- **System/**: overlays, inline actions, toasts

## Composition Rules

- Prefer `ZenScreen` for new screens.
- Prefer `ZenScreen(containerStyle: .list, ...)` over deprecated `ZenListScreen`.
- Prefer `ZenField` + input primitives for labeled forms.
- Prefer `ZenCard`, `ZenSection`, `ZenFieldSection`, and `ZenSettingGroup` over ad hoc container stacks when one of them matches the information hierarchy.
- Prefer existing variants, sizes, and helper subprimitives over custom styling.
- Do not build new grouped surfaces on top of native `SwiftUI.Section` unless system behavior is explicitly required.

## Source Of Truth

Use these paths in this order:

1. `Sources/ZenKit/Components/**` for API truth
2. `App/ZenKitShowcase/Sources/**` for canonical examples
3. `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift` for composition coverage
4. `docs/ai/*.md` for AI-oriented summaries and decision support

## When To Use Native SwiftUI Instead

Prefer native SwiftUI when:

- the needed interaction does not exist in the component catalog
- the design intentionally breaks ZenKit visual language
- the requirement is highly platform-specific
- the data set is too large for the lightweight selection primitives in ZenKit

## Showcase Guidance

- Add reusable demos under the matching `App/ZenKitShowcase/Sources/Screens/<Category>/` folder.
- Register every new showcase screen in:
  - `App/ZenKitShowcase/Sources/Catalog/ShowcaseScreenID.swift`
  - `App/ZenKitShowcase/Sources/Catalog/ShowcaseSection.swift`
  - `App/ZenKitShowcase/Sources/App/ShowcaseRootView.swift`
- Add or update `App/ZenKitShowcase/Tests/ZenKitShowcaseSmokeTests.swift` when a new catalog entry is introduced.

## Testing Guidance

- For package-level API coverage, update `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`.
- Run `swift test` after changing package sources.
- Run `xcodebuild -workspace ZenKit.xcworkspace -scheme ZenKitShowcase -destination 'generic/platform=iOS Simulator' build` after changing the showcase app.
- Run `./scripts/check_ai_docs.sh` after changing AI docs or the public component surface.

## Skills

Codex-first skills live under `.codex/skills/`:

- `zenkit-component-selector`
- `zenkit-screen-composer`
- `zenkit-migration-advisor`

They should stay small and point to `docs/ai/*` instead of duplicating API descriptions.

## Maintenance Rules

- Every new public component in `Sources/ZenKit/Components/**` must get an entry in `docs/ai/component-catalog.md`.
- New showcase screens should be linked from the AI docs when they are the closest canonical example.
- Do not revert unrelated local changes in the worktree.
- Prefer additive, isolated component files for new primitives.
