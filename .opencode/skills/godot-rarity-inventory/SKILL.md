---
name: godot-rarity-inventory
description: Design and implementation rules for POLAR V's rarity tiers (Common through Premium) and the limited/expandable inventory system. Use whenever the user works on item rarity, drop/gachapon odds weighting, inventory capacity/expansion, or FurnitureDatabase.gd fields related to rarity for this Godot cozy mobile game.
---

# POLAR V — Rarity & Inventory

## Rarity tiers (fixed list — don't invent new tiers without confirming with the user)
`Common → Rare → Epic → Legendary → Seasonal → Event → Premium`

- **Common/Rare/Epic/Legendary** — standard power-free cosmetic/decorative rarity ladder, likely tied to gachapon odds and shop pricing (see `godot-economy-system`).
- **Seasonal** — tied to a limited-time event or season; should carry a flag/date range so it can be hidden or specially marked once the season ends.
- **Event** — earned only through a specific event's activities, not purchasable normally.
- **Premium** — bought with premium currency, not necessarily "more powerful," just harder-to-get cosmetically (see the no-pay-to-win rule in `godot-economy-system` — rarity is a cosmetic/collection axis only).

## Data model
Add `rarity` as a field on furniture/item definitions in `FurnitureDatabase.gd` (a `Resource`-based table per `godot-gdscript-conventions`), e.g.:
```gdscript
enum Rarity { COMMON, RARE, EPIC, LEGENDARY, SEASONAL, EVENT, PREMIUM }
@export var rarity: Rarity = Rarity.COMMON
```
Keep rarity as metadata on the item definition — it should **not** appear in the per-placed-instance save record (`{ "id", "x", "y", "rotation" }` per `godot-save-persistence`), since rarity is a property of the item type (`id`), not the placement instance. Look it up from `FurnitureDatabase.gd` by `id` when needed for display.

## Inventory capacity
- Inventory is **limited but expandable** — track a capacity value (likely a server-authoritative stat once Nakama exists, same bucket as currency per `godot-save-persistence`) and an expansion mechanism (soft/premium currency purchase, or quest reward — ties into `godot-npc-system`).
- UI: `InventoryUI`/`FurnitureSlot` (see `godot-ui-mobile-design`) should visually communicate rarity (border color/frame per tier) consistently across inventory, shop, and gachapon-result screens — define the rarity → color mapping once (e.g. in the shared `Theme`) rather than per-screen.

## Gachapon weighting
When implementing gachapon (see `godot-economy-system`), weight pull tables by rarity tier with clearly documented probabilities per tier, and keep higher tiers (Legendary, Event) rarer by design — this is standard practice and also what most stores' fairness/disclosure requirements expect.
