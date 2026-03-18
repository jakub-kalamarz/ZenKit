# Timeline Primitives Design

**Date:** 2026-03-18

## Goal

Dodać do ZenKit composable primitives dla timeline, tak aby z tego samego zestawu dało się składać zarówno prosty activity feed, jak i bogatsze warianty z własnym indykatorem, badge'ami, kartami i rozwijaną treścią.

## Decision

Przyjmujemy model oparty o małe prymitywy:

- `ZenTimeline`
- `ZenTimelineItem`
- `ZenTimelineHeader`
- `ZenTimelineIndicator`
- `ZenTimelineSeparator`
- `ZenTimelineContent`
- `ZenTimelineTitle`
- `ZenTimelineDate`

Prymitywy odpowiadają za strukturę, spacing i wyrównanie osi. Nie zawierają logiki stanów typu `pending`, `active`, `completed` ani gotowych elementów typu badge, avatar czy collapsible content.

## Why this approach

- Najlepiej mapuje kompozycyjny styl znany z reui/shadcn bez przenoszenia webowego API 1:1 do SwiftUI.
- Usuwa ograniczenia obecnego `ZenTimelineItem`, który jest gotowym widgetem o z góry narzuconym układzie.
- Pozwala budować wiele wariantów bez rozrostu jednego komponentu i bez mnożenia wariantów stylu.

## API Direction

- `ZenTimeline` jest pionowym kontenerem dla elementów osi.
- `ZenTimelineItem` zarządza układem lewa kolumna plus prawa treść i opcjonalnie wie, czy separator ma być widoczny.
- `ZenTimelineHeader` grupuje tytuł oraz elementy blisko osi.
- `ZenTimelineIndicator` jest slotem na dowolny content użytkownika, ale ma domyślny rozmiar i pozycjonowanie zgodne z systemem.
- `ZenTimelineSeparator` rysuje pionową linię kontynuującą oś.
- `ZenTimelineContent`, `ZenTimelineTitle` i `ZenTimelineDate` dostarczają lekkie, spójne typograficznie opakowania.

## Scope

Pierwsza iteracja obejmuje:

- tylko układ pionowy,
- brak wbudowanego modelu statusów,
- brak wbudowanego collapse,
- showcase z dwoma przykładami:
  - prosty activity feed,
  - bardziej złożony wariant pipeline-like z własnym contentem.

## Compatibility

Obecny `ZenTimelineItem` zostanie zastąpiony nowym zestawem prymitywów. Showcase timeline zostanie przepisany na nowe API. Jeśli w repo pojawi się potrzeba zachowania zgodności, można później dodać osobny convenience wrapper zbudowany na nowych prymitywach.

## Testing

- smoke test public surface dla nowych typów,
- aktualizacja showcase smoke tests, jeśli screen lub nazewnictwo katalogu się zmienią,
- `swift test`,
- build aplikacji showcase przez `xcodebuild`.
