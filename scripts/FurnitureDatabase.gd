extends RefCounted

static var ITEMS: Dictionary = {
	"chair_01": {
		"display_name": "Chair",
		"size": Vector2i(1, 1),
		"category": "furniture",
		"layer": "furniture"
	},
	"table_2x1": {
		"display_name": "Small Table",
		"size": Vector2i(2, 1),
		"category": "furniture",
		"layer": "furniture"
	},
	"table_2x2": {
		"display_name": "Big Table",
		"size": Vector2i(2, 2),
		"category": "furniture",
		"layer": "furniture"
	},
	"bed_3x2": {
		"display_name": "Bed",
		"size": Vector2i(3, 2),
		"category": "furniture",
		"layer": "furniture"
	},
	"fountain_3x3": {
		"display_name": "Fountain",
		"size": Vector2i(3, 3),
		"category": "outdoor",
		"layer": "furniture"
	},
	"fridge_1x2": {
		"display_name": "Fridge",
		"size": Vector2i(1, 2),
		"category": "kitchen",
		"layer": "furniture"
	},
	"painting_1x1": {
		"display_name": "Painting",
		"size": Vector2i(1, 1),
		"category": "wall_decor",
		"layer": "wall"
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
		return Vector2i(1, 1)

	return ITEMS[item_id]["size"]
