extends Node
class_name OccupancyManager

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

const OCCUPANCY_LAYERS := [
	"floor",
	"furniture",
	"surface",
	"wall",
	"ceiling"
]

var occupied_cells: Dictionary = {}


func ensure_cell_exists(cell: Vector2i) -> void:
	if not occupied_cells.has(cell):
		occupied_cells[cell] = {}

	for layer: String in OCCUPANCY_LAYERS:
		if not occupied_cells[cell].has(layer):
			occupied_cells[cell][layer] = null


func get_furniture_layer(item_id: String) -> String:
	var data: Dictionary = FurnitureDatabase.get_item(item_id)

	if data.has("layer"):
		return str(data["layer"])

	return "furniture"


func cell_has_surface_provider(cell: Vector2i) -> bool:
	ensure_cell_exists(cell)

	var base_furniture = occupied_cells[cell]["furniture"]

	if base_furniture == null:
		return false

	return FurnitureDatabase.provides_surface(base_furniture.item_id)


func can_place_surface_item(origin: Vector2i, size: Vector2i) -> bool:
	var cells: Array[Vector2i] = get_cells_for_furniture(origin, size)

	for cell in cells:
		ensure_cell_exists(cell)

		if occupied_cells[cell]["surface"] != null:
			return false

		if not cell_has_surface_provider(cell):
			return false

	return true


func can_place_furniture(item_id: String, origin: Vector2i, size: Vector2i) -> bool:
	var layer: String = get_furniture_layer(item_id)

	if layer == "surface":
		return can_place_surface_item(origin, size)

	var cells: Array[Vector2i] = get_cells_for_furniture(origin, size)

	for cell in cells:
		ensure_cell_exists(cell)

		if occupied_cells[cell][layer] != null:
			return false

	return true


func occupy_furniture_cells(furniture: Node) -> void:
	var layer: String = get_furniture_layer(furniture.item_id)

	var cells: Array[Vector2i] = get_cells_for_furniture(
		furniture.grid_position,
		furniture.grid_size
	)

	for cell in cells:
		ensure_cell_exists(cell)
		occupied_cells[cell][layer] = furniture


func free_furniture_cells(furniture: Node) -> void:
	var layer: String = get_furniture_layer(furniture.item_id)

	var cells: Array[Vector2i] = get_cells_for_furniture(
		furniture.grid_position,
		furniture.grid_size
	)

	for cell in cells:
		ensure_cell_exists(cell)

		if occupied_cells[cell][layer] == furniture:
			occupied_cells[cell][layer] = null


func is_cell_blocked_for_movement(cell: Vector2i) -> bool:
	if not occupied_cells.has(cell):
		return false

	ensure_cell_exists(cell)

	for layer: String in OCCUPANCY_LAYERS:
		var furniture = occupied_cells[cell][layer]

		if furniture == null:
			continue

		if FurnitureDatabase.blocks_movement(furniture.item_id):
			return true

	return false


func get_top_furniture_at_cell(cell: Vector2i) -> Node:
	if not occupied_cells.has(cell):
		return null

	var layer_priority := [
		"surface",
		"ceiling",
		"wall",
		"furniture",
		"floor"
	]

	for layer: String in layer_priority:
		if occupied_cells[cell].has(layer):
			var furniture = occupied_cells[cell][layer]

			if furniture != null:
				return furniture

	return null


func get_cells_for_furniture(origin: Vector2i, size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for x in range(size.x):
		for y in range(size.y):
			cells.append(origin + Vector2i(x, y))

	return cells


func clear_all() -> void:
	occupied_cells.clear()


func get_all_occupied_furniture() -> Array:
	var seen: Array = []

	for cell in occupied_cells:
		for layer: String in OCCUPANCY_LAYERS:
			var f = occupied_cells[cell][layer]

			if f != null and not seen.has(f):
				seen.append(f)

	return seen