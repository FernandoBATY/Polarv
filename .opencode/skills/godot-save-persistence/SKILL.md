---
name: godot-save-persistence
description: Rules for POLAR V's save/load and server-authoritative data architecture — local autosave to decorations_save.json today, and the future Nakama + PostgreSQL server-authoritative model. Use whenever the user works on saving/loading game state, autosave, decorations_save.json, what data belongs on client vs server, currency/inventory/progress persistence, or designing any data format that will eventually sync with a Nakama backend in this Godot game.
---

# POLAR V — Save & Persistence

## Current implementation (local, works)
- File: `user://decorations_save.json`.
- **Autosave only** — there is no manual save key anymore ("S to save" was removed). Autosave fires automatically on: place, move, delete of a decoration.
- Any new mutation to world state (new object types, new interactions) should hook into the same autosave trigger points rather than adding a separate save path.

## Data format
```json
{
  "player_id": "123",
  "world": {
    "decorations": [
      { "id": "chair_01", "x": 10, "y": 5, "rotation": 90 }
    ]
  }
}
```
Keep new persisted fields inside this `world` envelope (e.g. future `npcs`, `zones_unlocked`) rather than inventing parallel top-level save files, so a single player blob maps cleanly to a future Nakama storage object.

## What is "local cache" vs "server truth" (design for this split now, even pre-backend)
- **Local only / never trusted:** settings, temporary UI state, in-progress previews.
- **Server is the source of truth (once backend exists):** inventory, currency, decorations, progress, active events, weather, elapsed game time.
- When designing any new persisted field, ask: "if a modified client sent a fake value for this, would it matter?" If yes, it belongs in the server-authoritative bucket, and the client-side save should be treated as a prediction/cache that the server can overwrite, not a write-once source of truth.

## Preparing for Nakama + PostgreSQL migration
- Keep the JSON shape flat and serializable as-is — it should be usable directly as a Nakama storage object value with minimal transformation.
- Avoid embedding Godot-specific types (Vector2, Color, etc.) directly in save data; use plain ints/strings/arrays (as the current format already does) so the same schema works server-side.
- Time and weather (see project roadmap) must eventually be **server-controlled, not client-controlled** — don't build client-authoritative timers for anything that affects shop rotation, events, or rewards, even as a placeholder; stub it behind a function that can later be swapped for a server call.
