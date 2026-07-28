---
name: godot-time-weather-system
description: Design and implementation rules for POLAR V's Fase 4 server-controlled time and weather system — server-authoritative clock, dynamic weather (rain/sun/storm/nieve) synced across clients, and their effects on events/shop/rewards. Use whenever the user designs or codes in-game time, day/night cycles, or weather for this Godot mobile game, even before this system exists (anticipatory design).
---

# POLAR V — Time & Weather System (Fase 4)

## Status
Not yet built, and depends on `godot-nakama-integration` for true server authority. Confirm scope before assuming it exists.

## Non-negotiable rule
**Time is controlled by the server, never by the client.** This is explicit in the project doc and it's the single most important rule in this system — do not implement a client-side `Time.get_ticks_msec()`-driven day cycle as anything other than a *visual interpolation* between server-provided timestamps.

## What time/weather affects
- Event scheduling (start/end of limited-time events).
- Daily shop rotation (see `godot-economy-system`).
- Rewards (e.g. daily login, time-gated quest rewards).

Because these all have real economic/progression value, letting the client control time would let players manipulate their device clock to exploit shop refreshes or reward timers — this is exactly the kind of value that must live in the server-authoritative bucket per `godot-save-persistence`.

## Suggested client architecture
```
scripts/world/
  └── TimeWeatherSync.gd
```
- On connect (or periodically), fetch the authoritative server time + current weather state via Nakama RPC/storage.
- Locally, interpolate/animate smoothly between synced states (e.g. gradually shift lighting tint for day/night, fade in rain particles) rather than snapping, but always re-anchor to the next server sync rather than free-running indefinitely — cap how long the client will extrapolate without a fresh sync (e.g. resync at least every few minutes) to bound drift.
- Never derive shop refresh, event start/end, or reward eligibility from the local interpolated clock directly — always check against the last-synced server value or, once available, a server RPC that answers "is it a new day yet" authoritatively.

## Weather types
`lluvia (rain), sol (sun), tormenta (storm), nieve (snow)` — dynamic, synced by server. Weather is presentation-first (particle effects, tinting, ambient sound) for this cozy game; avoid adding gameplay-blocking effects (e.g. don't let storms disable interaction) unless the user specifically designs that in, since it risks contradicting the game's cozy, low-friction tone.

## Performance note
Weather particle effects should follow the mobile performance guidance in `godot-mobile-performance` — no dynamic lighting, keep particle counts modest, and disable/reduce weather VFX when the player is in `DECORATION_MODE` or a UI-heavy screen to keep frame time predictable during precise placement interactions.
