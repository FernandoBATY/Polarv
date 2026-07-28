---
name: godot-mobile-performance
description: Mobile performance and Android/iOS export best practices for POLAR V, a Godot 4.6 mobile-first game. Use whenever the user asks about frame rate, battery drain, memory/texture usage, draw calls, shaders, touch input handling, Android/iOS export settings, app size, or "how do I make this run well on phones" for this Godot project — or generally for any Godot mobile optimization question even outside POLAR V specifics.
---

# POLAR V — Mobile Performance & Android/iOS Best Practices

## Project-specific rules (from the tech doc — don't relax these)
- No dynamic lights/shadows — the art style already uses baked/painted shadows, so this is both an art and a performance decision. Don't suggest `Light2D`/dynamic shadows to "improve" visuals.
- No heavy shaders. Prefer built-in materials/CanvasItem features over custom fragment shaders unless there's no alternative.
- No complex physics — the game doesn't need a physics simulation; collision is grid-based (see `godot-world-grid-tilemap`), not `RigidBody2D` physics.
- Use sprite atlases, not loose textures per frame.
- Use culling and per-zone loading — don't load the whole village + all zones into memory at once; stream by zone (Town/Forest/Beach/Lake/Mountain/Market).
- Use object pooling for anything spawned repeatedly (particles, UI popups, visiting-player avatars).

## General Godot 4.x mobile checklist (Android + iOS)
**Rendering**
- Use the **Mobile** rendering method (Project Settings → Rendering → Renderer), not Forward+ (desktop-oriented).
- Batch draws: keep sprites on shared `CanvasTexture`/atlas to reduce draw calls; avoid one-off unique materials per instance.
- Keep `TileMapLayer` chunk sizes reasonable so terrain isn't rebuilt/redrawn unnecessarily each frame.

**Touch input**
- Design all interactive hit targets for finger size (~44x44pt minimum), not mouse-precision clicks.
- Debounce/guard against double-registration of a single tap across UI and world layers (see `block_next_decoration_click` pattern in `godot-decoration-system`) — this is a common source of "ghost input" bugs on mobile.
- Support both tap-to-move and drag-to-pan/zoom camera gestures without them fighting each other; gate world-taps while a UI panel/modal is open.

**Memory & battery**
- Compress textures appropriately per platform (ETC2/ASTC for Android, ASTC/PVRTC family for iOS) via Godot's import presets — don't ship raw uncompressed PNGs at scale.
- Cap and throttle background timers/polling (e.g. clock/weather sync) — polling every frame drains battery; prefer event-driven updates or coarse intervals (e.g. once per minute).
- Release/unload zone content the player isn't currently in rather than keeping every zone resident.

**Android export**
- Set a sensible `minSdk`/`targetSdk` in the Android export preset and keep it updated to current Play Store requirements.
- Use AAB (Android App Bundle) for Play Store submission, not raw APK, to let Play deliver per-device assets.
- Test on a low/mid-tier device profile, not just a flagship emulator — cozy/decoration games skew toward a broad, not high-end, device audience.

**iOS export**
- Requires a Mac (or remote build service) for the final Xcode build step — plan CI/build pipeline around this if the user doesn't have local macOS access.
- Watch app size limits and asset thinning; iOS is stricter about over-the-air download size than Android.
- Respect iOS safe-area insets for UI (notch/home-indicator) since this is a UI-heavy cozy game (inventory, decoration menus).

**Networking (for the future Nakama backend)**
- Keep payloads small and batched — mobile networks are less reliable than desktop; design the client to tolerate latency/dropouts gracefully (queue actions locally, reconcile on reconnect) rather than assuming an always-on socket.
- Cap "online visit" capacity server-side too, not just client-side (doc specifies max 5 players per village) — don't rely on the client to self-limit.
