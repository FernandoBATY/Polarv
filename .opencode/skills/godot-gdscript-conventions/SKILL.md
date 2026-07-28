---
name: godot-gdscript-conventions
description: Coding conventions and structural patterns for POLAR V's GDScript codebase — naming, typing, signals vs direct references between managers/controllers, export vars, and file organization. Use whenever the user writes new GDScript for this project, reviews/refactors existing scripts, or asks how a new manager/controller/system should be structured (especially during the Game.gd modularization work).
---

# POLAR V — GDScript Conventions

## Naming
- Scripts/classes: `PascalCase` (`DecorationController.gd`, `FurnitureItem.gd`).
- Files that are singletons/systems without a matching scene node can be lowercase (`player.gd` already exists this way — don't rename existing files just for consistency, but use PascalCase for anything new).
- Variables/functions: `snake_case`. Constants: `ALL_CAPS`.
- Signals: past-tense verbs, `snake_case` (`decoration_placed`, `navigation_rebaked`, `zone_unlocked`).
- Grid coordinates always named `cell` or `grid_pos` (a `Vector2i`), never `pos`/`position` alone, to avoid confusion with world-space `Vector2`.

## Typing
- Use static typing everywhere new code is written: `var occupied_cells: Dictionary = {}`, `func place(id: String, cell: Vector2i, rotation: int) -> bool:`. This project's mobile-first performance goals benefit from typed GDScript (faster, fewer runtime errors) — don't suggest dropping types for brevity.
- Type dictionaries/arrays with inline comments describing shape when GDScript can't express it natively, e.g. `# Dictionary[Vector2i, CellOccupancy]`.

## Manager/controller communication pattern
This matters most during the current `Game.gd` → managers refactor (see `godot-architecture-refactor`):
- **Downward calls** (coordinator → manager): direct method calls are fine. `Game.gd` calling `decoration_controller.begin_placement(id)` is normal.
- **Upward/lateral notifications** (manager → coordinator, or manager → manager): use **signals**, not direct references back into `Game.gd` or into a sibling manager. E.g. `DecorationController` emits `decoration_placed(cell, id, rotation)`; `Game.gd` connects that to `save_manager.request_autosave()` and `navigation_manager.rebake()`. Managers should not know about each other directly — `Game.gd` wires them.
- Avoid global/autoload state for anything that's really per-village session data. Autoloads are fine for truly global singletons (e.g. `FurnitureDatabase.gd`, which is static reference data), not for mutable session state.

## Export vars & resources
- Use `@export` for designer-tunable values (footprint sizes, colors, timers) so they're editable in the Inspector rather than hardcoded magic numbers in scripts.
- Prefer `Resource`/`.tres` custom resources for data tables (e.g. furniture definitions in `FurnitureDatabase.gd`) over parsing JSON at runtime for static data — reserve JSON for save files and future server payloads (see `godot-save-persistence`), where interop with Nakama/PostgreSQL matters.

## File organization
- One class per file, file name matches `class_name` when one is declared.
- Keep `scripts/` mirroring `scenes/` folder structure (`scripts/world/`, `scripts/player/`, `scripts/furniture/`, `scripts/ui/`) as already established — new systems should follow the same mirroring rather than a flat `scripts/` dump.

## Comments & documentation
- Prefer self-documenting names over comments explaining *what* code does; use comments for *why* (e.g. "# server will eventually own this value, client is prediction only" — tie back to `godot-save-persistence`'s server-authoritative rule).
- Any function that will later be replaced by a server call (time, weather, currency, rewards) should get a short `# SERVER-AUTHORITATIVE (future Nakama call)` marker comment so it's easy to grep for later.
