# Zen Screen Shared Background Visibility Design

**Problem:** `ZenScreen` i `ZenListScreen` zawsze stosują `sharedBackgroundVisibility(.hidden)` dla `ToolbarItem` na iOS 26+, bez możliwości wyłączenia tego zachowania.

**Decision:** Dodać do obu komponentów nowy parametr `hidesSharedToolbarBackground: Bool = true`.

**Why this approach:**
- Zachowuje pełną kompatybilność wsteczną.
- Jest prosty w użyciu i jasno komunikuje intencję.
- Nie wprowadza cięższego API tylko dla jednego przełącznika.

**Behavior:**
- `true`: obecne zachowanie pozostaje bez zmian.
- `false`: `ToolbarItem` jest tworzony bez `sharedBackgroundVisibility(.hidden)`.

**Implementation notes:**
- Parametr trafia do głównego inicjalizatora i wszystkich convenience overloadów `ZenScreen` oraz `ZenListScreen`.
- Helpery budujące toolbar items przyjmują flagę i warunkowo stosują modifier tylko na iOS 26+.
- Smoke test publicznego API obejmuje oba komponenty z ustawieniem `false`.
