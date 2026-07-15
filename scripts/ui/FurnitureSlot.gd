extends Button

signal furniture_selected(furniture_id: String)

var item_id: String = ""

@onready var icon_rect: TextureRect = $VBoxContainer/Icon
@onready var name_label: Label = $VBoxContainer/NameLabel


func setup(new_item_id: String, item_data: Dictionary) -> void:
	item_id = new_item_id

	name_label.text = item_data.get("display_name", item_id)

	var texture_path: String = item_data.get("front_texture", "")

	if texture_path != "" and ResourceLoader.exists(texture_path):
		icon_rect.texture = load(texture_path)

	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)


func _on_pressed() -> void:
	furniture_selected.emit(item_id)
