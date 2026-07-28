---
name: godot-architecture-refactor
description: Guidance for POLAR V's current top priority — modularizing the 700+ line Game.gd into specialized manager/controller scripts (DecorationController, SaveManager, NavigationManager, OccupancyManager, SelectionManager) without changing behavior. Use whenever the user wants to refactor Game.gd, split up a god-object script, add a new manager/controller, or asks "where should this logic live" in this Godot project.
---

# POLAR V — Architecture Refactor (Current Priority)

## Why this exists
`Game.gd` grew past 700 lines by absorbing decoration, save, navigation, occupancy, and selection logic directly. The decision was made to **stop adding features on top of it** and instead extract responsibilities into dedicated manager scripts. This is not a rewrite — behavior must stay identical at every step.

## Target shape
```
scripts/world/
├── Game.gd                 — coordinator only: owns/wires the managers, top-level state machine
├── DecorationController.gd — placement/rotation/move/delete flow, preview state
├── SaveManager.gd          — load/autosave, JSON read-write (see godot-save-persistence)
├── NavigationManager.gd    — rebuild_navigation_blockers / bake_navigation_polygon calls (see godot-navigation-pathfinding)
├── OccupancyManager.gd     — occupied_cells bookkeeping (see godot-decoration-system)
└── SelectionManager.gd     — what's currently selected (inventory item, placed object)
```
`Game.gd`'s end-state job is only: hold references to each manager, respond to the game state enum (`GAMEPLAY`, `DECORATION_MODE`, `MENU`, `VISITING`), and route input/events to the right manager. It should not contain placement math, save I/O, or navigation calls directly once the refactor is done.

## Refactor rules
1. **One extraction at a time.** Pick one responsibility (e.g. save/load), move it to its manager, keep the game fully playable, then stop and confirm before starting the next one. Don't attempt to extract everything in a single pass.
2. **No behavior changes during extraction.** This is pure move-and-wire, not a rewrite of logic — bugs found along the way get noted for a separate fix, not silently "improved" mid-refactor.
3. **Preserve existing contracts.** Other systems already call things like `rebuild_navigation_blockers()`/`bake_navigation_polygon()` (see `godot-navigation-pathfinding`) and rely on the save JSON shape (see `godot-save-persistence`) — when a piece of logic moves into a manager, keep its public function names/signatures the same where possible so callers don't need simultaneous changes.
4. **Wiring pattern:** prefer `Game.gd` holding manager instances as `@onready` node references or plain instantiated objects, with managers communicating back to `Game.gd` (or to each other) via signals rather than manager scripts reaching into `Game.gd`'s state directly. This keeps the coordinator role clean and avoids circular dependencies.
5. **Order suggestion** (can be reordered based on what's riskiest to leave tangled): SaveManager → OccupancyManager → NavigationManager → DecorationController → SelectionManager, since save/occupancy are read by the others.

## When the user asks for a new feature instead
If a request would add new logic to `Game.gd` while this refactor is still in progress, point out that it should go into the appropriate manager (existing or newly extracted) instead of growing `Game.gd` further — but still help implement it there if the user wants to proceed.

## After the refactor
Once `Game.gd` is a thin coordinator, the project's next planned step (per the master context) is building the new professional UI — not new gameplay systems yet, unless the user directs otherwise.
