# Zen Onboarding Design

**Date:** 2026-03-22

**Goal:** Zaprojektować pełnoekranowy, reusable zestaw prymitywów `ZenOnboarding` dla SwiftUI, z animowanym mesh gradient background, grain overlay i przejściami między ekranami, bez narzucania gotowych bloków treści w pierwszym etapie.

## Context

ZenKit ma dziś [`ZenOnboardingCard`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenOnboardingCard.swift), ale jest to mały surface informacyjny osadzany wewnątrz innych ekranów. Brakuje pełnoekranowego flow onboardingowego, które mogłoby pełnić rolę wejścia do produktu albo showcase'owego hero experience.

Repo preferuje:

- composable SwiftUI primitives
- builder-driven API zamiast string-heavy convenience layers
- izolowane reusable surfaces zamiast task-specific ekranów
- showcase-first ocenę UX i motion w aplikacji demonstracyjnej

## Problem Statement

Potrzebny jest nowy onboarding primitive, który:

- wspiera pełnoekranowy flow wieloekranowy
- dostarcza charakterystyczne tło mesh gradient + grain
- animuje przejścia między krokami w sposób premium, ale bezpieczny jako domyślny UX
- pozostawia treść ekranu w rękach użytkownika biblioteki
- może później stanowić bazę również pod `ZenLoginScreen`

## Goals

- `ZenOnboarding` jako główny entry point dla full-screen onboarding flow
- hybrydowe API: prosty model stron plus composable wariant builderowy
- `backgroundStyle` ukrywający szczegóły implementacji mesh/grain
- `transitionStyle` kontrolujący charakter przejść między stronami
- showcase pokazujący zarówno subtelny default, jak i bardziej ekspresyjny wariant

## Non-Goals

- gotowe bloki treści typu headline/body/CTA group w pierwszym etapie
- logika biznesowa CTA, routingu i zapisu stanu ukończenia onboardingu
- snapshotowe testowanie motion
- integracja z login screenem w tym tasku

## Recommended Approach

Zbudować `ZenOnboarding` jako hybrydowy kontener full-screen, oparty o kilka niższych warstw odpowiedzialnych za tło, grain i page transitions. Publiczny surface pozostaje prosty, ale implementacja zachowuje modułowość i możliwość rozszerzania.

To podejście daje:

- dobry developer experience dla typowego use case
- rozsądny poziom reusability dla tła i przejść
- bezpieczny punkt startowy dla kolejnych surfaces, takich jak login screen

## Alternatives Considered

### 1. Monolityczny flow component

Jeden typ zarządza wszystkim: stronami, tłem, grainem, CTA i paginacją. Byłby szybki do wdrożenia, ale źle pasuje do ZenKit jako biblioteki i szybko zrobiłby się zbyt sztywny.

### 2. Tylko niskopoziomowe primitives

Osobne typy dla mesh backgroundu, grain overlay, pagera i containera strony. Architektonicznie czyste, ale zbyt ciężkie w użyciu jako pierwszy publiczny surface.

### 3. Hybrid container

Publiczny `ZenOnboarding` wsparty niższymi warstwami wewnętrznymi lub częściowo publicznymi. To najlepszy kompromis między ergonomią a modularnością.

## Proposed API

Wariant model-driven:

```swift
ZenOnboarding(
    pages: pages,
    selection: $selection,
    backgroundStyle: .animatedMesh(),
    transitionStyle: .default
) { page in
    page.content
}
```

Wariant builder-driven:

```swift
ZenOnboarding(selection: $selection) {
    ZenOnboardingStep(id: "welcome") { ... }
    ZenOnboardingStep(id: "focus") { ... }
    ZenOnboardingStep(id: "sync") { ... }
}
```

Założenia:

- `ZenOnboarding` odpowiada za layout full-screen, selection state i animację zmiany kroku
- `ZenOnboardingStep` jest lekkim wrapperem identyfikującym stronę
- `backgroundStyle` kontroluje mesh, grain i intensywność ruchu
- `transitionStyle` kontroluje przejścia contentu bez mieszania się z treścią strony
- treść strony pozostaje zwykłym SwiftUI `View`

## Architecture

Docelowa struktura pierwszego etapu:

- `ZenOnboarding` jako główny kontener
- `ZenOnboardingStep` jako identyfikowalna strona
- `ZenOnboardingBackgroundStyle` dla mesh/grain presetów
- `ZenOnboardingTransitionStyle` dla subtelnego i ekspresyjnego profilu animacji
- reuse istniejącego [`ZenPageIndicator`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenPageIndicator.swift), jeśli pasuje wizualnie

Nazewnictwo pozostaje rozdzielone:

- `ZenOnboarding` dla full-screen flow
- `ZenOnboardingCard` dla małego surface embedded w innych widokach

## Interaction Model

- `selection` jest zewnętrznie kontrolowane przez `Binding`
- komponent nie zarządza akcjami CTA ani routingiem
- zmiana strony wywołuje skoordynowaną animację contentu i tła
- dla `Reduce Motion` mocniejsze transformacje są redukowane do prostszego fade/opacity

## Visual Direction

Domyślny kierunek motion:

- subtelny, premium i bezpieczny produkcyjnie
- wolny drift mesh gradientu
- delikatny grain overlay
- miękkie crossfade i lekki blur/offset treści

Showcase powinien dodatkowo demonstrować wariant bardziej ekspresyjny:

- bardziej zauważalne morphing/shift tła
- wyraźniejsze przejścia między stronami

Mesh gradient nie powinien opierać się na pełnej losowości. Lepiej użyć deterministycznych presetów punktów i kolorów per strona, żeby przejścia były stabilne i estetyczne.

## Performance Guidance

- grain powinien być lekki: proceduralny lub tiled texture z animowanym offsetem/opacities
- unikać ciężkich efektów GPU i nadmiaru nakładających się blurów
- style powinny ukrywać parametry implementacyjne, żeby w przyszłości można było zoptymalizować mechanikę bez łamania API

## Testing Strategy

Na pierwszy etap:

- smoke test public surface dla nowych typów w `ZenKitTests`
- aktualizacja showcase smoke testu po dodaniu nowego ekranu katalogowego
- manualna weryfikacja motion i odbioru wizualnego w showcase

Na ten etap nie planujemy ścisłych testów snapshotowych animacji, bo koszt utrzymania byłby wyższy niż wartość.

## Risks

- spadek płynności na starszych urządzeniach przy zbyt ciężkim backgroundzie
- zbyt szerokie API odsłaniające za dużo szczegółów implementacji gradientu
- nieczytelne rozróżnienie między `ZenOnboarding` a `ZenOnboardingCard`, jeśli showcase nie pokaże ich odmiennych ról

## Decision

Implementować `ZenOnboarding` jako full-screen hybrid container z hybrydowym API, ukrytymi stylami tła i przejść, oraz showcase'em pokazującym subtelny default i mocniejszy wariant demonstracyjny.
