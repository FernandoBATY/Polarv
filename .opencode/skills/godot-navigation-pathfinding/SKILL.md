---
name: godot-navigation-pathfinding
description: Rules for POLAR V's touch-to-move pathfinding and dynamic navigation obstacles built with NavigationRegion2D and NavigationAgent2D. Use whenever the user works on player movement, touch-to-move, NavigationAgent2D, NavigationRegion2D, navigation obstacles/blockers, rebaking the navigation mesh after placing/moving/deleting furniture, or pathfinding bugs (player walking through furniture, not rerouting, getting stuck) in this Godot isometric mobile game.
---

# POLAR V — Navigation & Movement

## Movement model
- Touch-to-move: player taps a destination, character paths there automatically avoiding obstacles.
- Implemented with **`NavigationAgent2D`**, driven by a **`NavigationRegion2D`**.

## Do not use AStarGrid2D
This project has explicitly decided against `AStarGrid2D` in favor of the built-in navigation mesh workflow (`NavigationRegion2D` + `NavigationAgent2D` + `NavigationAgent2D`'s dynamic obstacle avoidance). If the user or existing code suggests `AStarGrid2D`, flag that it conflicts with the established architecture before proceeding.

## Dynamic obstacles from furniture
Furniture automatically generates navigation obstacles/blockers. After **placing, moving, or deleting** a piece of furniture, the system must run, in this order:
1. `rebuild_navigation_blockers()`
2. `bake_navigation_polygon()`

This is already implemented and working — treat it as a contract other systems (decoration, save/load on world entry) must call, not something to reimplement per-feature. When adding a new way to modify the world (e.g. loading a saved layout, an admin/debug tool), make sure it also triggers this rebake pair after changes are applied, or the player will be able to walk through newly-placed objects.

## Debugging checklist
If the player doesn't route around an obstacle, or gets stuck:
1. Confirm the obstacle/blocker was actually created for that furniture's real footprint (see `godot-decoration-system` for footprint sizes), not just its origin cell.
2. Confirm `rebuild_navigation_blockers()` then `bake_navigation_polygon()` ran *after* the world state changed, not before.
3. Confirm baking happens on load too (visiting a saved village must rebake before the player can move), not only on live edits during the current session.
4. Check the `NavigationLayer` TileMapLayer (optional layer feeding the region) is in sync with `GroundLayer`/`BlockLayer` if it's being used.
