# Nested Corner Radius Design

**Date:** 2026-03-15

**Problem**

ZenKit resolves corner radius per component, but nested elements do not inherit or derive radius from their semantic parent. Some components already approximate nesting by subtracting hardcoded values locally, which makes radius behavior inconsistent across the package.

**Decision**

Use a partially automatic model based on the direct semantic container:

- semantic containers publish their resolved corner radius through SwiftUI environment
- nested components derive their own corner radius from the parent radius when they do not use a fully rounded shape
- components can still opt into explicit radius behavior when needed

**Why this approach**

- it fits SwiftUI better than trying to infer global view depth
- it keeps behavior stable even when technical wrapper views are added
- it centralizes nested radius rules in theme logic instead of per-component arithmetic

**Corner roles**

- `container`: top-level container radius
- `nestedContainer`: container radius derived from the nearest semantic parent
- `control`: standalone control radius
- `nestedControl`: control radius derived from the nearest semantic parent
- fully rounded shapes remain separate and continue using `dimension / 2`

**Rules**

- nested values fall back to the standalone role when no parent radius exists
- nested values never exceed the parent radius
- nested values never drop below zero
- `cornerStyle == .none` still resolves all non-fully-rounded paths to zero

**Initial tokens**

- base container radius remains the existing theme radius
- nested container inset: `4`
- control inset: `4`
- minimum nested radius: `ZenRadius.small`

**Architecture**

1. Extend `ZenTheme` with semantic corner roles and nested-resolution helpers.
2. Add an environment key carrying the nearest semantic container radius.
3. Add a shared internal helper for publishing resolved radius to descendants.
4. Migrate container-like and control-like components to use the shared theme API.

**Non-goals**

- automatic radius resolution from arbitrary SwiftUI view depth
- reflection or layout introspection
- changing fully rounded primitives such as avatars, pills, and tiny progress indicators

**Testing**

- theme tests for nested role fallback and clamping
- smoke tests proving nested controls and containers compose with the new API
