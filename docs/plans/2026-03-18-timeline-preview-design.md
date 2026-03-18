# Timeline Preview Design

**Date:** 2026-03-18

## Goal

Rozszerzyć istniejący preview timeline tak, aby lepiej pokazywał kompozycyjny charakter nowych primitives bez zmiany API ani runtime behavior.

## Decision

Zostawiamy cały scope w `Sources/ZenKit/Components/ZenTimelineItem.swift` i rozbudowujemy pojedynczy preview o trzy warianty:

- prosty activity row,
- bogatszy row z badge i card-like content,
- końcowy row bez separatora.

## Why this approach

- Najmniejszy możliwy diff.
- Preview dokumentuje faktyczny zakres kompozycji primitives.
- Nie dodaje nowych publicznych typów ani test surface.
