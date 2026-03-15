# Zen Screen Shared Background Visibility Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Dodać do `ZenScreen` i `ZenListScreen` opcję wyłączenia domyślnego `sharedBackgroundVisibility(.hidden)` bez zmiany domyślnego zachowania.

**Architecture:** Oba komponenty dostaną nowy parametr `hidesSharedToolbarBackground` z domyślną wartością `true`. Flaga zostanie przekazana do helperów budujących `ToolbarItem`, które warunkowo zastosują `sharedBackgroundVisibility(.hidden)` tylko wtedy, gdy flaga jest włączona i platforma to iOS 26+.

**Tech Stack:** Swift, SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Dodać test publicznego API

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`

**Step 1: Write the failing test**

Dodać smoke test kompilacyjny tworzący `ZenScreen` i `ZenListScreen` z `hidesSharedToolbarBackground: false`.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: kompilacja/test fail, bo inicjalizatory nie przyjmują jeszcze nowego parametru.

**Step 3: Write minimal implementation**

Dodać parametr do publicznego API obu komponentów i przekazać go do helperów toolbar.

**Step 4: Run test to verify it passes**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS

### Task 2: Rozszerzyć implementację `ZenScreen`

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiScreen.swift`

**Step 1: Dodać pole i parametr**

Uzupełnić główny init i wszystkie overloady o `hidesSharedToolbarBackground: Bool = true`.

**Step 2: Przekazać flagę do helperów toolbar**

Zmienić wywołania `standardToolbarItem` i `principalToolbarItem`, aby przekazywały flagę.

**Step 3: Zmienić helper warunkowego modifiera**

Rozszerzyć helper `standardToolbarItem`, aby nakładał `sharedBackgroundVisibility(.hidden)` tylko przy wartości `true`.

### Task 3: Rozszerzyć implementację `ZenListScreen`

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiListScreen.swift`

**Step 1: Dodać pole i parametr**

Uzupełnić główny init i wszystkie overloady o `hidesSharedToolbarBackground: Bool = true`.

**Step 2: Przekazać flagę do helperów toolbar**

Zmienić wywołania `zenListScreenToolbarItem` i `zenListScreenPrincipalToolbarItem`, aby przekazywały flagę.

**Step 3: Zmienić helper warunkowego modifiera**

Rozszerzyć helper `zenListScreenToolbarItem`, aby nakładał `sharedBackgroundVisibility(.hidden)` tylko przy wartości `true`.

### Task 4: Zweryfikować zmianę

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitPublicSurfaceSmokeTests.swift`
- Modify: `Sources/ZenKit/Components/ZenshiScreen.swift`
- Modify: `Sources/ZenKit/Components/ZenshiListScreen.swift`

**Step 1: Run focused tests**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`
Expected: PASS

**Step 2: Run package tests**

Run: `swift test`
Expected: PASS
