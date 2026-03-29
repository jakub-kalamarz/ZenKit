---
name: zenkit-component-selector
description: Choose the right ZenKit primitives for a SwiftUI use case, point to the matching source and showcase files, and give a minimal composition skeleton for external ZenKit users.
---

# ZenKit Component Selector

Use this skill when the user asks which ZenKit component, primitive, or pattern fits a screen, control, or UX flow.

## Workflow

1. Classify the request into one or two ZenKit categories: `Inputs`, `Feedback`, `Navigation`, `Surfaces`, `Layout`, `Data Display`, or `System`.
2. Read [`references/workflow.md`](references/workflow.md).
3. Read [`../../../docs/ai/selection-matrix.md`](../../../docs/ai/selection-matrix.md) for the initial shortlist.
4. Read only the relevant entries in [`../../../docs/ai/component-catalog.md`](../../../docs/ai/component-catalog.md) before recommending a primitive.
5. If the user also wants a screen example, read the closest recipe in [`../../../docs/ai/composition-recipes.md`](../../../docs/ai/composition-recipes.md).
6. Verify that every recommended primitive exists in `Sources/ZenKit/Components/**` and reference 1-3 real files from the repo.

## Output Contract

Follow [`references/response-contract.md`](references/response-contract.md).

Always:

- recommend 1-3 existing ZenKit primitives, not invented APIs
- explain why they fit this request
- give a minimal SwiftUI skeleton when code would help
- mention the closest showcase or source files
- say when native SwiftUI is the better choice

## Boundaries

- Prefer existing primitives over proposing new components.
- Treat `ZenListScreen` as legacy; recommend `ZenScreen(containerStyle: .list, ...)` unless the user is explicitly touching deprecated API.
- Do not answer as a generic SwiftUI advisor when ZenKit has a clear primitive.
- Do not force ZenKit when the repo has no matching primitive.
