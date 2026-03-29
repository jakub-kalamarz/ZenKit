---
name: zenkit-migration-advisor
description: Review existing SwiftUI code and map it onto current ZenKit primitives, calling out safe replacements, gaps that should stay native, and the smallest viable migration path.
---

# ZenKit Migration Advisor

Use this skill when the user brings existing SwiftUI and wants to migrate all or part of it to ZenKit.

## Workflow

1. Read [`references/migration-mapping.md`](references/migration-mapping.md).
2. Inspect the user's code first; do not assume their intent from screenshots or names alone.
3. Confirm candidate replacements in [`../../../docs/ai/component-catalog.md`](../../../docs/ai/component-catalog.md).
4. Use [`../../../docs/ai/selection-matrix.md`](../../../docs/ai/selection-matrix.md) when there are multiple plausible replacements.
5. If a target composition is needed, consult the closest recipe in [`../../../docs/ai/composition-recipes.md`](../../../docs/ai/composition-recipes.md).

## Output

Return:

- `Keep native`: code that should remain plain SwiftUI
- `Replace with ZenKit`: concrete mappings from current views to ZenKit primitives
- `Migration order`: the smallest safe refactor sequence
- `Risks`: behavior or API gaps to watch
- `References`: 1-3 repo paths showing the target pattern

## Guardrails

- Do not recommend deprecated API unless the user is maintaining existing deprecated usage.
- Do not force ZenKit replacements for missing primitives.
- Prefer small, mechanical migrations over a full rewrite.
