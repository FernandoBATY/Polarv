---
name: godot-ui-mobile-design
description: UI/UX patterns for POLAR V's touch-first mobile interface — Control node layout, WindowBase/panel patterns, responsive anchors for different phone sizes, and the upcoming "professional UI" pass planned after the Game.gd refactor. Use whenever the user builds or restyles UI screens (inventory, windows, HUD, menus), works on WindowBase.gd/UIRoot.gd/InventoryUI/FurnitureSlot, or asks about responsive layout, touch targets, or UI flow for this Godot mobile game.
---

# POLAR V — Mobile UI Design

## Foundational rule
This is a **touch-first, portrait-oriented mobile game** (cozy/social genre, warm illustrated style — see `polar-v-project-context`). Every UI decision should assume a phone in one hand, thumb-reachable controls, and no keyboard/mouse.

## Layout & responsiveness
- Use Godot's `Control` anchoring/containers (`MarginContainer`, `VBoxContainer`/`HBoxContainer`, `GridContainer`) instead of fixed pixel positions, so screens adapt across phone aspect ratios (tall Android phones vs iPhone notch/Dynamic Island proportions).
- Design against a base resolution but verify against at least one very tall (e.g. 20:9) and one more square-ish (e.g. tablet/iPad) aspect ratio — cozy games get played on tablets too even if not primary target.
- Respect safe-area insets on iOS (notch, home indicator) and gesture-nav insets on Android — keep primary actions out of the bottom ~24px and top status-bar strip.

## Existing UI components (build on these, don't duplicate)
- `UIRoot.tscn`/`UIRoot.gd` — top-level UI container.
- `WindowBase.tscn`/`WindowBase.gd` — the reusable panel/modal base. New screens (shop, gachapon, NPC dialogue) should extend `WindowBase` rather than building bespoke panel scenes, so open/close animation, backdrop dimming, and input-blocking behavior stay consistent.
- `InventoryUI.gd` + `FurnitureSlot.gd` — grid-based item selection with ghost-click protection (`block_next_decoration_click`). Any new grid-of-items UI (gachapon results, shop stock) should reuse `FurnitureSlot`'s interaction pattern rather than reinventing tap handling.

## Touch targets & feedback
- Minimum tappable area ~44x44pt (iOS HIG) / ~48x48dp (Material) even if the visible icon is smaller — pad hit areas, don't shrink icons to fit cramped layouts.
- Provide visual press feedback (scale-down or highlight) on every tappable element — mobile players get no hover state, so the only affordance is on-press feedback.
- Avoid double-tap-to-confirm patterns for common actions; reserve confirmation dialogs for destructive/costly actions (deleting a placed decoration, spending premium currency).

## Modal/window stacking
- Only one `WindowBase` modal should capture input at a time; when opening a new window, close or explicitly stack-pause the previous one rather than layering multiple simultaneous input-blocking panels (a known source of the ghost-click issue that `block_next_decoration_click` was built to guard against — see `godot-decoration-system`).
- Back/close behavior should be consistent everywhere: same corner position and same gesture (tap-outside-to-close for lightweight panels, explicit close button only for panels with unsaved state like decoration mode).

## Planned "professional UI" pass (after the Game.gd refactor)
Per the project roadmap, once `Game.gd` is fully modularized (see `godot-architecture-refactor`), the next step is a UI quality pass. When that work starts:
1. Establish a shared style (`Theme` resource) for buttons, panels, fonts, and the warm color palette described in `polar-v-project-context`, instead of per-scene overrides.
2. Consolidate icon/9-patch assets into an atlas (ties into `godot-mobile-performance`'s draw-call guidance).
3. Prioritize the inventory and decoration-mode UI first, since those are the most-used screens.
