# Metric Strip Compact Style Design

**Goal:** Add a compact visual style to `ZenMetricStrip` that can present metrics as icon-and-value tiles in either a 2x2 grid or a single 1x4 row, without introducing a separate component.

**Architecture:** Keep `ZenMetricValue` unchanged and extend `ZenMetricStrip` with two explicit configuration axes: `style` and `layout`. `style` controls content density (`default` keeps the existing label/value layout, `compact` renders only icon and value), while `layout` controls geometry (`grid(columns:)` or `row`).

**Visual Rules:** Reuse the current tile chrome so the compact variant still reads as the same primitive: `zenSurfaceMuted` tiles, nested corner radius, and restrained spacing. In compact mode, render a horizontal `HStack` with optional icon on the left and value on the right; if no icon exists, render only the value without a placeholder.

**Fallbacks:** Existing call sites should remain unchanged through default arguments. Compact mode should tolerate missing icons, and row layout should distribute tiles evenly across available width.

**Testing:** Lock the new public API and default values in `ZenKitDashboardComponentTests`, then verify the showcase composes both compact variants.
