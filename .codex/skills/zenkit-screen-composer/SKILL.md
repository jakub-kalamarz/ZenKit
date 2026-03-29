---
name: zenkit-screen-composer
description: Compose a SwiftUI screen from existing ZenKit primitives, using the library's preferred layout, field, action, and feedback patterns instead of generic SwiftUI scaffolding.
---

# ZenKit Screen Composer

Use this skill when the user already knows the feature they are building and wants a concrete ZenKit-based screen composition.

## Workflow

1. Read [`references/composition-checklist.md`](references/composition-checklist.md).
2. Read the closest recipe in [`../../../docs/ai/composition-recipes.md`](../../../docs/ai/composition-recipes.md).
3. Read only the relevant entries in [`../../../docs/ai/component-catalog.md`](../../../docs/ai/component-catalog.md).
4. If the screen depends on a choice between similar primitives, consult [`../../../docs/ai/selection-matrix.md`](../../../docs/ai/selection-matrix.md).
5. Compose the smallest useful screen that follows ZenKit conventions.

## Composition Rules

- Prefer `ZenScreen` for page structure and navigation chrome.
- Prefer builder-driven APIs over string-heavy wrappers where both exist.
- Reach for `ZenCard`, `ZenSection`, `ZenField`, `ZenMenu`, `ZenButton`, and theme tokens before custom containers.
- Keep example state minimal and realistic.
- Use existing ZenKit helpers before styling raw SwiftUI controls.

## Output

Return:

- the chosen primitives
- a concise SwiftUI composition
- any state shape the caller needs
- 1-3 repo references that match the pattern

If the request would be better served by native SwiftUI or needs a missing primitive, say so explicitly.
