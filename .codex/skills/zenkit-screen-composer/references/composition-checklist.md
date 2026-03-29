# Composition Checklist

Before writing code:

1. Choose the screen shell:
   `ZenScreen`, `ZenScreen(containerStyle: .list, ...)`, or native SwiftUI.
2. Choose grouping:
   `ZenCard`, `ZenSection`, `ZenFieldSection`, `ZenSettingGroup`, or `ZenSheetContainer`.
3. Choose actions:
   `ZenButton`, `ZenInlineAction`, `ZenMenuItem`, `ZenSwipeAction`, or navigation rows.
4. Choose transient states:
   `ZenLoading`, `ZenSkeleton`, `ZenStatusBanner`, `ZenEmpty`, `ZenAlert`, `ZenConfirmationDialog`.
5. Use tokens for spacing and typography before ad hoc numbers or modifiers.

Prefer additive composition. Do not rebuild ZenKit surfaces from raw `VStack` + custom styling unless the catalog clearly lacks the needed primitive.
