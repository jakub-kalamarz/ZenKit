# Auto-Sizing Sheet Design

**Goal:** Add a reusable SwiftUI sheet API that sizes itself to its content height instead of forcing callers to choose a fixed detent.

## Context

`ZenSheetContainer` is currently a reusable content wrapper, but the library does not offer a reusable way to present sheet content with an intrinsic height. The current preview uses a regular `.sheet(isPresented:)`, so the sheet presentation remains caller-owned and fixed by the system.

The requested behavior matches the adaptive sheet pattern: measure the rendered content height, keep that value in state, and feed it back into `.presentationDetents([.height(...)])`.

## Approaches Considered

### 1. Reusable sheet modifier on `View`

Expose a public API like `zenAutoSizingSheet(isPresented:onDismiss:content:)` that owns the measurement and the real `.sheet` presentation.

- Pros: reusable for any sheet content, keeps `ZenSheetContainer` focused on layout, matches SwiftUI's presentation API
- Cons: requires a new public API surface

### 2. Auto-sizing behavior on `ZenSheetContainer`

Teach the container to measure itself and expose a helper specific to sheet container usage.

- Pros: minimal surface area for the current use case
- Cons: incorrectly couples presentation behavior to a content component and does not help other sheet content

### 3. Internal helper used only in previews/showcase

Apply the adaptive sizing pattern only to package previews or demo screens.

- Pros: smallest implementation
- Cons: does not satisfy the reusable requirement

## Recommended Design

Use approach 1.

Add a public `View` extension that presents a sheet and measures the sheet body through a `GeometryReader` preference. Store the measured height in `@State`, clamp it to a small non-zero minimum, and apply `.presentationDetents([.height(measuredHeight)])` to the presented content. Animate height updates so content changes inside an open sheet grow or shrink smoothly.

Keep `ZenSheetContainer` unchanged as a content primitive. Update its preview to use the new modifier so the preview demonstrates the intended production integration.

## Validation

- Add a public surface smoke test that composes the new modifier.
- Run `swift test` to verify the package compiles and tests pass.
