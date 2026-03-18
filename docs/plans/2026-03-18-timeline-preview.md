# Timeline Preview Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Expand the existing timeline preview to demonstrate basic, rich, and terminal timeline item compositions.

**Architecture:** Keep the change preview-only and local to `ZenTimelineItem.swift`. Rework the existing `#Preview` content to show three representative compositions using the current public timeline primitives and existing ZenKit components.

**Tech Stack:** SwiftUI, Swift Package Manager, swift test

---

### Task 1: Update the timeline preview

**Files:**
- Modify: `Sources/ZenKit/Components/ZenTimelineItem.swift`

**Step 1: Edit the existing preview**

Replace the current preview content with three compact examples:
- a simple activity feed row,
- a richer row with badge and card-like nested content,
- a final row with `showsSeparator: false`.

**Step 2: Run verification**

Run: `swift test`
Expected: PASS
