---
name: godot-decoration-system
description: Rules and patterns for POLAR V's furniture/decoration placement system — placing, rotating, moving, deleting furniture, decoration preview (green/red), multi-tile objects, layers (floor/furniture/surface/wall/ceiling), the surface system (objects on top of objects), and occupancy tracking. Use whenever the user works on FurnitureItem.gd, DecorationController, FurnitureDatabase.gd, InventoryUI/FurnitureSlot, occupied_cells, decoration mode, or furniture placement/rotation/collision bugs in this Godot isometric game.
---

# POLAR V — Decoration System

## Core loop
Decoration is a **separate mode** from gameplay. While `DECORATION_MODE` is active the player character cannot move. States: `GAMEPLAY`, `DECORATION_MODE`, `MENU`, `VISITING`.

Supported actions: place, rotate (4 directions), move, delete, preview (green = valid, red = invalid).

## Data shape
Each placed object is stored as:
```json
{ "id": "chair_01", "x": 12, "y": 5, "rotation": 90 }
```
Only these four fields — don't add extra runtime-only fields to the persisted record; derive anything else (footprint, layer, sprite) from `FurnitureDatabase.gd` by `id`.

## Sizes (multi-tile footprints)
- 1x1 → chair (legacy example), but current minimum furniture size is **2x2**.
- Known catalog: `chair_2x2`, `table_4x2`, `table_4x4`, `bed_6x4`, `fountain_6x6`, `fridge_2x4`, `painting_2x2`, `flower_vase_2x2`, `rug_4x4`.
- Footprint math must go through the grid conversion in `IsoGrid.gd` (see `godot-world-grid-tilemap`), not ad-hoc pixel math.

## Layers & occupancy
Five logical layers per cell: `floor`, `furniture`, `surface`, `wall`, `ceiling`. Occupancy is tracked per cell as:
```gdscript
occupied_cells[cell] = {
  "floor": null, "furniture": null, "surface": null, "wall": null, "ceiling": null
}
```
When placing an object, only check/reserve the layer(s) it actually occupies — a rug on `floor` and a chair on `furniture` can coexist on the same cell.

## Surface system (already implemented)
Objects flagged as surfaces (e.g. a table) can hold other decoration on top (e.g. a flower vase). When validating placement of a "surface item" (like a vase), check the `surface` layer of the target cell for a valid host object, not just `decoratable` tile metadata.

## Rotation (do NOT use rotation_degrees)
Rotation is one of four **logical** directions: `0`, `90`, `180`, `270`. Visual representation is achieved with a front sprite, a back sprite, and `flip_h` — never `Node2D.rotation_degrees`, since that would rotate the isometric sprite incorrectly.

## Placement validation checklist
When implementing/debugging placement logic, verify in this order:
1. Target cells are inside a zone the player has unlocked.
2. Target tiles have `decoratable = true`.
3. Every cell in the object's footprint is free on the required layer(s) (respecting the surface exception above).
4. Preview color reflects step 1–3 (green only if all pass).
5. On confirm: write to `occupied_cells`, persist via the save system (see `godot-save-persistence`), and trigger navigation rebake if the object blocks movement (see `godot-navigation-pathfinding`).

## Inventory integration
- `InventoryUI` + `FurnitureSlot` drive selection of what to place.
- `block_next_decoration_click` guards against "ghost clicks" — a click that opens the inventory shouldn't also register as a placement click on the world underneath it. Preserve this guard when touching inventory-to-world interaction.
- Numeric hotkeys (1-9, and the old "S to save" key) were intentionally removed — don't reintroduce keyboard shortcuts for a touch-first mobile game; use on-screen buttons instead.
