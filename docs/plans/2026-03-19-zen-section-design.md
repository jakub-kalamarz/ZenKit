# Zen Section Design

**Date:** 2026-03-19

**Goal:** Wprowadzić nowy, ogólnego przeznaczenia primitive `ZenSection`, który zapewnia strukturę `header -> body -> footer`, własny grouped chrome oparty o theme oraz spójne zachowanie w `List`, `VStack` i `ScrollView`, bez zależności od natywnego `SwiftUI.Section`.

## Decision

Implementujemy nowy `ZenSection` zamiast dalszego stylowania wrappera nad natywnym `Section`. Stary `ZenListSection` i jego header/footer primitives zostają usunięte.

## Why

Natywne `List` i `Section` narzucają własny layout, insets i clipping, przez co rounded grouped container bywa przycinany i trudny do przewidywalnego wystylizowania. Potrzebujemy primitive, który daje pełną kontrolę nad:

- corner radius
- border
- background
- wewnętrznym spacingiem
- zachowaniem w preview, showcase i ekranach listowych

## Architecture

`ZenSection` jest pełnym primitive layoutowym:

- opcjonalny `header`
- stylowane `body`
- opcjonalny `footer`

Zalecanymi primitives dla części opisowych są:

- `ZenSectionHeader`
- `ZenSectionFooter`

`ZenSection` nie opiera się o systemowy `Section`. Jest zwykłym SwiftUI view, które może być osadzane wewnątrz `List`, `VStack`, `ScrollView` i innych kontenerów.

## API

```swift
ZenSection {
    ZenSettingRow(...)
    ZenSettingRow(...)
} header: {
    ZenSectionHeader {
        Text("Workspace")
    } subtitle: {
        Text("Shared settings and access")
    }
} footer: {
    ZenSectionFooter {
        Text("Only admins can change billing details.")
    }
}
```

Wspierane overloady:

- `ZenSection { ... }`
- `ZenSection { ... } header: { ... }`
- `ZenSection { ... } header: { ... } footer: { ... }`

Brak shortcutów stringowych. Header i footer są w pełni composable.

## Visual Rules

- `header` renderuje się nad body
- `body` renderuje się w lekkim grouped containerze opartym o theme
- `footer` renderuje się pod body
- grouped body używa `Color.zenSurface`, `Color.zenBorder` i radiusów wyliczanych z `ZenTheme`
- styl jest lżejszy niż `ZenCard`

## Usage in Lists

W `ZenListScreen` oraz natywnym `List` `ZenSection` jest używany jako zwykły widok. Sam komponent odpowiada za `listRowInsets` i `listRowBackground(.clear)`, tak żeby jego wygląd nie zależał od systemowego `Section`.

## Migration

- dodać `ZenSection`, `ZenSectionHeader`, `ZenSectionFooter`
- przepiąć testy i showcase na nowe nazwy
- usunąć `ZenListSection`, `ZenListSectionHeader`, `ZenListSectionFooter`
- nie zostawiać aliasów kompatybilności
