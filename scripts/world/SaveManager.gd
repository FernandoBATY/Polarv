extends Node
class_name SaveManager

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

signal save_completed
signal save_error(message: String)

const SAVE_PATH: String = "user://decorations_save.json"


func save_decorations(decorations_data: Array) -> void:
	var data := {
		"decorations": decorations_data
	}

	var json_text := JSON.stringify(data, "\t")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		print("ERROR AL GUARDAR: ", FileAccess.get_open_error())
		save_error.emit(FileAccess.get_open_error())
		return

	file.store_string(json_text)
	file.close()

	print("AUTO SAVE OK: ", SAVE_PATH)
	save_completed.emit()


func load_decorations_from_file() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		print("NO HAY SAVE LOCAL. MUNDO VACIO.")
		return []

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		print("ERROR AL CARGAR: ", FileAccess.get_open_error())
		return []

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)

	if error != OK:
		print("ERROR JSON: ", json.get_error_message())
		return []

	var data: Dictionary = json.data

	if data.has("decorations"):
		return data["decorations"]

	return []


func collect_save_data(furniture_root: Node2D) -> Array:
	var data: Array = []
	for furniture in furniture_root.get_children():
		if furniture.has_method("to_save_data"):
			data.append(furniture.to_save_data())
	return data


func load_and_place(data: Array, furniture_root: Node2D, occupancy_manager: OccupancyManager,
		selection_manager: SelectionManager, navigation_manager, decoration_controller) -> void:
	occupancy_manager.clear_all()

	for child in furniture_root.get_children():
		child.queue_free()

	selection_manager.selected_furniture = null
	selection_manager.is_moving = false
	decoration_controller.clear_selected_cells()

	var scene := preload("res://scenes/furniture/FurnitureItem.tscn")

	for decoration_data in data:
		var item_id: String = str(decoration_data["id"])

		if not FurnitureDatabase.has_item(item_id):
			print("NO SE PUDO CARGAR, ITEM NO EXISTE: ", item_id)
			continue

		var cell := Vector2i(int(decoration_data["x"]), int(decoration_data["y"]))
		var rotation_data: int = int(decoration_data.get("rotation", 0))
		var database_size: Vector2i = FurnitureDatabase.get_size(item_id)
		var rotated_size: Vector2i = decoration_controller.get_rotated_size(database_size, rotation_data)

		if not occupancy_manager.can_place_furniture(item_id, cell, rotated_size):
			print("NO SE PUDO CARGAR: ", decoration_data)
			continue

		var furniture := scene.instantiate()
		furniture_root.add_child(furniture)
		furniture.setup(item_id, cell, rotation_data, rotated_size)
		occupancy_manager.occupy_furniture_cells(furniture)

	navigation_manager.rebuild_blockers(furniture_root)