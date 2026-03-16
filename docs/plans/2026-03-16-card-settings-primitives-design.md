# Card Settings Primitives Design

**Date:** 2026-03-16

**Goal:** Add reusable card and settings primitives to ZenKit so apps can build account/settings surfaces without overloading `ZenCard` or hand-rolling row layouts.

## Direction

`ZenCard` should remain a neutral surface container. Settings-oriented presentation should come from composable primitives layered inside the card rather than from card-specific metadata APIs.

## New Primitives

### `ZenCardHeader`

- Purpose: reusable, icon-friendly card header
- API shape: `title`, optional `subtitle`, optional leading icon, optional tint
- Use cases: settings cards, account summaries, informational cards

### `ZenSettingGroup`

- Purpose: consistent grouping and spacing for related settings rows
- API shape: simple container with `@ViewBuilder` content
- Use cases: cards containing toggles, pickers, navigation rows, status rows

### `ZenSettingRow`

- Purpose: standard settings row with title/subtitle and trailing affordance
- API shape: title, optional subtitle, optional leading icon, optional trailing content, optional accessory
- Use cases: action rows, status rows, value rows, navigation rows

### `ZenPickerRow<Value>`

- Purpose: settings-style picker that reads like a toggle/navigation row instead of a bare SwiftUI menu
- API shape: title, optional subtitle, optional leading icon, selection binding, list of options, row label for the selected value
- Use cases: language choice, sorting preference, display density, account-level configuration

## Composition Rules

- `ZenCard` stays generic and unaware of icon or status metadata.
- `ZenCardHeader` should compose cleanly at the top of `ZenCard`.
- `ZenSettingGroup` is responsible only for grouping rhythm, not section semantics.
- `ZenSettingRow` and `ZenPickerRow` should visually align with `ZenToggle` and `ZenNavigationRow`.

## Visual Rules

- Use the existing nested control corner-radius rules.
- Use Zen typography and semantic colors only.
- Keep icon treatment subtle and reusable, not settings-specific branding.
- `ZenPickerRow` should expose the selected value inline with a compact trailing affordance.

## Testing

- Extend `ZenKitPublicSurfaceSmokeTests` with a single composed example covering the new primitives.
- Keep tests source-level and public-surface oriented.
- Verify that new primitives can compose inside a `ZenCard` without requiring changes to `ZenCard` API.

## Scope

In scope:

- new components in `Sources/ZenKit/Components`
- smoke tests in `Tests/ZenKitTests`
- plan/docs updates

Out of scope:

- changing `ZenCard` API to accept icon metadata
- app-specific Hook layout changes in this step
