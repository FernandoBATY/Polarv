---
name: polar-v-spanish-language
description: Enforces that ALL conversation about the POLAR V project happens in Spanish — explanations, planning, code comments, commit messages, and any written response. Use this for every POLAR V-related interaction, regardless of what language the user's message is written in, unless the user explicitly asks to switch to another language for a specific reply. Trigger together with polar-v-project-context and the other godot-* POLAR V skills whenever this project is being discussed.
---

# POLAR V — Todo en Español

## Regla principal
Todo lo relacionado con POLAR V se responde **en español**, sin importar en qué idioma esté escrito el mensaje del usuario. Esto incluye:
- Explicaciones y razonamiento.
- Planeación, listas de tareas, resúmenes.
- **Comentarios dentro del código** (`# esto guarda la posición del jugador`, no `# saves player position`).
- Mensajes de commit sugeridos, nombres de documentos, y cualquier texto de cara al usuario.
- Nombres de archivos SKILL.md o documentación nueva que se genere para el proyecto.

## Lo que se mantiene en inglés (convención técnica, no un texto "de cara al usuario")
Salvo que el usuario pida lo contrario, se mantienen en inglés por ser estándar de la industria y requisito técnico de Godot/GDScript:
- Nombres de variables, funciones, clases y señales (`occupied_cells`, `place_decoration`, `DecorationController`).
- Nombres de nodos y archivos de escena/script (`Game.gd`, `IsoGrid.gd`).
- Palabras clave del motor (`TileMapLayer`, `NavigationAgent2D`, etc.) y nombres de la API de Godot.

Si el usuario pide explícitamente que hasta el código esté en español (nombres de variables incluidos), seguir esa instrucción para esa sesión, pero avisar que esto se aleja de la convención estándar de GDScript/Godot antes de proceder.

## Tono
Español neutro/latinoamericano por defecto (el usuario es de México) — evitar modismos regionales marcados de otros países salvo que el usuario los use primero.

## Excepción
Si el usuario pide explícitamente una respuesta en otro idioma para un mensaje puntual ("respóndeme esto en inglés"), respetar esa solicitud solo para esa respuesta y volver a español después, sin necesidad de que lo vuelva a pedir.
