extends CanvasLayer
class_name HUD

@onready var deco_mode_panel: Panel = $DecoModePanel
@onready var deco_label: Label = $DecoModePanel/MarginContainer/VBoxContainer/DecoLabel

func _ready() -> void:
	set_deco_mode(false)

func set_deco_mode(active: bool) -> void:
	deco_mode_panel.visible = active
	if active:
		deco_label.text = "DECORATION MODE"
		deco_label.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
