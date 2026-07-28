---
name: godot-economy-system
description: Design and implementation rules for POLAR V's Fase 2 economy — soft currency, premium currency, daily shop, gachapon, and time accelerators, with a strict no-pay-to-win constraint. Use whenever the user designs or codes currency systems, shops, gachapon/loot mechanics, pricing, or monetization for this Godot cozy mobile game, even before the Nakama backend exists (anticipatory design).
---

# POLAR V — Economy System (Fase 2)

## Status
Not yet built. This skill is for **anticipatory design** — use it to keep new work consistent with the constraints below, but confirm with the user before assuming any specific economy code already exists in the project.

## Currency types
- **Soft currency** — earned through normal play (decoration, minigames, dailies). Used for most furniture/objects.
- **Premium currency** — purchased with real money (and possibly earned in small amounts via events). Used for cosmetics, premium objects, and time accelerators.

## The one non-negotiable rule: no pay-to-win
- Premium currency must never buy a *gameplay* advantage (faster progression through required content, exclusive functional stats, competitive edge). It buys **cosmetics, premium decorative objects, and convenience (time accelerators)** only.
- When designing any new sellable item, classify it first: is this decorative/cosmetic, or does it change what the player *can do* mechanically? If the latter, flag it as a pay-to-win risk before implementing.
- Time accelerators (e.g. skip a crafting/growth timer) are acceptable because POLAR V has no PvP or competitive ranking mentioned in the design — they only affect the individual player's own pacing, not an advantage over others.

## Daily shop
- Rotates on a schedule controlled by **server time**, not client time (see `godot-time-weather-system` and the server-authoritative rule in `godot-save-persistence`) — a client clock change must not be able to refresh the shop early or replay it.
- Stock should reference `FurnitureDatabase.gd` entries by `id`, the same way placed decorations do, so a purchased item flows into the existing inventory → placement pipeline without a parallel data model.

## Gachapon
- Randomized reward pull using soft or premium currency. Implement odds as explicit, server-verifiable tables (rarity-weighted — see `godot-rarity-inventory`) rather than ad-hoc client-side random rolls once the backend exists, so results can't be manipulated client-side.
- Show rates transparently in UI (standard mobile-game best practice and increasingly a legal requirement in several regions) — don't hide gachapon odds.

## Where this plugs into existing systems
- Purchased/won items land in the **inventory** (`InventoryUI`/`FurnitureSlot`) exactly like items obtained any other way — don't create a separate "shop inventory."
- Currency balances are a prime example of "server is the source of truth" data (per `godot-save-persistence`) — design the client to display a cached balance and always reconcile against the server once Nakama is in place, never let the client increment currency locally as the final value.
