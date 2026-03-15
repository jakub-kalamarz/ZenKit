# ZenKit Tuist Showcase Design

## Goal

Ułożyć repo `ZenKit` jako monorepo, w którym biblioteka komponentów pozostaje czystym Swift Package, a obok niej działa generowany przez Tuist workspace z aplikacją showcase do rozwijania i prezentowania komponentów.

## Recommended Approach

Najlepszym podejściem jest warstwa Tuista nad istniejącym pakietem, bez przepisywania samej biblioteki na targety Tuista. `ZenKit` pozostaje lokalnym package dependency i źródłem prawdy dla reusable API, natomiast Tuist zarządza workspace, aplikacją `ZenKitShowcase` i ewentualnymi dodatkowymi targetami developerskimi.

To daje niski koszt wejścia, zachowuje kompatybilność z SPM i pozwala rozwijać środowisko pracy nad komponentami bez mieszania kodu biblioteki z logiką katalogu demo.

## Alternatives Considered

### 1. Swift Package + ręcznie utrzymywana appka Xcode

Najprostszy start, ale słabsza skalowalność konfiguracji i gorsza kontrola nad przyszłym rozwojem workspace.

### 2. Pełna migracja biblioteki do targetów Tuista

Jeden system konfiguracji, ale niepotrzebnie zwiększa koszt migracji i osłabia prostotę dystrybucji `ZenKit` jako pakietu.

### 3. Tuist workspace + lokalny package + showcase app

Rekomendowany wariant. Zachowuje czystość biblioteki i dodaje wygodne środowisko do pracy nad komponentami.

## Approved Architecture

Repo pozostaje monorepo z trzema warstwami odpowiedzialności:

- `ZenKit` jako biblioteka komponentów i tokenów
- `ZenKitShowcase` jako aplikacja developerska do katalogu komponentów
- `Tuist` jako warstwa konfiguracji workspace i targetów

Docelowy układ:

```text
ZenKit/
├── Package.swift
├── Sources/ZenKit/
├── Tests/ZenKitTests/
├── Workspace.swift
├── Project.swift
├── Tuist/
│   └── Package.swift
├── App/
│   └── ZenKitShowcase/
│       ├── Sources/
│       ├── Resources/
│       └── Tests/
└── docs/
    └── plans/
```

## Responsibility Boundaries

`ZenKit` zawiera wyłącznie kod reusable:

- komponenty
- tokeny
- foundation helpers
- public API i testy biblioteki

`ZenKitShowcase` zawiera wyłącznie kod developerski:

- katalog komponentów
- routing i app shell
- sample data
- demo states
- przykłady użycia
- lekkie testy integracyjne showcase

Żaden kod showcase nie powinien trafiać do `Sources/ZenKit`, a showcase powinien konsumować bibliotekę wyłącznie przez jej publiczne API.

## Showcase App Structure

Aplikacja showcase powinna być zorganizowana według sposobu przeglądania systemu komponentów, a nie według typów plików.

Rekomendowany podział:

- `Sources/App` dla entrypointu i shella aplikacji
- `Sources/Catalog` dla list komponentów i nawigacji
- `Sources/Screens` dla ekranów demo
- `Sources/Support` dla sample data i helperów developerskich
- `Resources` dla assetów specyficznych dla showcase

W katalogu komponentów warto grupować ekrany według domen UI:

- `Foundations`
- `Inputs`
- `Feedback`
- `Navigation`
- `Surfaces`
- `Data Display`

## Demo Screen Rules

Każdy ważniejszy komponent lub rodzina komponentów powinna mieć własny ekran demo. Ekran powinien pokazywać:

- podstawowy wariant
- warianty wizualne
- stany skrajne
- sizing
- theming
- przykładowe użycie

Dodatkowo showcase powinien pokazywać przypadki, które zwykle psują API lub layout, na przykład:

- bardzo długie teksty
- disabled state
- loading state
- empty state
- zagnieżdżone użycie w kartach i listach

## Testing Strategy

Testy bibliotekowe pozostają w `Tests/ZenKitTests` i dalej chronią publiczną warstwę `ZenKit`.

Showcase nie powinien dublować testów komponentów. Jego testy powinny obejmować tylko:

- smoke tests dla uruchomienia głównych ekranów
- podstawowe testy routingu katalogu
- opcjonalnie snapshoty lub testy wizualne w późniejszym etapie

## Non-Goals For V1

Pierwsza wersja nie powinna obejmować:

- logiki produktowej prawdziwej aplikacji
- backendu lub persistence
- rozbudowanego systemu dokumentacji poza samą appką showcase
- migracji `ZenKit` z SPM na pełne targety Tuista

## Development Workflow

Praca nad nowym komponentem powinna wyglądać tak:

1. dodać lub zmienić komponent w `ZenKit`
2. dodać lub zaktualizować testy biblioteki
3. dodać ekran demo w showcase
4. sprawdzić zachowanie w stanach normalnych i brzegowych

Jeżeli showcase wymaga nieeleganckich obejść, należy poprawić publiczne API biblioteki, a nie ukrywać problem w kodzie demo.
