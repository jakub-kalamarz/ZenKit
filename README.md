# ZenKit

ZenKit is a library of modern, reusable SwiftUI primitives used across the ZenKit ecosystem.

## Features

- **Design-driven**: Components are built on shared tokens for color, typography, and spacing.
- **Composable**: Prefer `ViewBuilder` composition over rigid string-based APIs.
- **Platform support**: iOS 17.0+ and macOS 13.0+.
- **Showcase app**: Includes a demo app covering all available components.

## Library Structure

Components in `Sources/ZenKit/Components/` are grouped into categories:

- **DataDisplay**: Data presentation primitives such as Avatar, Badge, Progress, and Metrics.
- **Feedback**: Feedback components such as Alert, Spinner, Loading, and Skeleton.
- **Inputs**: Form controls such as Button, TextInput, MultiSelect, and Toggle.
- **Layout**: Screen and section structure such as ZenScreen, ListScreen, and Sections.
- **Navigation**: Navigation primitives such as Menu and Rows.
- **Surfaces**: Container and content surfaces such as Card, Sheet, and Settings.
- **System**: Technical infrastructure such as Overlays and Toasts.

## Installation (Swift Package Manager)

Add ZenKit as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/zenshi/ZenKit.git", branch: "main")
]
```

## Quick Start

```swift
import SwiftUI
import ZenKit

struct MyView: View {
    var body: some View {
        ZenScreen(navigationTitle: "Dashboard") {
            ZenCard(title: "Welcome") {
                Text("This is your new dashboard.")
                ZenButton("Get Started") {
                    print("Start!")
                }
            }
        }
    }
}
```

## Variable Fonts

ZenKit also supports variable fonts via `ZenFontSource.variable(...)`.
The font must already be added to the app and registered by the host bundle.

```swift
let displayFont = ZenVariableFont(
    name: "Skia",
    axes: .init(width: 110, opticalSize: 28),
    weights: .init(regular: 420, medium: 520, semibold: 640)
)

let theme = ZenTheme(
    typography: ZenTypography(
        display: .init(source: .variable(displayFont)),
        text: .init(source: .system(.rounded))
    )
)
```

## Development and Testing

- **Unit tests**: `swift test`
- **Showcase app**: Open `ZenKit.xcworkspace` and run the `ZenKitShowcase` scheme.

## Using ZenKit with AI

- Start with [LLM.md](LLM.md). It is the main entry point for models and agents working with ZenKit.
- For component selection, use `LLM.md` together with `docs/ai/selection-matrix.md` and `docs/ai/component-catalog.md`.
- For ready-made screen compositions, see `docs/ai/composition-recipes.md`.
- In Codex, you can reference these skills directly:
  - `$zenkit-component-selector`
  - `$zenkit-screen-composer`
  - `$zenkit-migration-advisor`

For more technical details, see [LLM.md](LLM.md).
