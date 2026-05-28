extends RefCounted

static var ITEMS: Dictionary = {
	"chair_2x2": {
		"display_name": "Chair",
		"size": Vector2i(2, 2),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": false,
		"blocks_movement": true,
		"front_texture": "res://assets/furniture/chair_2x2_front.png",
		"back_texture": "res://assets/furniture/chair_2x2_back.png"
	},
	"table_4x2": {
		"display_name": "Small Table",
		"size": Vector2i(4, 2),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": true,
		"blocks_movement": true,
		"front_texture": "res://assets/furniture/table_4x2_front.png",
		"back_texture": "res://assets/furniture/table_4x2_back.png"
	},
	"table_4x4": {
		"display_name": "Big Table",
		"size": Vector2i(4, 4),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": true,
		"blocks_movement": true,
		"front_texture": "res://assets/furniture/table_4x4_front.png",
		"back_texture": "res://assets/furniture/table_4x4_back.png"
	},
	"bed_6x4": {
		"display_name": "Bed",
		"size": Vector2i(6, 4),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": false,
		"blocks_movement": true,
		"front_texture": "res://assets/furniture/bed_6x4_front.png",
		"back_texture": "res://assets/furniture/bed_6x4_back.png"
	},
	"fountain_6x6": {
		"display_name": "Fountain",
		"size": Vector2i(6, 6),
		"category": "outdoor",
		"layer": "furniture",
		"provides_surface": false,
		"blocks_movement": true,
		"front_texture": "res://assets/furniture/fountain_6x6_front.png",
		"back_texture": "res://assets/furniture/fountain_6x6_back.png"
	},
	"fridge_2x4": {
		"display_name": "Fridge",
		"size": Vector2i(2, 4),
		"category": "kitchen",
		"layer": "furniture",
		"provides_surface": false,
		"blocks_movement": true,
		"front_texture": "res://assets/furniture/fridge_2x4_front.png",
		"back_texture": "res://assets/furniture/fridge_2x4_back.png"
	},
	"painting_2x2": {
		"display_name": "Painting",
		"size": Vector2i(2, 2),
		"category": "wall_decor",
		"layer": "wall",
		"provides_surface": false,
		"blocks_movement": false,
		"front_texture": "res://assets/furniture/painting_2x2_front.png",
		"back_texture": "res://assets/furniture/painting_2x2_back.png"
	},
	"flower_vase_2x2": {
		"display_name": "Flower Vase",
		"size": Vector2i(2, 2),
		"category": "decoration",
		"layer": "surface",
		"provides_surface": false,
		"blocks_movement": false,
		"front_texture": "res://assets/furniture/flower_vase_2x2_front.png",
		"back_texture": "res://assets/furniture/flower_vase_2x2_back.png"
	},
	"rug_4x4": {
		"display_name": "Rug",
		"size": Vector2i(4, 4),
		"category": "floor_decor",
		"layer": "floor",
		"provides_surface": false,
		"blocks_movement": false,
		"front_texture": "res://assets/furniture/rug_4x4_front.png",
		"back_texture": "res://assets/furniture/rug_4x4_back.png"
	}
}


static func has_item(item_id: String) -> bool:
	return ITEMS.has(item_id)


static func get_item(item_id: String) -> Dictionary:
	if not ITEMS.has(item_id):
		return {}

	return ITEMS[item_id]


static func get_size(item_id: String) -> Vector2i:
	if not ITEMS.has(item_id):
		return Vector2i(2, 2)

	return ITEMS[item_id]["size"]


static func provides_surface(item_id: String) -> bool:
	if not ITEMS.has(item_id):
		return false

	return bool(ITEMS[item_id].get("provides_surface", false))


static func blocks_movement(item_id: String) -> bool:
	if not ITEMS.has(item_id):
		return false

	return bool(ITEMS[item_id].get("blocks_movement", false))


static func get_texture_path_for_rotation(item_id: String, rotation_data: int) -> String:
	if not ITEMS.has(item_id):
		return ""

	if rotation_data == 90 or rotation_data == 180:
		return str(ITEMS[item_id].get("back_texture", ""))

	return str(ITEMS[item_id].get("front_texture", ""))


static func get_texture_for_rotation(item_id: String, rotation_data: int) -> Texture2D:
	var path: String = get_texture_path_for_rotation(item_id, rotation_data)

	if path == "":
		return null

	if not ResourceLoader.exists(path):
		print("TEXTURE NO EXISTE: ", path)
		return null

	return load(path)
