# Button Contrast Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Sprawić, żeby `ZenButton` dobierał kolor tekstu na podstawie własnego tła dla wbudowanych wariantów z rzeczywistym fill.

**Architecture:** Zmiana pozostaje lokalna dla `ZenButtonResolvedStyle`. Dodajemy mały helper mapujący `ZenDynamicColor` na kontrastowy `Color`, a zachowanie wariantów transparentnych zostaje bez zmian.

**Tech Stack:** Swift, SwiftUI, Testing

---

### Task 1: Opisać nowe zachowanie testami

**Files:**
- Modify: `Tests/ZenKitTests/ZenKitButtonTests.swift`

**Step 1: Write the failing test**

Dodać testy, które oczekują foregroundu wyliczanego z `primary`, `surface`, `surfaceMuted` i `critical`, oraz zachowania semantycznego dla `ghost` i `link`.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ZenKitButtonTests`

Expected: FAIL dla nowych asercji foregroundu.

### Task 2: Wprowadzić minimalną implementację

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiButtonStyle.swift`

**Step 1: Write minimal implementation**

Dodać helper do wyliczania kontrastowego `Color` z `ZenDynamicColor` i użyć go dla wariantów z rzeczywistym tłem.

**Step 2: Run test to verify it passes**

Run: `swift test --filter ZenKitButtonTests`

Expected: PASS

### Task 3: Zweryfikować regresje

**Files:**
- Modify: `Sources/ZenKit/Components/ZenshiButtonStyle.swift`
- Modify: `Tests/ZenKitTests/ZenKitButtonTests.swift`

**Step 1: Run broader verification**

Run: `swift test --filter ZenKitPublicSurfaceSmokeTests`

Expected: PASS
