---
name: godot-nakama-integration
description: Design and implementation rules for POLAR V's Fase 3 backend integration — Nakama server, PostgreSQL storage, auth, sockets for online visits, and migrating client-authoritative logic to server-authoritative. Use whenever the user sets up or codes against Nakama (godot-nakama client plugin, RPCs, storage objects, matchmaking, real-time sockets) for this Godot mobile game, even before the backend exists (anticipatory design).
---

# POLAR V — Nakama Backend Integration (Fase 3)

## Status
Not yet built. This is the biggest architectural jump in the roadmap — treat it as a distinct project phase, not something to bolt on incrementally without planning. Confirm scope with the user before assuming any backend code exists.

## Stack
- Server: **Nakama**.
- Database: **PostgreSQL** (Nakama's default storage backend).
- Client: Godot's official Nakama client plugin (asset library / addon), not a hand-rolled HTTP client, for auth/session/socket handling.

## Core principle carried over from local save design
Everything flagged as "server-authoritative" in `godot-save-persistence` (inventory, currency, decorations, progress, events, weather, elapsed time) becomes literally server-owned once Nakama is live:
- Client sends **intents** (RPCs: "place_decoration", "buy_item", "start_quest"), not final state.
- Server validates the intent (enough currency? valid cell? zone unlocked?) and returns the authoritative new state.
- Client updates its local cache/UI from the server's response, not from its own optimistic guess alone (optimistic UI updates are fine for responsiveness, but must reconcile with the server response, not overwrite it).

## Mapping existing local save format to Nakama storage
- The local JSON envelope (`{ player_id, world: { decorations: [...] } }`, see `godot-save-persistence`) was deliberately kept flat/serializable so it can become the value of a Nakama **storage object** (collection e.g. `"village"`, key = `player_id`) with minimal transformation.
- Keep using plain JSON-serializable types (no Godot-native types) in anything that will cross this boundary.

## Real-time / sockets (for online visits)
- Village visits (max 5 players per village, per `polar-v-project-context`) should use Nakama's realtime socket/match API, not polling REST calls, to get live presence and position updates.
- Server should enforce the 5-player cap itself — don't rely on the client to self-limit (also called out in `godot-mobile-performance`).
- Design for graceful degradation: if the socket drops, the client should fall back to "offline visit" mode (exploration only, per the doc's Modo Offline/Online distinction) rather than freezing or erroring.

## Auth
- Use Nakama's built-in auth flows (device ID, email, or social login) rather than building custom auth — this is standard Nakama practice and reduces security surface for a small team.

## Suggested integration order (mirrors the doc's Fase 3 breakdown)
1. Auth + basic session (player can log in, server recognizes returning device).
2. Storage sync: migrate `SaveManager.gd` (see `godot-architecture-refactor`) to read/write via Nakama storage instead of/alongside local file, with local file as offline cache.
3. Realtime visits: join/leave a village "match", see other players, basic interaction.
4. Social features layer on top (see `godot-social-system`) once presence/visits work.
