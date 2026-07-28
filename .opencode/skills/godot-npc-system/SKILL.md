---
name: godot-npc-system
description: Design and implementation rules for POLAR V's Fase 2 NPC system — story delivery, simple quests, zone-unlock gating, and lightweight NPC AI. Use whenever the user designs or codes NPCs, dialogue, quests/missions, or zone-unlocking logic for this Godot cozy mobile game, even before this system exists yet (anticipatory design).
---

# POLAR V — NPC System (Fase 2)

## Status
Not yet built. Use this for anticipatory design consistent with the project's other systems; confirm with the user before assuming existing NPC code.

## Role of NPCs
- Deliver story/flavor.
- Give simple missions/quests.
- **Gate zone unlocks** — per the world doc, zones (Forest, Beach, Lake, Mountain, Market) are unlocked progressively, and NPCs are the intended trigger for that progression (e.g. complete an NPC's quest → unlock Beach).
- AI is intentionally simple — no complex behavior trees needed. A basic state machine (idle → talk-available → quest-active → quest-complete) is enough; don't over-engineer NPC AI for a decoration-focused cozy game.

## Suggested structure
```
scenes/npc/
scripts/npc/
  ├── NPC.gd            — base NPC behavior, dialogue trigger, idle animation
  ├── Quest.gd           — a Resource (.tres) describing a quest: id, prerequisites, rewards, zone_unlock
  └── QuestManager.gd     — tracks player quest progress, persists via SaveManager
```
- Model quests as `Resource` data (like furniture definitions in `FurnitureDatabase.gd`), not hardcoded branches per NPC — keeps content additions data-driven.

## Interaction pattern
- NPC interaction is a tap (touch-first — see `godot-ui-mobile-design`), opening a dialogue window built on the existing `WindowBase` pattern rather than a bespoke dialogue box.
- Dialogue/quest UI should reuse the same modal-stacking discipline as inventory/decoration windows (only one blocking window at a time).

## Persistence & server authority
- Quest completion and zone-unlock state are gameplay progress — per `godot-save-persistence`, these belong in the server-authoritative bucket once Nakama exists. Locally, persist them inside the same save envelope (`world.quests`, `world.zones_unlocked`) rather than a separate save file.
- Zone-unlock checks (can the player decorate/enter a zone) should read from this persisted state, not be re-derived from "has the player talked to NPC X this session" — it must survive app restarts and eventually be server-verified.

## Where this plugs into existing systems
- Zone-unlock state gates the decoration permission check described in `godot-world-grid-tilemap` ("player can only decorate zones they've unlocked") — when this system is built, that check should read from `QuestManager`'s unlocked-zones list.
- Quest rewards commonly grant currency or furniture — route them through the same reward-granting path as the economy system (`godot-economy-system`) and inventory, not a separate one-off grant function.
