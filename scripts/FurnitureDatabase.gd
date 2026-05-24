extends RefCounted

static var ITEMS: Dictionary = {
	"chair_2x2": {
		"display_name": "Chair",
		"size": Vector2i(2, 2),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": false
	},
	"table_4x2": {
		"display_name": "Small Table",
		"size": Vector2i(4, 2),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": true
	},
	"table_4x4": {
		"display_name": "Big Table",
		"size": Vector2i(4, 4),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": true
	},
	"bed_6x4": {
		"display_name": "Bed",
		"size": Vector2i(6, 4),
		"category": "furniture",
		"layer": "furniture",
		"provides_surface": false
	},
	"fountain_6x6": {
		"display_name": "Fountain",
		"size": Vector2i(6, 6),
		"category": "outdoor",
		"layer": "furniture",
		"provides_surface": false
	},
	"fridge_2x4": {
		"display_name": "Fridge",
		"size": Vector2i(2, 4),
		"category": "kitchen",
		"layer": "furniture",
		"provides_surface": false
	},
	"painting_2x2": {
		"display_name": "Painting",
		"size": Vector2i(2, 2),
		"category": "wall_decor",
		"layer": "wall",
		"provides_surface": false
	},
	"flower_vase_2x2": {
		"display_name": "Flower Vase",
		"size": Vector2i(2, 2),
		"category": "decoration",
		"layer": "surface",
		"provides_surface": false
	},
	"rug_4x4": {
		"display_name": "Rug",
		"size": Vector2i(4, 4),
		"category": "floor_decor",
		"layer": "floor",
		"provides_surface": false
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
