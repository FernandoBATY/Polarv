---
name: godot-localization-i18n
description: Localization and internationalization rules for POLAR V's in-game text content (UI strings, dialogue, item names, quest text) using Godot's CSV/PO translation system. Use whenever the user adds player-facing text, works on translation files, sets up locales, or asks about supporting multiple languages (English, Portuguese, etc.) for this Godot mobile game. This is about the GAME'S content language, not the language Claude uses to talk to the user — see polar-v-spanish-language for that.
---

# POLAR V — Localización / i18n

## Alcance de esta skill
Esto es sobre el **idioma dentro del juego** (lo que ve el jugador: botones, diálogos de NPCs, nombres de objetos, descripciones de misiones). No confundir con `polar-v-spanish-language`, que rige el idioma en que *hablamos entre tú y Claude* sobre el proyecto — son cosas independientes; el juego puede terminar soportando inglés/portugués aunque nuestras conversaciones sigan en español.

## Estado
No implementado todavía. El diseño actual (según el doc) no menciona multi-idioma como requisito del MVP — trátalo como preparación anticipada, útil sobre todo para **no tener que refactorizar texto hardcodeado después**.

## Regla de oro: separar texto de código desde ya
Aunque el MVP se lance solo en español, **nunca hardcodear strings visibles al jugador directamente en `.gd` o en nodos de escena** (`Label.text = "Colocar"` es un error desde el día uno). En vez de eso:
- Usar claves de traducción: `Label.text = tr("ACTION_PLACE")`.
- Godot resuelve `tr()` automáticamente contra el sistema de traducción activo, sin costo extra si solo hay un idioma cargado.
- Esto aplica también a: nombres de objetos en `FurnitureDatabase.gd`, texto de misiones (`godot-npc-system`), nombres de rarezas (`godot-rarity-inventory`), mensajes de UI de economía (`godot-economy-system`).

## Formato de archivos de traducción
Godot soporta dos formatos principales; para este proyecto:
- **CSV** — más simple de editar en hoja de cálculo (Google Sheets/Excel), buena opción si traduces internamente o con un traductor no-técnico. Estructura: una columna `keys`, una columna por idioma (`es`, `en`, `pt`).
- **PO (gettext)** — mejor si en algún momento usas un servicio de traducción profesional o herramientas tipo Crowdin/Weblate, que hablan PO nativamente.
- Recomendación para POLAR V: empezar con **CSV** (equipo pequeño, contenido moderado) y migrar a PO solo si el volumen de texto o el flujo de traducción externa lo justifica.

## Estructura sugerida
```
res://
└── localization/
    ├── polar_v_strings.csv     — o .po por idioma si se usa gettext
    └── keys_reference.md       — lista de claves y dónde se usan (opcional, útil para traductores)
```
Importar el CSV/PO en Project Settings → Localization → Translations para que Godot lo cargue automáticamente.

## Convención de claves
- `PREFIJO_DESCRIPCION` en mayúsculas, agrupado por sistema: `UI_INVENTORY_TITLE`, `NPC_DIALOGUE_INTRO_01`, `ITEM_CHAIR_2X2_NAME`, `RARITY_LEGENDARY`, `SHOP_BUY_CONFIRM`.
- Prefijos por sistema facilitan encontrar/filtrar claves relacionadas con `godot-decoration-system`, `godot-npc-system`, `godot-economy-system`, etc. sin depender de comentarios.

## Datos que ya son "data-driven" (fáciles de traducir)
Como `FurnitureDatabase.gd`, `Quest.gd` y las tablas de rareza ya se modelan como `Resource` (`.tres`) según `godot-gdscript-conventions`, cada entrada debería guardar una **clave de traducción**, no el texto final, en su campo de nombre/descripción — así el mismo dato sirve para todos los idiomas sin duplicar tablas.

## Consideraciones específicas del proyecto
- **Formato numérico/fecha**: si se muestra tiempo restante de eventos o clima (`godot-time-weather-system`), usar formato relativo ("en 2 horas") con `tr()` en vez de concatenar strings crudas — la gramática varía entre idiomas (plural, orden de palabras).
- **Expansión de texto en UI**: el inglés suele ser ~15-20% más corto que el español, y el portugués similar al español; diseñar botones/etiquetas (`godot-ui-mobile-design`) con margen para texto más largo, no ajustados al pixel al string en español.
- **Nombres de assets no se traducen**: los IDs internos (`chair_2x2`, `table_4x4`) permanecen en inglés siempre — son claves técnicas, no texto de jugador (mismo principio que en `godot-gdscript-conventions`).

## Selector de idioma
Cuando se implemente, exponer el cambio de idioma en un menú de ajustes simple (reutilizando `WindowBase`, ver `godot-ui-mobile-design`), guardando la preferencia localmente (dato de tipo "cache", no server-authoritative — ver `godot-save-persistence`) ya que es una preferencia de dispositivo/jugador sin impacto en la economía o el progreso.
