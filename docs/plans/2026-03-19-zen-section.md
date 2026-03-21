# Zen Section Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the experimental `ZenListSection` surface with a new reusable `ZenSection` primitive and migrate tests plus showcase usage to the new API.

**Architecture:** Build `ZenSection` as a regular SwiftUI view with optional header and footer slots plus a grouped body container styled from theme tokens. Add `ZenSectionHeader` and `ZenSectionFooter` as composable helper primitives, then remove the old list-section files and update all call sites.

**Tech Stack:** Swift 5.9, SwiftUI, Swift Testing, Swift Package Manager

---

### Task 1: Update smoke tests to the new API and verify RED
### Task 2: Implement `ZenSection`, `ZenSectionHeader`, and `ZenSectionFooter`
### Task 3: Remove old list-section files and migrate call sites
### Task 4: Update showcase usage to demonstrate `ZenSection`
### Task 5: Run focused verification and full `swift test`
