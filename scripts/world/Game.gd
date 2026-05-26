extends Node2D

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

const FURNITURE_ITEM_SCENE: PackedScene = preload("res://scenes/furniture/FurnitureItem.tscn")
const SAVE_PATH: String = "user://decorations_save.json"

const OCCUPANCY_LAYERS := [
	"floor",
	"furniture",
	"surface",
	"wall",
	"ceiling"
]

var occupied_cells: Dictionary = {}
var current_preview_valid: bool = true
var decoration_mode: bool = true
var current_rotation: int = 0

var current_furniture_id: String = "chair_2x2"
var current_furniture_size: Vector2i = Vector2i(2, 2)

var selected_furniture: Node = null
var is_moving_selected: bool = false
var move_original_position: Vector2i = Vector2i.ZERO
var move_original_rotation: int = 0
var move_original_size: Vector2i = Vector2i(2, 2)

var selected_cells_root: Node2D

@onready var player: CharacterBody2D = $Player
@onready var grid_debug: Sprite2D = $GridDebug
@onready var furniture_root: Node2D = $FurnitureRoot
@onready var furniture_preview: Node2D = $FurniturePreview
@onready var preview_cells: Node2D = $FurniturePreview/PreviewCells


func _ready() -> void:
	selected_cells_root = Node2D.new()
	selected_cells_root.name = "SelectedCells"
	add_child(selected_cells_root)

	load_decorations_from_file()
	select_furniture(current_furniture_id)
	set_decoration_mode(decoration_mode)


func _process(_delta: float) -> void:
	if player:
		player.z_index = int(player.global_position.y)

	update_grid_debug()

	if decoration_mode:
		update_furniture_preview()
		update_selected_cells_display()
		furniture_preview.visible = true
		selected_cells_root.visible = true
	else:
		furniture_preview.visible = false
		selected_cells_root.visible = false


func set_decoration_mode(value: bool) -> void:
	decoration_mode = value

	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(not decoration_mode)

	if not decoration_mode:
		if is_moving_selected:
			cancel_selection_or_move()

		if selected_furniture != null:
			selected_furniture.set_selected(false)
			selected_furniture = null

		clear_selected_cells()

	print("DECORATION MODE: ", decoration_mode)


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

	var preview_id: String = current_furniture_id
	var preview_size: Vector2i = current_furniture_size
	var preview_rotation: int = current_rotation

	if is_moving_selected and selected_furniture != null:
		preview_id = selected_furniture.item_id
		preview_size = FurnitureDatabase.get_size(preview_id)
		preview_rotation = selected_furniture.rotation_degrees_data

	var rotated_size: Vector2i = get_rotated_size(preview_size, preview_rotation)

	current_preview_valid = can_place_furniture(
		preview_id,
		cell,
		rotated_size
	)

	update_preview_cells(cell, rotated_size, current_preview_valid)

	var preview_sprite := furniture_preview.get_node("Sprite2D") as Sprite2D
	preview_sprite.flip_h = preview_rotation == 180 or preview_rotation == 270

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


func update_selected_cells_display() -> void:
	clear_selected_cells()

	if selected_furniture == null:
		return

	var origin: Vector2i = selected_furniture.grid_position
	var size: Vector2i = selected_furniture.grid_size

	if is_moving_selected:
		origin = IsoGrid.world_to_grid(get_global_mouse_position())

		var base_size: Vector2i = FurnitureDatabase.get_size(selected_furniture.item_id)
		size = get_rotated_size(base_size, selected_furniture.rotation_degrees_data)

	var cells: Array[Vector2i] = get_cells_for_furniture(origin, size)

	for cell in cells:
		var cell_sprite := Sprite2D.new()
		cell_sprite.texture = grid_debug.texture
		cell_sprite.centered = true
		cell_sprite.global_position = IsoGrid.grid_to_world(cell)
		cell_sprite.z_index = int(cell_sprite.global_position.y) - 5
		cell_sprite.modulate = Color(1.0, 0.5, 0.0, 0.55)

		selected_cells_root.add_child(cell_sprite)


func clear_selected_cells() -> void:
	if selected_cells_root == null:
		return

	for child in selected_cells_root.get_children():
		child.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_D:
			set_decoration_mode(not decoration_mode)

		if event.pressed and event.keycode == KEY_R and decoration_mode:
			if is_moving_selected and selected_furniture != null:
				rotate_selected_for_move()
			else:
				current_rotation += 90

				if current_rotation >= 360:
					current_rotation = 0

			print("DIRECTION: ", current_rotation)

		if event.pressed and event.keycode == KEY_M and decoration_mode:
			start_move_selected()

		if event.pressed and decoration_mode and (event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE):
			delete_selected_furniture()

		if event.pressed and event.keycode == KEY_ESCAPE and decoration_mode:
			cancel_selection_or_move()

		if event.pressed and event.keycode == KEY_1 and decoration_mode:
			select_furniture("chair_2x2")

		if event.pressed and event.keycode == KEY_2 and decoration_mode:
			select_furniture("table_4x2")

		if event.pressed and event.keycode == KEY_3 and decoration_mode:
			select_furniture("table_4x4")

		if event.pressed and event.keycode == KEY_4 and decoration_mode:
			select_furniture("bed_6x4")

		if event.pressed and event.keycode == KEY_5 and decoration_mode:
			select_furniture("fountain_6x6")

		if event.pressed and event.keycode == KEY_6 and decoration_mode:
			select_furniture("fridge_2x4")

		if event.pressed and event.keycode == KEY_7 and decoration_mode:
			select_furniture("painting_2x2")

		if event.pressed and event.keycode == KEY_8 and decoration_mode:
			select_furniture("flower_vase_2x2")

		if event.pressed and event.keycode == KEY_9 and decoration_mode:
			select_furniture("rug_4x4")

		if event.pressed and event.keycode == KEY_P:
			print(get_decorations_save_data())

		if event.pressed and event.keycode == KEY_S:
			save_decorations_to_file()

	if event is InputEventMouseButton:
		if decoration_mode and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_decoration_click()


func handle_decoration_click() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var cell: Vector2i = IsoGrid.world_to_grid(mouse_position)

	if is_moving_selected and selected_furniture != null:
		confirm_move_selected(cell)
		return

	var clicked_furniture: Node = get_top_furniture_at_cell(cell)

	if clicked_furniture != null:
		select_existing_furniture(clicked_furniture)
		return

	if current_preview_valid:
		spawn_test_furniture(cell)


func select_furniture(furniture_id: String) -> void:
	if not FurnitureDatabase.has_item(furniture_id):
		print("ERROR: MUEBLE NO EXISTE EN DATABASE: ", furniture_id)
		return

	if selected_furniture != null:
		selected_furniture.set_selected(false)
		selected_furniture = null

	is_moving_selected = false
	clear_selected_cells()

	var furniture_data: Dictionary = FurnitureDatabase.get_item(furniture_id)

	current_furniture_id = furniture_id
	current_furniture_size = furniture_data["size"]

	print("FURNITURE SELECTED: ", current_furniture_id, " SIZE: ", current_furniture_size)


func select_existing_furniture(furniture: Node) -> void:
	if selected_furniture != null:
		selected_furniture.set_selected(false)

	selected_furniture = furniture
	selected_furniture.set_selected(true)

	is_moving_selected = false

	print("SELECTED EXISTING: ", selected_furniture.item_id)


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


func start_move_selected() -> void:
	if selected_furniture == null:
		print("NO HAY MUEBLE SELECCIONADO")
		return

	is_moving_selected = true

	move_original_position = selected_furniture.grid_position
	move_original_rotation = selected_furniture.rotation_degrees_data
	move_original_size = selected_furniture.grid_size

	free_furniture_cells(selected_furniture)

	print("MOVIENDO: ", selected_furniture.item_id)


func confirm_move_selected(cell: Vector2i) -> void:
	if selected_furniture == null:
		return

	var item_id: String = selected_furniture.item_id
	var rotation_data: int = selected_furniture.rotation_degrees_data
	var base_size: Vector2i = FurnitureDatabase.get_size(item_id)
	var rotated_size: Vector2i = get_rotated_size(base_size, rotation_data)

	if not can_place_furniture(item_id, cell, rotated_size):
		print("NO SE PUEDE MOVER A: ", cell)
		return

	selected_furniture.move_to_grid(
		cell,
		rotation_data,
		rotated_size
	)

	occupy_furniture_cells(selected_furniture)

	is_moving_selected = false

	print("MUEBLE MOVIDO: ", selected_furniture.item_id, " A ", cell)


func rotate_selected_for_move() -> void:
	if selected_furniture == null:
		return

	var new_rotation: int = selected_furniture.rotation_degrees_data + 90

	if new_rotation >= 360:
		new_rotation = 0

	var base_size: Vector2i = FurnitureDatabase.get_size(selected_furniture.item_id)
	var rotated_size: Vector2i = get_rotated_size(base_size, new_rotation)

	selected_furniture.move_to_grid(
		selected_furniture.grid_position,
		new_rotation,
		rotated_size
	)


func cancel_selection_or_move() -> void:
	if is_moving_selected and selected_furniture != null:
		selected_furniture.move_to_grid(
			move_original_position,
			move_original_rotation,
			move_original_size
		)

		occupy_furniture_cells(selected_furniture)

		is_moving_selected = false

		print("MOVIMIENTO CANCELADO")
		return

	if selected_furniture != null:
		selected_furniture.set_selected(false)
		selected_furniture = null
		clear_selected_cells()

		print("SELECCION CANCELADA")


func delete_selected_furniture() -> void:
	if selected_furniture == null:
		print("NO HAY MUEBLE SELECCIONADO")
		return

	if is_moving_selected:
		is_moving_selected = false
	else:
		free_furniture_cells(selected_furniture)

	print("MUEBLE BORRADO: ", selected_furniture.item_id)

	selected_furniture.queue_free()
	selected_furniture = null
	clear_selected_cells()


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


func spawn_test_furniture(cell: Vector2i) -> void:
	var rotated_size: Vector2i = get_rotated_size(current_furniture_size, current_rotation)

	if not can_place_furniture(
		current_furniture_id,
		cell,
		rotated_size
	):
		print("NO SE PUEDE COLOCAR: ", current_furniture_id, " CELL: ", cell, " SIZE: ", rotated_size)
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
		print("NO HAY SAVE LOCAL. MUNDO VACIO.")
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

	selected_furniture = null
	is_moving_selected = false
	clear_selected_cells()

	for decoration_data in data:
		var item_id: String = str(decoration_data["id"])

		if not FurnitureDatabase.has_item(item_id):
			print("NO SE PUDO CARGAR, ITEM NO EXISTE: ", item_id)
			continue

		var cell := Vector2i(
			int(decoration_data["x"]),
			int(decoration_data["y"])
		)

		var rotation_data: int = int(decoration_data.get("rotation", 0))

		var database_size: Vector2i = FurnitureDatabase.get_size(item_id)
		var rotated_size: Vector2i = get_rotated_size(database_size, rotation_data)

		if not can_place_furniture(
			item_id,
			cell,
			rotated_size
		):
			print("NO SE PUDO CARGAR: ", decoration_data)
			continue

		var furniture := FURNITURE_ITEM_SCENE.instantiate()
		furniture_root.add_child(furniture)

		furniture.setup(
			item_id,
			cell,
			rotation_data,
			rotated_size
		)

		occupy_furniture_cells(furniture)
