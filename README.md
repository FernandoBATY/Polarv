\# 🏔️ POLAR V (Nombre Temporal)



¡Bienvenido al repositorio central de \*\*POLAR V\*\*! Un juego móvil cozy/social en 2D isométrico enfocado en la decoración, la colección y la interacción comunitaria. Cada jugador gestiona su propia aldea persistente, la cual puede personalizar y expandir mientras recibe visitas de otros jugadores tanto en modo online como offline.



\---



\## 📌 1. Visión General \& Core Gameplay

\* \*\*Estilo de Juego:\*\* Cozy / Social RPG móvil.

\* \*\*Perspectiva:\*\* 2D Isométrico ilustrado (colores cálidos, sombras pintadas, \*\*sin\*\* luces dinámicas).

\* \*\*Mundo:\*\* Una aldea continua por jugador dividida técnicamente en zonas (\*chunks\* lógicos): \*Town, Forest, Beach, Lake, Mountain, Market\*.

\* \*\*Casas:\*\* Fachada visual en el mapa principal; interiores expandibles en escenas separadas (`HouseInterior.tscn`).

\* \*\*Gameplay Activo:\*\* Decoración en grilla, pesca, minijuegos, tienda diaria, gachapon y eventos estacionales/premium.



\---



\## 🛠️ 2. Stack Tecnológico



| Componente | Tecnología | Notas / Versión |

| :--- | :--- | :--- |

| \*\*Motor de Juego\*\* | Godot Engine | Versión 4.3+ |

| \*\*Backend / Servidor\*\* | Heroic Labs Nakama | Gestión social, tiempo y guardado |

| \*\*Base de Datos\*\* | PostgreSQL | Persistencia de datos del servidor |

| \*\*Pathfinding\*\* | NavigationAgent2D | Movimiento basado en \*Touch-to-move\* |



\---



\## 📐 3. Especificaciones Técnicas Clave



\### Sistema de Grilla y Construcción

Todo el posicionamiento de muebles, colisiones y navegación se rige por una grilla isométrica.

\* \*\*Tamaño del Tile base:\*\* 128x64 px.

\* \*\*Sprites de Objetos:\*\* Base de 256x256 px.

\* \*\*Capas Lógicas de Decoración:\*\* `floor`, `furniture`, `surface`, `wall`, `ceiling`.

\* \*\*Superficies:\*\* Los muebles con metadata específica (`decoratable = true`) permiten colocar otros objetos encima (ej. mesas).



\### ❌ Regla Crítica del TileMap (Godot 4.3+)

\*\*No usar el nodo `TileMap` tradicional (obsoleto).\*\* Se implementa estrictamente \*\*`TileMapLayer`\*\* dividiendo la escena del mundo bajo la siguiente estructura de nodos:



```text

World (Node2D)

├── GroundLayer (TileMapLayer -> Solo terreno/lógica)

├── BlockLayer (TileMapLayer -> Colisiones/obstáculos)

├── NavigationLayer (TileMapLayer opcional -> Caminos)

└── FurnitureRoot (Node2D -> Los muebles se instancian como nodos independientes)

