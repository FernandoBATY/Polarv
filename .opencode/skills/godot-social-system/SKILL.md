---
name: godot-social-system
description: Design and implementation rules for POLAR V's Fase 3 social features — friends, following, online/offline visits, friends-only chat, gifts, and direct trade, explicitly excluding any public marketplace. Use whenever the user designs or codes friends lists, visiting other players' villages, chat, gifting, or trading for this Godot mobile game, even before this system exists (anticipatory design).
---

# POLAR V — Social System (Fase 3)

## Status
Not yet built, and depends on `godot-nakama-integration` being in place for anything realtime (visits, chat, live trade). Confirm scope before assuming it exists.

## Feature scope (fixed — matches the tech doc)
- Friends list, follow players, mark favorites.
- Visit other villages **online or offline**:
  - Offline visit = exploration only, no interaction with the owner or other visitors.
  - Online visit = other players visible, interaction possible (see `godot-nakama-integration`'s realtime section, capped at 5 players/village).
- Chat — **friends only**, not global/public chat.
- Gifts.
- Direct trade (player-to-player).
- **Explicitly excluded: no public marketplace.** Don't design or suggest an open buy/sell marketplace between arbitrary players — trade is direct (friend-to-friend or in-visit), not a listing/auction system.

## Why this matters for other systems
- Because there's no public marketplace, item value/pricing only needs to be balanced against the shop/gachapon economy (`godot-economy-system`), not against a player-driven market — simpler economy tuning, but also means trade shouldn't accidentally become a marketplace substitute (e.g. don't build public trade-offer boards).

## Suggested structure
```
scripts/social/
  ├── FriendsManager.gd   — friends list, requests, favorites (synced via Nakama storage/RPCs)
  ├── VisitManager.gd     — enter/exit another player's village, offline vs online mode
  ├── ChatManager.gd      — friends-only messaging, likely a Nakama realtime channel scoped to a friend pair
  ├── GiftManager.gd      — send/receive gifts, delivered via server RPC + inventory grant
  └── TradeManager.gd     — direct trade session between two online players
```

## Trust boundary
Every social action that changes state (accepting a trade, receiving a gift, joining a village) must be validated server-side once Nakama is live — a client cannot be trusted to report "trade accepted" or "gift sent" as the source of truth (same server-authoritative principle as `godot-save-persistence` and `godot-nakama-integration`). Design trade/gift flows as an atomic server-side transaction (both sides' inventories update together or not at all) to avoid item duplication or loss bugs, which are especially damaging in a collection-focused cozy game.

## UI
- Visiting, chat, and trade screens should reuse the `WindowBase` pattern and touch-friendly layout established in `godot-ui-mobile-design`, not introduce a new UI paradigm just for social features.
