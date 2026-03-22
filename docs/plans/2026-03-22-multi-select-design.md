# Zen Multi Select Design

**Date:** 2026-03-22

**Goal:** Zaprojektować lekki komponent `multi-select` do krótkich list opcji, używany m.in. do filtrów i wyboru kolumn, spójny z istniejącym API ZenKit i oparty o natywne prymitywy SwiftUI.

## Context

ZenKit ma już pojedynczy wybór przez [`ZenPickerRow`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenshiPickerRow.swift) oraz menu-driven actions przez [`ZenMenu`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenshiMenu.swift). Brakuje jednak lekkiego primitive do wielokrotnego wyboru, który nie wymaga od razu pełnego search/palette UX.

Repo preferuje komponenty:

- generyczne i composable
- oparte o `Binding`
- z ergonomią builder-driven zamiast string-heavy API tam, gdzie to ma sens
- testowane głównie przez smoke/API composition tests oraz showcase

## Problem Statement

Potrzebny jest komponent, który:

- pozwala zaznaczyć wiele opcji z krótkiej listy
- nadaje się do filtrów i zarządzania widocznością kolumn
- domyślnie działa natychmiast po kliknięciu
- opcjonalnie wspiera tryb `deferred` z akcją `Apply`
- pokazuje wybrane wartości w triggerze w sposób stabilny dla layoutu

## Goals

- lekki `multi-select` dla ok. 5-20 opcji
- trigger z hybrydowym podsumowaniem wyboru: do 2 etykiet, potem licznik
- konfigurowalny tryb interakcji: `immediate` lub `deferred`
- API kontrolowane przez `Binding<Set<Option>>`
- możliwość custom renderingu wiersza opcji i etykiet triggera

## Non-Goals

- pełnotekstowe wyszukiwanie
- grupowanie sekcji
- drag and drop do sortowania kolumn
- rozbudowany filter builder z operatorami
- osobny task-specific component dla każdej domeny

## Recommended Approach

Zbudować `ZenMultiSelect` jako lekki wrapper nad `Menu`. Dzięki temu komponent pozostaje natywny, prosty i dobrze pasuje do istniejącego `ZenPickerRow`. Trigger będzie własnym widokiem ZenKit, a zawartość menu będzie generowana z listy opcji wraz z checkmarkiem oraz opcjonalnymi akcjami `Clear` i `Apply`.

To podejście jest wystarczające dla krótkich list, ma niski koszt utrzymania i nie wymusza budowy custom popover/infrastructure już teraz.

## Alternatives Considered

### 1. Custom popover z własną listą

Daje pełną kontrolę nad layoutem i przyszłym rozszerzaniem, ale jest cięższy implementacyjnie, wymaga więcej state management i nie jest potrzebny dla potwierdzonego lekkiego zakresu.

### 2. Rozszerzenie `ZenPickerRow` o multi-select

Zmniejsza liczbę typów, ale miesza odpowiedzialności komponentu single-select i multi-select. API szybko stanie się mniej czytelne.

### 3. Search-first command picker

Przydatny dla większych zbiorów, ale za ciężki dla obecnego use case i wprowadza funkcjonalność, o którą nie proszono.

## Proposed API

```swift
ZenMultiSelect(
    title: "Columns",
    selection: $selectedColumns,
    options: Column.allCases,
    mode: .immediate
) { option in
    Text(option.title)
}
```

Opcjonalny wariant z custom trigger summary:

```swift
ZenMultiSelect(
    title: "Filters",
    selection: $selectedFilters,
    options: Filter.allCases,
    mode: .deferred
) { option in
    Text(option.title)
} summaryLabel: { selectedOptions in
    Text(summary(for: selectedOptions))
}
```

Założenia:

- `Option` jest `Hashable & Sendable`
- `selection` jest `Binding<Set<Option>>`
- `options` zachowuje kolejność prezentacji
- domyślne podsumowanie pokazuje placeholder, do 2 etykiet albo licznik `+N`
- `mode` kontroluje natychmiastową aktualizację albo wewnętrzny draft

## Interaction Model

### Immediate

- kliknięcie opcji od razu modyfikuje `selection`
- brak dodatkowych akcji zatwierdzających
- opcjonalne `Clear` może czyścić wybór natychmiast

### Deferred

- komponent utrzymuje lokalny draft po otwarciu menu
- kliknięcia zmieniają draft, ale nie zapisują `selection`
- `Apply` przepisuje draft do bindowania
- `Clear` czyści draft, a nie zewnętrzny stan, dopóki nie nastąpi `Apply`

## Visual Design

- trigger ma wyglądać jak lekki control ZenKit, spójny z `ZenPickerRow` i `ZenTagInput`
- tytuł po lewej, summary po prawej
- summary używa muted typography, gdy nic nie wybrano
- chevron komunikuje menu interaction
- zaznaczone opcje w menu dostają checkmark

## Testing Strategy

Potrzebne są:

- smoke test public surface dla obu trybów
- API convention test potwierdzający builder-based composition
- showcase screen z wariantem filtrów i kolumn

Logikę podsumowania warto wydzielić do małego helpera testowalnego bez UI runtime.

## Risks

- `Menu` ogranicza możliwości bardziej zaawansowanej interakcji i nie daje pełnej kontroli nad stopką akcji na każdej platformie
- tryb `deferred` wymaga ostrożnego modelowania draft state wewnątrz `Menu`
- zbyt bogaty API na starcie może skomplikować prosty komponent

## Decision

Implementować `ZenMultiSelect` jako lekki, generyczny primitive oparty o `Menu`, z kontrolowanym `Binding<Set<Option>>`, domyślnym hybrydowym summary oraz dwoma trybami: `immediate` i `deferred`.
