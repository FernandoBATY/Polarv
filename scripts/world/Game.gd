extends Node2D
const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

var occupied_cells: Dictionary = {}
var current_preview_valid: bool = true
var decoration_mode: bool = true
var current_rotation: int = 0

var current_furniture_id: String = "chair_01"
var current_furniture_size: Vector2i = Vector2i(1, 1)

@onready var player: CharacterBody2D = $Player
@onready var grid_debug: Sprite2D = $GridDebug
@onready var furniture_root: Node2D = $FurnitureRoot
@onready var furniture_preview: Node2D = $FurniturePreview
@onready var preview_cells: Node2D = $FurniturePreview/PreviewCells

const FURNITURE_ITEM_SCENE: PackedScene = preload("res://scenes/furniture/FurnitureItem.tscn")
const SAVE_PATH: String = "user://decorations_save.json"


func _ready() -> void:
	load_decorations_from_file()
	select_furniture(current_furniture_id)


func _process(_delta: float) -> void:
	if player:
		player.z_index = int(player.global_position.y)

	update_grid_debug()

	if decoration_mode:
		update_furniture_preview()
		furniture_preview.visible = true
	else:
		furniture_preview.visible = false


func update_grid_debug() -> void:
	var cell: Vector2i = IsoGrid.world_to_grid(player.global_position)
	var grid_world_position: Vector2 = IsoGrid.grid_to_world(cell)

	grid_debug.global_position = grid_world_position
	grid_debug.z_index = int(grid_debug.global_position.y) - 1


func update_furniture_preview() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var cell: Vector2i = IsoGrid.world_to_grid(mouse_position)
	var snapped_position: Vector2 = IsoGrid.grid_to_world(cell)

	furniture_preview.global_position = snapped_position
	furniture_preview.z_index = int(snapped_position.y)

	var rotated_size: Vector2i = get_rotated_size(current_furniture_size, current_rotation)

	current_preview_valid = can_place_furniture(cell, rotated_size)

	update_preview_cells(cell, rotated_size, current_preview_valid)

	var preview_sprite := furniture_preview.get_node("Sprite2D") as Sprite2D
	preview_sprite.flip_h = current_rotation == 180 or current_rotation == 270

	if current_preview_valid:
		preview_sprite.modulate = Color(0, 1, 0, 0.5)
	else:
		preview_sprite.modulate = Color(1, 0, 0, 0.5)


func update_preview_cells(origin: Vector2i, size: Vector2i, is_valid: bool) -> void:
	for child in preview_cells.get_children():
		child.queue_free()

	var origin_world: Vector2 = IsoGrid.grid_to_world(origin)
	var cells: Array[Vector2i] = get_cells_for_furniture(origin, size)

	for cell in cells:
		var cell_sprite := Sprite2D.new()
		cell_sprite.texture = grid_debug.texture
		cell_sprite.centered = true

		var cell_world: Vector2 = IsoGrid.grid_to_world(cell)
		cell_sprite.position = cell_world - origin_world
		cell_sprite.z_index = -10

		if is_valid:
			cell_sprite.modulate = Color(0, 1, 0, 0.35)
		else:
			cell_sprite.modulate = Color(1, 0, 0, 0.35)

		preview_cells.add_child(cell_sprite)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_D:
			decoration_mode = !decoration_mode
			print("DECORATION MODE: ", decoration_mode)

		if event.pressed and event.keycode == KEY_R:
			current_rotation += 90

			if current_rotation >= 360:
				current_rotation = 0

			print("DIRECTION: ", current_rotation)

		if event.pressed and event.keycode == KEY_1:
			select_furniture("chair_01")

		if event.pressed and event.keycode == KEY_2:
			select_furniture("table_2x1")

		if event.pressed and event.keycode == KEY_3:
			select_furniture("table_2x2")

		if event.pressed and event.keycode == KEY_4:
			select_furniture("bed_3x2")

		if event.pressed and event.keycode == KEY_5:
			select_furniture("fountain_3x3")

		if event.pressed and event.keycode == KEY_6:
			select_furniture("fridge_1x2")

		if event.pressed and event.keycode == KEY_7:
			select_furniture("painting_1x1")

		if event.pressed and event.keycode == KEY_P:
			var data := get_decorations_save_data()
			print(data)

		if event.pressed and event.keycode == KEY_S:
			save_decorations_to_file()

	if event is InputEventMouseButton:
		if decoration_mode and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position: Vector2 = get_global_mouse_position()
			var cell: Vector2i = IsoGrid.world_to_grid(mouse_position)

			if current_preview_valid:
				spawn_test_furniture(cell)


func select_furniture(furniture_id: String) -> void:
	if not FurnitureDatabase.has_item(furniture_id):
		print("ERROR: MUEBLE NO EXISTE EN DATABASE: ", furniture_id)
		return

	var furniture_data: Dictionary = FurnitureDatabase.get_item(furniture_id)

	current_furniture_id = furniture_id
	current_furniture_size = furniture_data["size"]

	print("FURNITURE SELECTED: ", current_furniture_id, " SIZE: ", current_furniture_size)


func get_rotated_size(size: Vector2i, rotation_data: int) -> Vector2i:
	if rotation_data == 90 or rotation_data == 270:
		return Vector2i(size.y, size.x)

	return size


func get_cells_for_furniture(origin: Vector2i, size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for x in range(size.x):
		for y in range(size.y):
			cells.append(origin + Vector2i(x, y))

	return cells


func can_place_furniture(origin: Vector2i, size: Vector2i) -> bool:
	var cells: Array[Vector2i] = get_cells_for_furniture(origin, size)

	for cell in cells:
		if occupied_cells.has(cell):
			return false

	return true


func occupy_furniture_cells(furniture: Node) -> void:
	var cells: Array[Vector2i] = get_cells_for_furniture(
		furniture.grid_position,
		furniture.grid_size
	)

	for cell in cells:
		occupied_cells[cell] = furniture


func free_furniture_cells(furniture: Node) -> void:
	var cells: Array[Vector2i] = get_cells_for_furniture(
		furniture.grid_position,
		furniture.grid_size
	)

	for cell in cells:
		if occupied_cells.has(cell) and occupied_cells[cell] == furniture:
			occupied_cells.erase(cell)


func spawn_test_furniture(cell: Vector2i) -> void:
	var rotated_size: Vector2i = get_rotated_size(current_furniture_size, current_rotation)

	if not can_place_furniture(cell, rotated_size):
		print("ESPACIO OCUPADO: ", cell, " SIZE: ", rotated_size)
		return

	var furniture := FURNITURE_ITEM_SCENE.instantiate()
	furniture_root.add_child(furniture)

	furniture.setup(
		current_furniture_id,
		cell,
		current_rotation,
		rotated_size
	)

	occupy_furniture_cells(furniture)


func get_decorations_save_data() -> Array:
	var decorations: Array = []

	for furniture in furniture_root.get_children():
		if furniture.has_method("to_save_data"):
			decorations.append(furniture.to_save_data())

	return decorations


func save_decorations_to_file() -> void:
	var data := {
		"decorations": get_decorations_save_data()
	}

	var json_text := JSON.stringify(data, "\t")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("ERROR AL GUARDAR: ", FileAccess.get_open_error())
		return

	file.store_string(json_text)
	file.close()

	print("GUARDADO OK: ", SAVE_PATH)


func load_decorations_from_file() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("NO HAY SAVE LOCAL, CARGANDO DATOS FAKE")
		load_decorations(get_fake_save_data())
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("ERROR AL CARGAR: ", FileAccess.get_open_error())
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)

	if error != OK:
		print("ERROR JSON: ", json.get_error_message())
		return

	var data: Dictionary = json.data

	if data.has("decorations"):
		load_decorations(data["decorations"])


func load_decorations(data: Array) -> void:
	occupied_cells.clear()

	for child in furniture_root.get_children():
		child.queue_free()

	for decoration_data in data:
		var cell := Vector2i(
			int(decoration_data["x"]),
			int(decoration_data["y"])
		)

		var rotation_data: int = int(decoration_data.get("rotation", 0))

		var size := Vector2i(
			int(decoration_data.get("size_x", 1)),
			int(decoration_data.get("size_y", 1))
		)

		if not can_place_furniture(cell, size):
			print("NO SE PUDO CARGAR, ESPACIO OCUPADO: ", decoration_data)
			continue

		var furniture := FURNITURE_ITEM_SCENE.instantiate()
		furniture_root.add_child(furniture)

		furniture.setup(
			str(decoration_data["id"]),
			cell,
			rotation_data,
			size
		)

		occupy_furniture_cells(furniture)


func get_fake_save_data() -> Array:
	return [
		{
			"id": "chair_01",
			"x": 5,
			"y": 2,
			"size_x": 1,
			"size_y": 1,
			"rotation": 0
		},
		{
			"id": "table_2x1",
			"x": 8,
			"y": 3,
			"size_x": 2,
			"size_y": 1,
			"rotation": 270
		},
		{
			"id": "table_2x2",
			"x": 10,
			"y": 5,
			"size_x": 2,
			"size_y": 2,
			"rotation": 180
		},
		{
			"id": "bed_3x2",
			"x": 4,
			"y": 7,
			"size_x": 3,
			"size_y": 2,
			"rotation": 0
		},
		{
			"id": "fountain_3x3",
			"x": 12,
			"y": 8,
			"size_x": 3,
			"size_y": 3,
			"rotation": 0
		}
	]
