extends Panel
class_name WindowBase

signal window_closed

var _block_backdrop_close: bool = false

@onready var backdrop: ColorRect = $Backdrop
@onready var window_margin: MarginContainer = $WindowMargin
@onready var title_label: Label = $WindowMargin/VBoxContainer/TitleBar/TitleLabel
@onready var close_button: Button = $WindowMargin/VBoxContainer/TitleBar/CloseButton
@onready var content_container: MarginContainer = $WindowMargin/VBoxContainer/ContentContainer


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	backdrop.gui_input.connect(_on_backdrop_input)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP


func open(title: String = "") -> void:
	title_label.text = title
	visible = true
	window_margin.scale = Vector2(0.9, 0.9)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(window_margin, "scale", Vector2.ONE, 0.15)


func close() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(window_margin, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_callback(_finish_close)


func _finish_close() -> void:
	visible = false
	window_closed.emit()


func _on_close_pressed() -> void:
	close()


func _on_backdrop_input(event: InputEvent) -> void:
	if _block_backdrop_close:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()


func set_title(text: String) -> void:
	title_label.text = text