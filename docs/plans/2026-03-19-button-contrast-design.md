# Zen Button Contrast Design

**Date:** 2026-03-19

**Goal:** Ustalić sposób doboru koloru tekstu dla wbudowanych wariantów `ZenButton` na podstawie koloru tła.

## Context

Aktualnie [`ZenButtonResolvedStyle`](/Users/kuba/Desktop/ZenKit/Sources/ZenKit/Components/ZenshiButtonStyle.swift) przypisuje `foregroundColor` ręcznie per wariant. W tokenach kolorów istnieje już logika kontrastu przez `ZenColorComponents.accessibleForeground`, używana do `primaryForeground`.

## Decision

Przyjmujemy podejście hybrydowe:

- warianty z rzeczywistym tłem (`default`, `outline`, `secondary`, `destructive`) wyliczają kolor tekstu z koloru tła
- warianty transparentne (`ghost`, `link`) zachowują obecne semantyczne foregroundy

## Rationale

To podejście daje automatyczną adaptację do zmian theme dla buttonów wypełnionych, ale nie zgaduje foregroundu dla wariantów z `clear`, gdzie faktyczne tło zależy od rodzica.

## Testing

Potrzebne są testy sprawdzające, że:

- `default`, `outline`, `secondary`, `destructive` używają foregroundu wynikającego z odpowiednich tokenów tła
- `ghost` pozostaje przy `textPrimary`
- `link` pozostaje przy `accent`
