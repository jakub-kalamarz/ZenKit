# ZenControlGroup Design

**Date:** 2026-03-15

## Goal

Add a ZenKit control-group component inspired by SwiftUI `ControlGroup`, while keeping ZenKit's public API lightweight and visually consistent with existing button and spacing tokens.

## Recommended Approach

Implement a public `ZenControlGroup` wrapper around native `ControlGroup`, plus a ZenKit-provided style and a small layout model. This keeps system semantics and composability while giving the library a consistent default presentation.

## Alternatives Considered

### 1. Thin wrapper only

Expose `ZenControlGroup` as a direct pass-through to `ControlGroup`.

Pros:
- Lowest maintenance cost
- Minimal API surface

Cons:
- Adds little ZenKit value beyond naming
- No shared spacing or styling conventions

### 2. Wrapper plus style system

Expose `ZenControlGroup`, `ZenControlGroupLayout`, and a ZenKit style built on `ControlGroupStyle`.

Pros:
- Preserves native SwiftUI behavior
- Allows horizontal, vertical, and adaptive layouts
- Fits existing ZenKit pattern of lightweight semantic wrappers

Cons:
- Requires a small amount of infrastructure for layout resolution

### 3. Fully custom DSL

Create a custom component family with explicit trigger and item types.

Pros:
- Maximum control over behavior and visuals

Cons:
- Duplicates existing SwiftUI semantics
- Higher maintenance cost
- Prematurely commits the library to a larger API

## Approved Architecture

Version 1 will ship:
- `ZenControlGroup<Content, Label>`
- `ZenControlGroupLayout` with `horizontal`, `vertical`, and `adaptive`
- a ZenKit control-group style that determines layout presentation

`ZenControlGroup` will wrap native `ControlGroup`, allowing an optional label. The default ZenKit style will focus on layout and spacing, not on rewriting the appearance of child controls.

## Layout Rules

- `horizontal`: place controls in a single horizontal row
- `vertical`: place controls in a vertical stack
- `adaptive`: resolve to horizontal or vertical using a simple deterministic rule based on available width

The adaptive rule should remain explicit and testable. Version 1 should avoid opaque heuristics or behavior that is difficult to verify in tests.

## Visual Rules

The first release should stay visually restrained:
- use ZenKit spacing tokens
- keep compatibility with `ZenButton` as the primary child component
- avoid heavy container chrome by default
- avoid automatic mutation of child button variants or sizes

This keeps the component useful in cards, forms, sheets, and toolbars without introducing double borders or over-styled wrappers.

## Testing Strategy

Cover the feature with:
- public-surface smoke coverage
- unit tests for layout resolution and default metrics
- focused rendering/composition smoke tests where useful

## Non-Goals for V1

- custom item types
- overflow menus
- action prioritization
- automatic conversion of extra actions into dropdown content

## Implementation Notes

The component should follow existing ZenKit conventions:
- public semantic wrapper in `Sources/ZenKit/Components`
- small, testable supporting types where layout logic is needed
- previews showing common `ZenButton` composition
