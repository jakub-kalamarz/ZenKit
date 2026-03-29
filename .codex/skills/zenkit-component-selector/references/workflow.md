# Workflow

Use this order:

1. Identify the primary interaction:
   `action`, `text input`, `single choice`, `multi choice`, `feedback state`, `navigation`, `container`, `data display`, or `system overlay`.
2. Map that interaction to a ZenKit category with `selection-matrix.md`.
3. Confirm the exact primitive in `component-catalog.md`.
4. Pull one canonical file path from the source and one from showcase if it exists.
5. Return a compact recommendation with caveats.

Heuristics:

- Prefer `ZenScreen` for whole-screen structure.
- Prefer `ZenField` + `ZenTextInput` over raw text fields when label/message/state matter.
- Prefer `ZenMenu`, `ZenPickerRow`, and `ZenMultiSelect` based on selection model, not visual similarity.
- Prefer `ZenCard`, `ZenSection`, and `ZenFieldSection` based on information hierarchy, not just chrome.
- Recommend native SwiftUI when the need is deeply platform-specific or missing from the catalog.
