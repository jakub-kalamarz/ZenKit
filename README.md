# ZenKit

Reusable SwiftUI design system primitives extracted from the `zenshi` app.

## Current Status

`ZenKit` is intended to be shared across apps, but it is still under active development. The package API is usable now, with versioning discipline recommended before broad adoption.

## Recommended Reuse Model

- Put `ZenKit` in its own git repository.
- Consume it from apps through Swift Package Manager.
- Pin production apps to tags, not `main`.
- Allow one integration app to track `main` or a feature branch while package work is in flight.

## What Belongs In ZenKit

- Theme, colors, typography, spacing, motion
- Reusable SwiftUI primitives and small composites
- Generic feedback, overlay, form, navigation, and layout building blocks

## What Should Stay Out

- App branding
- App route policy
- App-specific accessibility IDs
- Product/domain presentation logic

## Integration Notes

- `ZenKit` supports both asset-backed and SF Symbol-backed icons through `ZenIcon`.
- Prefer SF Symbols for reusable package UI. Asset-backed icons remain available for app-specific integrations.
- The package currently depends on `ZenAvatar`.

## Suggested Extraction Steps

1. Move `Packages/ZenKit` into a dedicated repository.
2. Keep `Package.swift`, `Sources`, `Tests`, `README.md`, and `.gitignore`.
3. Add CI for `swift test`.
4. Tag an initial `0.x` release.
5. Switch consuming apps from local-path dependency to git dependency.
