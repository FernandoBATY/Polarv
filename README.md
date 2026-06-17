\# 🏔️ POLAR V (Nombre Temporal)



¡Bienvenido al repositorio central de \*\*POLAR V\*\*! Un juego móvil cozy/social en 2D isométrico enfocado en la decoración, la colección y la interacción comunitaria. Cada jugador gestiona su propia aldea persistente, la cual puede personalizar y expandir mientras recibe visitas de otros jugadores tanto en modo online como offline.



\---



\## 📌 1. Visión General \& Core Gameplay

\* \*\*Estilo de Juego:\*\* Cozy / Social RPG móvil.

\* \*\*Perspectiva:\*\* 2D Isométrico ilustrado (colores cálidos, sombras pintadas, \*\*sin\*\* luces dinámicas).

\* \*\*Mundo:\*\* Una aldea continua por jugador dividida técnicamente en zonas (\*chunks\* lógicos): \*Town, Forest, Beach, Lake, Mountain, Market\*.

\* \*\*Casas:\*\* Fachada visual en el mapa principal; interiores expandibles en escenas separadas (`HouseInterior.tscn`).

\* \*\*Gameplay Activo:\*\* Decoración en grilla, pesca, minijuegos, tienda diaria, gachapon y eventos estacionales/premium.


# 🏔️ POLAR V (Nombre Temporal)

Bienvenido al repositorio de **POLAR V**, un prototipo de juego móvil cozy/social en 2D isométrico centrado en la decoración y la interacción entre jugadores.

---

## 📌 Visión general

- **Género:** Cozy / Social RPG para móvil.
- **Perspectiva:** 2D isométrico (arte pintado, sin luces dinámicas).
- **Enfoque:** Gestión y personalización de una aldea por jugador, decoración en grilla y visitas sociales.

## 🧭 Estado actual del prototipo

- Implementado: sistema de inventario, selección e instanciado de muebles en modo decoración, grilla isométrica y guardado local básico.
- En progreso: sincronización/servicio online, economía/tienda y minijuegos.

---

## 🛠️ Stack y requisitos

- **Motor:** Godot Engine 4.3+
- **Backend (plan):** Nakama (Heroic Labs)
- **Base de datos (plan):** PostgreSQL

Requisitos locales:

1. Instalar Godot 4.3 o superior.
2. Abrir `project.godot` desde el editor.
3. Ejecutar la escena principal: `scenes/world/game.tscn` (seleccionarla como escena principal en el editor si es necesario).

---

## 📐 Especificaciones técnicas clave

- La colocación de muebles, colisiones y navegación usa una grilla isométrica.
- Tile base sugerido: 128x64 px. Sprites de objeto: 256x256 px.
- Capas lógicas: `floor`, `furniture`, `surface`, `wall`, `ceiling`.

### Regla sobre TileMap (Godot 4.3+)

No usar el nodo `TileMap` tradicional; emplear `TileMapLayer` y la estructura de nodos del mundo:

```text
World (Node2D)
├── GroundLayer (TileMapLayer)
├── BlockLayer (TileMapLayer)
├── NavigationLayer (TileMapLayer) [opcional]
└── FurnitureRoot (Node2D)
```

---

## Estructura del repositorio (resumen)

- `project.godot` — archivo del proyecto Godot.
- `scenes/` — escenas del juego (`world/`, `player/`, `furniture/`, etc.).
- `scripts/` — GDScript (sistemas: inventario, muebles, UI, mundo).
- `assets/` — recursos importados (sprites, tiles, audio).

## Cómo contribuir

- Abrir un issue para discutir cambios grandes.
- Hacer forks/branches y enviar PRs pequeñas y enfocadas.
- Usamos GDScript; respeta la convención de nodos y la estructura de escenas existente.

---

Si quieres, puedo añadir una sección de comandos para ejecutar pruebas locales o un checklist de tareas abiertas. Indícame qué prefieres actualizar a continuación.

