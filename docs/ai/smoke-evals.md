# ZenKit AI Smoke Evals

Use these prompts to sanity-check the skills and `LLM.md`.

## Component Selection

- "Buduję ekran ustawień konta, jakich komponentów ZenKit użyć?"
- "Mam filtr z wieloma opcjami i apply, czego użyć?"
- "Chcę pusty stan z CTA i ikoną."
- "Potrzebuję menu z akcjami destrukcyjnymi i zagnieżdżonym submenu."

## Screen Composition

- "Ułóż ekran profilu z formularzem, przyciskiem zapisu i stanem ładowania."
- "Złóż dashboard z kartami, metrykami i paskiem postępu w ZenKit."
- "Pokaż screen listy projektów z nawigacją, swipe actions i empty state."

## Migration

- "Mam natywny `Form` i `Section`, jak to zmigrować do ZenKit?"
- "Mam `List` z własnymi `NavigationLink` i `Toggle`; wskaż mapowanie na ZenKit."
- "Ten fragment SwiftUI ma zostać częściowo natywny. Co warto, a czego nie warto migrować?"

## Acceptance Checks

- odpowiedź wskazuje istniejące ZenKit API
- rekomendacja odwołuje się do właściwej kategorii
- pojawia się 1-3 realnych repo references
- model nie proponuje nowego primitive, jeśli katalog zawiera sensowny odpowiednik
- kod przykładowy wygląda jak kompozycja ZenKit, a nie ogólny SwiftUI boilerplate
