# POLAR V — Documento de Preferencias y Contexto Maestro

> Este documento resume todo lo definido sobre el proyecto POLAR V y el set de skills creado para que cualquier agente de IA (Claude u otro) sepa exactamente qué reglas, prioridades y sistemas debe respetar al trabajar en este proyecto.

---

## 1. Idioma de trabajo

**Todas las conversaciones sobre este proyecto deben ser en español.** Esto incluye explicaciones, planeación, comentarios dentro del código y cualquier texto de cara al usuario.

- Se mantienen en inglés (convención técnica estándar, no texto "de cara al usuario"): nombres de variables, funciones, clases, señales, nodos y archivos de escena/script (`occupied_cells`, `DecorationController`, `Game.gd`, `TileMapLayer`, etc.).
- Si se pide explícitamente responder en otro idioma para un mensaje puntual, se respeta solo para esa respuesta y se vuelve a español después.
- Español neutro/latinoamericano por defecto.
- Esto es distinto de la **localización del contenido del juego** (idioma que ve el jugador final) — ver sección de skills, `godot-localization-i18n`.

---

## 2. Visión general del juego

- **Género:** Cozy Social, 2D isométrico, **Mobile First** (Android + iOS).
- **Referencias:** Tsuki Odyssey, Animal Crossing: Pocket Camp.
- **Modelo:** cada jugador tiene una aldea propia y persistente. Otros jugadores pueden visitarla (online u offline), explorar y ver la decoración.
- **No incluye:** mundo compartido permanente, marketplace público entre jugadores.

---

## 3. Tecnología

| Componente | Elección |
|---|---|
| Motor | Godot Engine **4.6.1 Stable** |
| Backend (futuro) | **Nakama** |
| Base de datos | **PostgreSQL** |
| Arquitectura | **Servidor = fuente de verdad. Cliente nunca es confiable.** |

---

## 4. Estilo visual

- 2D ilustrado isométrico — **no pixel art**.
- Sprites: 256x256. Tiles: 128x64.
- Colores cálidos, sombras pintadas, sin luces dinámicas, animaciones suaves.

---

## 5. Prioridades al tomar cualquier decisión

En este orden, siempre:

1. Escalabilidad
2. Mobile First
3. Server Authoritative
4. Decoración avanzada
5. Online ligero

Si una sugerencia sacrifica alguna de estas, el agente debe decirlo explícitamente.

---

## 6. Estructura actual del proyecto

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

---

## 7. Reglas que nunca se deben romper

- Nunca usar `TileMap` (obsoleto) → siempre `TileMapLayer`.
- Nunca usar `AStarGrid2D` para navegación → siempre `NavigationRegion2D` + `NavigationAgent2D`.
- Nunca usar `rotation_degrees` en muebles → usar las 4 direcciones lógicas (0/90/180/270) con sprite frontal/trasero + `flip_h`.
- Nunca diseñar economía pay-to-win → la moneda premium solo compra cosméticos, objetos premium y aceleradores de tiempo.
- Nunca confiar en el cliente como fuente de verdad una vez exista el backend (moneda, inventario, decoraciones, progreso, clima, tiempo son server-authoritative).
- Nunca depender solo del color para comunicar estado (preview verde/rojo de decoración, rareza) — siempre acompañar con ícono, forma o texto por accesibilidad.
- Nunca hardcodear texto visible al jugador directamente en el código — usar `tr()` y claves de traducción desde el día uno.

---

## 8. Qué ya funciona (no reconstruir, extender)

Grid isométrico, TileMapLayer de terreno, decoración multi-tile, rotación en 4 direcciones, guardado/carga, autosave, capas (floor/furniture/surface/wall/ceiling), surface system, selección, mover, eliminar, `NavigationAgent2D` con obstáculos dinámicos y rebake automático, inventario básico con protección contra clic fantasma.

---

## 9. Prioridad actual

**Refactorizar `Game.gd` (700+ líneas)** en managers especializados sin cambiar el comportamiento, antes de agregar nuevas features:

```
scripts/world/
├── Game.gd                 — coordinador únicamente
├── DecorationController.gd
├── SaveManager.gd
├── NavigationManager.gd
├── OccupancyManager.gd
└── SelectionManager.gd
```

Regla: una extracción a la vez, sin cambios de comportamiento, preservando las firmas de funciones públicas existentes, comunicación entre managers vía señales (no referencias directas entre ellos).

---

## 10. Roadmap completo

| Fase | Contenido |
|---|---|
| **Fase 1** (en curso) | Movimiento, TileMapLayer, grid, decoración básica |
| **Fase 2** | Inventario avanzado, NPCs, economía |
| **Fase 3** | Online, visitas, chat, trade, integración Nakama |
| **Fase 4** | Eventos, clima, expansión de contenido |

---

## 11. Set de Skills del proyecto

Todas estas skills están instaladas/disponibles para que el agente las consulte automáticamente según el tema de la conversación. La primera en cargarse siempre debería ser `polar-v-project-context`, que redirige a las demás.

### Núcleo / contexto
| Skill | Cuándo se usa |
|---|---|
| `polar-v-project-context` | Punto de entrada para cualquier tema de POLAR V. Carga visión, stack, reglas duras. |
| `polar-v-spanish-language` | Fuerza que toda la conversación (no el contenido del juego) sea en español. |

### Sistemas core (Fase 1)
| Skill | Cuándo se usa |
|---|---|
| `godot-world-grid-tilemap` | Grid, `IsoGrid.gd`, TileMapLayer, z_index/profundidad, tiles decorables. |
| `godot-decoration-system` | Colocar/rotar/mover/borrar muebles, capas, surface system, occupancy. |
| `godot-navigation-pathfinding` | Touch-to-move, NavigationAgent2D, rebake de obstáculos. |
| `godot-save-persistence` | Autosave, formato JSON, qué es client-cache vs server-truth. |

### Código y UI
| Skill | Cuándo se usa |
|---|---|
| `godot-gdscript-conventions` | Naming, tipado estático, patrón de señales entre managers. |
| `godot-ui-mobile-design` | Layout táctil, `WindowBase`, responsive, la futura pasada de UI profesional. |
| `godot-architecture-refactor` | La modularización de `Game.gd` en curso. |

### Rendimiento y calidad
| Skill | Cuándo se usa |
|---|---|
| `godot-mobile-performance` | FPS, batería, memoria, shaders, export Android/iOS. |
| `godot-accessibility-mobile` | Contraste, tamaño de texto, daltonismo en preview verde/rojo y rareza. |
| `godot-localization-i18n` | Sistema de traducción del contenido del juego (CSV/PO), separar texto de código. |

### Gameplay (Fase 2, diseño anticipado)
| Skill | Cuándo se usa |
|---|---|
| `godot-economy-system` | Moneda soft/premium, tienda diaria, gachapon, regla anti pay-to-win. |
| `godot-npc-system` | Diálogos, misiones, desbloqueo de zonas, IA simple. |
| `godot-rarity-inventory` | Las 7 rarezas fijas, inventario limitado/expandible. |

### Online / backend (Fase 3, diseño anticipado)
| Skill | Cuándo se usa |
|---|---|
| `godot-nakama-integration` | Auth, storage objects, sockets, migración de save local → Nakama. |
| `godot-social-system` | Amigos, visitas, chat solo-amigos, regalos, trade directo (sin marketplace). |

### Mundo vivo (Fase 4, diseño anticipado)
| Skill | Cuándo se usa |
|---|---|
| `godot-time-weather-system` | Reloj y clima server-authoritative, efecto en tienda/eventos/recompensas. |

---

## 12. Skills pendientes (sugeridas, no creadas aún)

Quedaron identificadas pero sin construir — crear cuando el proyecto llegue a esa etapa:

- `godot-git-workflow` — convenciones de commits, branching, versionado de assets binarios.
- `godot-testing-qa` — checklist de pruebas manuales por sistema antes de cada build.
- `godot-build-release-pipeline` — export presets, firma de builds, Google Play / App Store, changelog.
- `godot-minigames` — estructura de minijuegos (ej. pesca) y su integración con la economía.
- `godot-onboarding-tutorial` — primera experiencia del jugador sin fricción.

---

## 13. Cómo debe comportarse el agente de IA en este proyecto

1. Al iniciar cualquier tarea de POLAR V, consultar `polar-v-project-context` primero.
2. Responder siempre en español (ver sección 1).
3. No proponer cambios de arquitectura sin justificación técnica clara y sin preguntar antes.
4. Antes de agregar features nuevas, verificar si compiten con la prioridad actual (refactor de `Game.gd`) y señalarlo si es el caso, aunque igual se ayude si el usuario insiste.
5. Para cualquier sistema de Fase 2-4, tratar el diseño como anticipado/propuesto, no como código ya existente, y confirmar alcance real con el usuario antes de asumir implementación previa.
6. Recordar el checklist de accesibilidad (color + ícono/forma) en cualquier feedback visual codificado por color.
7. Separar siempre texto de jugador del código (`tr()` + claves), incluso si el juego aún es monolingüe.
