# Navigation Row Icon Style Design

**Goal:** Align `ZenNavigationRow` more closely with the visual language of `ZenCardHeader` without copying its full badge treatment.

**Decision:** Use a lighter-touch leading icon style. The navigation row will keep its current layout, muted icon color, row spacing, and accessory behavior. The only visual change is adding a subtle rounded background behind the leading icon so it feels more intentional and closer to the card header style.

**Scope:**
- Modify `Sources/ZenKit/Components/ZenshiNavigationRow.swift`
- Leave `Sources/ZenKit/Components/ZenshiNavigationLink.swift` unchanged because it is a wrapper and does not render the leading icon itself
- Avoid API changes unless a minimal internal testing hook is needed

**Testing approach:** Follow the package's current pattern by exposing a small internal style constant for tests and asserting it from `Tests/ZenKitTests`.
