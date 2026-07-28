---
name: polar-v-project-context
description: Master context and non-negotiable rules for the POLAR V project — a cozy social 2D isometric mobile game (Android + iOS) built in Godot 4.6.1 with a future Nakama + PostgreSQL backend. Use this skill for ANY question, code, design, or architecture decision related to POLAR V, even if the user doesn't say "POLAR V" explicitly — trigger on mentions of Godot, isometric village game, decoration game, TileMapLayer, cozy game, Tsuki Odyssey / Animal Crossing style project, or any file/script that looks like it belongs to this project (Game.gd, IsoGrid.gd, FurnitureItem, DecorationController, etc). Always consult this skill FIRST before other POLAR V skills to load the project's vision, tech stack, and hard constraints, then pull in the more specific skill (world/grid, decoration, navigation, save, mobile performance, architecture) for the actual task.
---

# POLAR V — Master Project Context

Use this skill as the entry point for anything touching POLAR V. It contains the rules that must never be silently violated. After reading this, jump to the specific skill that matches the task:

- Grid, tiles, isometric depth → `godot-world-grid-tilemap`
- Placing/rotating/saving furniture → `godot-decoration-system`
- Movement, pathfinding, obstacles → `godot-navigation-pathfinding`
- Save files, autosave, server authority → `godot-save-persistence`
- Frame rate, battery, memory, Android/iOS export → `godot-mobile-performance`
- Splitting up Game.gd, adding new managers → `godot-architecture-refactor`

## Golden rule
This account/project is dedicated exclusively to POLAR V. Never change the established architecture without a clear technical justification — always ask before proposing an architecture change, don't just do it.

## Vision
- Genre: Cozy Social, 2D isometric, **Mobile First** (Android + iOS).
- References: Tsuki Odyssey, Animal Crossing: Pocket Camp.
- Each player owns one persistent village. Other players can visit (online or offline), explore, and observe decoration — there is **no shared persistent open world** and **no public marketplace**.

## Tech stack (do not suggest alternatives without being asked)
- Engine: **Godot 4.6.1 Stable**.
- Backend (future): **Nakama** + **PostgreSQL**.
- Architecture principle: **server is the source of truth, the client is never trusted.** Any gameplay-affecting value (currency, inventory, decorations, progress, time, weather) must be validated/owned server-side once the backend exists; local client state is only a cache/prediction layer.

## Visual style
- 2D illustrated isometric — **not pixel art**.
- Sprites: 256x256. Tiles: 128x64.
- Warm colors, painted shadows, no dynamic lighting, smooth animations.

## Priorities when giving any recommendation
Always optimize for, in this order: Escalabilidad (scalability) → Mobile First → Server Authoritative → Decoración avanzada → Online ligero. If a suggestion trades one of these off, say so explicitly.

## Current project structure (keep suggestions consistent with this layout)
```
res://
├── assets/ (furniture/, ui/)
├── scenes/ (world/Game.tscn, player/Player.tscn, furniture/FurnitureItem.tscn, ui/*.tscn)
├── scripts/
│   ├── world/Game.gd
│   ├── player/player.gd
│   ├── furniture/FurnitureItem.gd
│   ├── ui/ (InventoryUI.gd, FurnitureSlot.gd, UIRoot.gd, WindowBase.gd)
│   ├── FurnitureDatabase.gd
│   └── IsoGrid.gd
└── user://decorations_save.json
```

## Status: what already works (don't rebuild these — extend them)
Isometric grid, TileMapLayer terrain, multi-tile decoration, 4-direction rotation, save/load, autosave, layers (floor/furniture/surface/wall/ceiling), surface system, selection, move, delete, NavigationAgent2D with dynamic obstacles + auto rebake, basic inventory with ghost-click protection.

## Current phase / priority
The project just finished the core decoration + navigation loop. The active priority is **refactoring `Game.gd` (700+ lines) into specialized manager scripts** without changing behavior — see `godot-architecture-refactor`. Only after that is done should new UI or new gameplay systems (economy, NPCs, online) be built. If the user asks for a new feature, gently flag if it should wait until the refactor lands, but still help if they insist.

## Full roadmap (for context on where a task fits)
1. **Fase 1** (in progress): movement, TileMapLayer, grid, basic decoration.
2. **Fase 2**: inventory, NPCs, economy.
3. **Fase 3**: online, visits, chat, trade.
4. **Fase 4**: events, weather, expansion content.

## Hard "never do this" list
- Never use `TileMap` (obsolete) — always `TileMapLayer`.
- Never use `AStarGrid2D` for navigation — always `NavigationRegion2D` + `NavigationAgent2D`.
- Never use `rotation_degrees` for furniture — use the 4 logical directions (0/90/180/270) with front/back sprites + `flip_h`.
- Never design pay-to-win economy — premium currency buys cosmetics/objects/time accelerators only.
- Never trust the client as the source of truth once server code is involved.
