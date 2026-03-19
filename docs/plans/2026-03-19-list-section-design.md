# Zen List Section Design

**Date:** 2026-03-19

**Goal:** Zaprojektować komponent odpowiadający `Section` w `List`, który zachowuje semantykę SwiftUI, ale używa stylistyki ZenKit opartej o theme primitives zamiast stringowego, domenowego API.

## Context

Aktualny [`ZenListSection`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenshiListSection.swift) jest prostym `VStack`, który nadaje się do luźnego grupowania treści, ale nie odpowiada natywnemu `Section` osadzanemu w `List`.

W repo istnieją już theme-driven primitives, zwłaszcza [`ZenCard`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenshiCard.swift), które definiują język wizualny przez tokeny takie jak `surface`, `border`, spacing oraz rozwiązywanie corner radius z theme. Nowy komponent sekcji powinien korzystać z tego samego języka, ale nie powinien wyglądać jak pełna karta.

## Problem Statement

Potrzebny jest listowy primitive, który:

- zachowuje mental model natywnego `Section`
- wspiera dowolny `header` i `footer` przez `ViewBuilder`
- nie przyjmuje `String` ani `LocalizedStringKey`
- pozwala budować ergonomię przez osobne prymitywy nagłówka i stopki
- daje sekcji lekki, grouped wygląd zgodny z ZenKit theme

## Goals

- API bliskie natywnemu `Section`
- semantyka oparta o `SwiftUI.Section`
- header nad grupą rowów, footer pod nią
- theme-driven styling dla body sekcji
- composable header/footer primitives bez shortcutów stringowych

## Non-Goals

- budowanie drugiego `ZenCard`
- automatyczne stylowanie dowolnych rowów wewnątrz sekcji
- API domenowe oparte o `title`, `subtitle`, `footerText`
- rozbudowany system wariantów typu `.plain`, `.grouped`, `.card`

## Recommended Approach

Zaprojektować `ZenListSection` jako komponent listowy bazujący semantycznie na `SwiftUI.Section`, ale z własną oprawą wizualną dla grouped body. Nagłówek i stopka mają być przekazywane jako dowolne widoki, a zalecanym sposobem ich budowania mają być osobne primitives: `ZenListSectionHeader` i `ZenListSectionFooter`.

To podejście zachowuje zgodność z oczekiwaniami użytkownika SwiftUI, a jednocześnie daje spójny język wizualny ZenKit bez wprowadzania ciężkiego, stringowego API.

## Alternatives Considered

### 1. Bardzo cienki wrapper nad `Section`

Sekcja tylko przekazywałaby `header`, `footer` i `content` do natywnego `Section`, stylując wyłącznie typografię nagłówka i stopki.

Ten wariant jest najbezpieczniejszy technicznie, ale daje za mało wartości jako primitive design systemu i nie tworzy spójnego grouped treatment dla body sekcji.

### 2. Sekcja stylizowana jak `Card`

Sekcja dostawałaby pełny card chrome podobny do `ZenCard`, z wyraźnym paddingiem, borderem i radiusami na całym komponencie.

Ten wariant zbyt mocno przesuwa sekcję w stronę panelu i osłabia wrażenie natywnego `Section` w `List`.

### 3. Rozbudowany system stylów sekcji

Oddzielny `ZenListSectionStyle` lub kilka wariantów wyglądu.

Ten wariant jest zbyt szeroki na obecny etap i wprowadza przedwczesną abstrakcję bez potwierdzonej potrzeby.

## Proposed API

```swift
ZenListSection {
    ZenSettingRow(...)
    ZenSettingRow(...)
} header: {
    ZenListSectionHeader {
        Text("Workspace")
    } subtitle: {
        Text("Shared settings and access")
    }
} footer: {
    ZenListSectionFooter {
        Text("Only admins can change billing details.")
    }
}
```

Założenia:

- `ZenListSection` przyjmuje `content`, `header` i `footer` przez `ViewBuilder`
- header i footer są dowolnymi widokami
- ergonomia jest budowana przez primitives, nie przez string overloads
- warto dodać overloady bez `header` i bez `footer`, zgodnie z ergonomią natywnego `Section`

## Visual Design

Komponent powinien wyglądać bardziej jak stylizowany `Section` niż jak `Card`.

Układ:

- `header` nad grouped body
- `content` wewnątrz lekkiego grouped container
- `footer` pod grouped body

Zasady wizualne:

- header i footer pozostają poza obramowanym kontenerem
- tylko body sekcji dostaje grouped chrome
- grouped chrome korzysta z `Color.zenSurface`, `Color.zenBorder` i radiusów wynikających z theme
- wygląd ma być lżejszy niż `ZenCard`
- nie używamy pełnego `cardPadding` jako głównego rytmu całej sekcji

## Responsibilities

### `ZenListSection`

- opakowuje natywny `Section`
- odpowiada za strukturę sekcji i grouped chrome body
- zapewnia theme-driven spacing między header, body i footer

### `ZenListSectionHeader`

- dostarcza zalecany primitive dla title/subtitle layout
- odpowiada za typografię, kolor i spacing nagłówka
- pozostaje composable i nie wymaga stringów

### `ZenListSectionFooter`

- dostarcza zalecany primitive dla pomocniczego tekstu lub custom footer content
- odpowiada za muted styling i rytm stopki

### Row Content

- zachowuje własną odpowiedzialność za layout, hit testing i accessory behavior
- nie jest automatycznie restylowany przez sekcję

## Testing Strategy

Potrzebne są:

- preview lub showcase z wariantem basic, header-only, header+footer i custom header
- smoke tests public surface dla nowych inicjalizatorów
- testy weryfikujące, że komponenty pozostają publiczne i spójne z konwencjami API repo

## Showcase Plan

Warto dodać osobny ekran showcase lub zaktualizować istniejący ekran settings/list tak, żeby pokazywał:

- prostą sekcję z `ZenListSectionHeader`
- sekcję z footerem
- sekcję z bardziej niestandardowym headerem

## Risks

- Zbyt ciężki chrome sprawi, że komponent zacznie wyglądać jak `Card`
- Zbyt wiele automatycznych opinii o rowach utrudni użycie komponentu z istniejącymi primitives
- Zbyt cienki wrapper nie uzasadni istnienia nowego primitive w design systemie

## Decision

Implementować `ZenListSection` jako semantyczny wrapper nad `SwiftUI.Section` z lekkim grouped body i composable header/footer primitives. API ma pozostać bliskie natywnemu SwiftUI, a ergonomia ma wynikać z osobnych primitives zamiast stringowych shortcutów.
