extends Button

signal furniture_selected(furniture_id: String)

var item_id: String = ""

@onready var icon_rect: TextureRect = $VBoxContainer/Icon
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var rarity_bar: ColorRect = $RarityBar


func setup(new_item_id: String, item_data: Dictionary) -> void:
	item_id = new_item_id
	name_label.text = item_data.get("display_name", item_id)

	var texture_path: String = item_data.get("front_texture", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		icon_rect.texture = load(texture_path)

	var rarity: String = item_data.get("rarity", "COMMON")
	_set_rarity_color(rarity)

	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)


func _on_pressed() -> void:
	furniture_selected.emit(item_id)


func _set_rarity_color(rarity: String) -> void:
	match rarity:
		"COMMON":
			rarity_bar.color = Color(0.6, 0.6, 0.6)
		"RARE":
			rarity_bar.color = Color(0.3, 0.6, 1.0)
		"EPIC":
			rarity_bar.color = Color(0.6, 0.2, 0.9)
		"LEGENDARY":
			rarity_bar.color = Color(1.0, 0.7, 0.1)
		"SEASONAL":
			rarity_bar.color = Color(0.1, 0.8, 0.4)
		"EVENT":
			rarity_bar.color = Color(1.0, 0.3, 0.3)
		"PREMIUM":
			rarity_bar.color = Color(1.0, 0.5, 0.8)
		_:
			rarity_bar.color = Color(0.6, 0.6, 0.6)