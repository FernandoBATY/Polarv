---
name: godot-accessibility-mobile
description: Accessibility rules for POLAR V's mobile UI and gameplay feedback — text sizing, color contrast, and colorblind support for rarity color-coding and the decoration placement preview (green/red). Use whenever the user works on UI text, color-coded feedback (placement preview, rarity borders, status indicators), or asks about accessibility, readability, or colorblind users for this Godot mobile game. The green/red decoration preview is a current, real system — treat this as relevant now, not just future polish.
---

# POLAR V — Accesibilidad Móvil

## Por qué esto es urgente, no "futuro"
El sistema de preview verde/rojo en modo decoración (`godot-decoration-system`) ya existe y depende **solo del color** para comunicar "colocación válida" vs "inválida". Esto es ilegible para jugadores con deuteranopía/protanopía (los tipos más comunes de daltonismo, ~8% de hombres). No es un nice-to-have para una fase futura — es un bug de accesibilidad en un sistema core ya construido.

## Regla general: nunca color como único indicador
Para cualquier feedback codificado por color (preview de colocación, rareza, estados de salud/energía si existieran, indicadores de éxito/error), acompañar el color con al menos **una señal adicional**:
- Forma/ícono (✓ para válido, ✕ para inválido, superpuesto en el preview de colocación).
- Patrón (bordes sólidos vs punteados).
- Texto corto cuando el espacio lo permita.

### Aplicación concreta al preview de decoración
- Mantener verde/rojo como refuerzo visual (es intuitivo y consistente con convenciones ya aprendidas), pero agregar un ícono simple sobre el objeto fantasma: un check o un "x" pequeño, o un contorno de patrón distinto (línea sólida = válido, línea punteada = inválido) — así funciona con o sin percepción normal del color.
- Esto se implementa en el mismo shader/material del preview descrito en `godot-decoration-system`, sin tocar la lógica de validación (pasos 1-3 del checklist de esa skill) — es puramente presentación.

### Aplicación a rareza
- Los bordes de color por rareza (`godot-rarity-inventory`: Common→Legendary→Seasonal→Event→Premium) deben ir acompañados de una etiqueta de texto corta o un ícono distintivo por tier (una estrella con conteo, un patrón de esquina), no solo el color del borde — sobre todo porque hay 7 tiers, un rango donde confundir dos colores adyacentes es fácil incluso con visión de color típica.

## Contraste de texto
- Verificar contraste mínimo texto/fondo de **4.5:1** para texto normal y **3:1** para texto grande (guía WCAG AA, buen estándar por defecto aunque el juego no sea una app "de accesibilidad" formal).
- Cuidado particular con el estilo visual del proyecto (colores cálidos, sombras pintadas — ver `polar-v-project-context`): paletas cálidas/pastel tienden a bajo contraste; probar texto sobre los fondos reales del juego, no solo sobre blanco/negro de prueba.

## Tamaño de texto
- Tamaño mínimo recomendado ~14-16pt para texto de lectura en móvil (diálogos de NPC, descripciones de objetos), con jerarquía clara para títulos.
- Si el tiempo lo permite, soportar el multiplicador de tamaño de fuente del sistema operativo (accesibilidad del OS) en vez de un tamaño fijo — Godot permite escalar `Theme` global font sizes fácilmente si se centraliza como se sugiere en `godot-ui-mobile-design`.

## Objetivos táctiles
- Ya cubierto en `godot-ui-mobile-design` (mínimo ~44x44pt / 48x48dp), pero vale repetirlo aquí: el tamaño de objetivo táctil también es un tema de accesibilidad motriz, no solo de "sentirse bien" — mantenerlo como piso, no como ideal a recortar bajo presión de espacio en pantalla.

## Dónde revisar esto en el flujo de trabajo
Agregar una verificación de accesibilidad (contraste + doble-señal en indicadores de color) al checklist de QA cuando exista `godot-testing-qa`, y específicamente antes de cerrar cualquier tarea que toque el preview de decoración o el sistema de rareza — son los dos puntos de mayor riesgo real hoy en el proyecto.
