---
name: godot-world-grid-tilemap
description: Rules and patterns for POLAR V's isometric grid, coordinate conversion, TileMapLayer terrain, and Y-sorted depth (z_index). Use whenever the user works on IsoGrid.gd, grid_to_world/world_to_grid conversions, tile placement, terrain layers (GroundLayer/BlockLayer/NavigationLayer), decoratable tile metadata, isometric math, or z_index/depth sorting bugs (objects rendering in front/behind incorrectly) in a Godot isometric game.
---

# POLAR V — World Grid & TileMapLayer System

## Grid fundamentals
- All logical positions use `Vector2i(x, y)` grid coordinates, never raw pixel/world positions for game logic.
- Conversion lives in `IsoGrid.gd` via two functions only: `grid_to_world()` and `world_to_grid()`. Any new code that needs to convert coordinates should call these, never re-derive the math inline.
- Tile size: 128x64 (isometric diamond). Sprite canvas: 256x256.

## TileMapLayer (mandatory)
- Use **`TileMapLayer`** nodes exclusively. `TileMap` is obsolete in this project — flag it if you see it suggested or present in code.
- World layer structure:
  ```
  World
  ├── GroundLayer (TileMapLayer)      — visual terrain
  ├── BlockLayer (TileMapLayer)       — collision/blocking logic
  ├── NavigationLayer (TileMapLayer)  — optional, feeds navigation baking
  └── FurnitureRoot (Node2D)          — furniture are independent nodes, NOT tiles
  ```
- Rule of thumb: **TileMapLayer is for terrain/ground logic only.** Furniture, decoration, and anything interactive is a separate `Node2D`/scene under `FurnitureRoot`, never painted into a TileMapLayer.

## Decoratable tiles
- Whether a tile can hold decoration is controlled by tile metadata: `decoratable = true/false`. Read this metadata before allowing placement in the decoration system; don't hardcode zone-based rules for this.

## Depth sorting (critical, frequent bug source)
- Every world object sets: `z_index = int(global_position.y)`.
- If something renders in the wrong order (in front of/behind a wall, furniture clipping through the player), the first thing to check is whether `z_index` is being set from `global_position.y` every frame it moves, and whether it's being computed from the *global* position, not local.

## Zones
- Town, Forest, Beach, Lake, Mountain, Market — visually one continuous village, but internally logical chunks/zones.
- A player can walk through every zone, but can only **decorate** zones they've unlocked. Enforce this at the decoration-permission check, not by hiding/disabling the zone itself.

## When editing this system
- Keep changes additive — the grid/tilemap system is marked as fully working in the project. Confirm with the user before restructuring layer names or the grid_to_world/world_to_grid contract, since other systems (navigation, decoration, save) depend on it.
