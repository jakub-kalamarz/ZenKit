# ZenKit

ZenKit to biblioteka nowoczesnych, reużywalnych prymitywów SwiftUI wykorzystywanych w ekosystemie ZenKit.

## Funkcje

- **Zorientowane na design**: Komponenty są zbudowane w oparciu o wspólne tokeny (kolory, typografia, odstępy).
- **Elastyczność**: Preferujemy kompozycję (`ViewBuilder`) nad sztywnymi API opartymi o ciągi znaków.
- **Wsparcie platform**: iOS 17.0+ oraz macOS 13.0+.
- **Showcase**: Dołączona aplikacja demo prezentująca wszystkie dostępne komponenty.

## Struktura biblioteki

Komponenty w `Sources/ZenKit/Components/` są podzielone na kategorie:

- **DataDisplay**: Prezentacja danych (Avatar, Badge, Progress, Metrics).
- **Feedback**: Informacje zwrotne (Alert, Spinner, Loading, Skeleton).
- **Inputs**: Kontrolki formularzy (Button, TextInput, MultiSelect, Toggle).
- **Layout**: Struktura ekranów i sekcji (ZenScreen, ListScreen, Sections).
- **Navigation**: Elementy nawigacyjne (Menu, Rows).
- **Surfaces**: Kontenery i struktury danych (Card, Sheet, Settings).
- **System**: Infrastruktura techniczna (Overlays, Toasts).

## Instalacja (Swift Package Manager)

Dodaj ZenKit jako zależność w swoim `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/zenshi/ZenKit.git", branch: "main")
]
```

## Szybki start

```swift
import SwiftUI
import ZenKit

struct MyView: View {
    var body: some View {
        ZenScreen(navigationTitle: "Dashboard") {
            ZenCard(title: "Witaj") {
                Text("To jest Twój nowy panel.")
                ZenButton("Rozpocznij") {
                    print("Start!")
                }
            }
        }
    }
}
```

## Rozwój i testowanie

- **Testy jednostkowe**: `swift test`
- **Aplikacja Showcase**: Otwórz `ZenKit.xcworkspace` i uruchom schemat `ZenKitShowcase`.

Więcej informacji technicznych znajdziesz w pliku [LLM.md](LLM.md).
