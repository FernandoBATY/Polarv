extends Node2D

var occupied_cells: Dictionary = {}
var current_preview_valid: bool = true
var decoration_mode: bool = true
var current_rotation: int = 0

@onready var player: CharacterBody2D = $Player
@onready var grid_debug: Sprite2D = $GridDebug
@onready var furniture_root: Node2D = $FurnitureRoot
@onready var furniture_preview: Node2D = $FurniturePreview

const FURNITURE_ITEM_SCENE: PackedScene = preload("res://scenes/furniture/FurnitureItem.tscn")
const SAVE_PATH: String = "user://decorations_save.json"

func _ready() -> void:
	load_decorations_from_file()


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
	var mouse_position := get_global_mouse_position()
	var cell := IsoGrid.world_to_grid(mouse_position)
	var snapped_position := IsoGrid.grid_to_world(cell)

	furniture_preview.global_position = snapped_position
	furniture_preview.z_index = int(snapped_position.y)

	current_preview_valid = !occupied_cells.has(cell)

	var preview_sprite := furniture_preview.get_node("Sprite2D") as Sprite2D
	preview_sprite.flip_h = current_rotation == 270

	if current_preview_valid:
		preview_sprite.modulate = Color(0, 1, 0, 0.5)
	else:
		preview_sprite.modulate = Color(1, 0, 0, 0.5)


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

		if event.pressed and event.keycode == KEY_P:
			var data := get_decorations_save_data()
			print(data)

		if event.pressed and event.keycode == KEY_S:
			save_decorations_to_file()

	if event is InputEventMouseButton:
		if decoration_mode and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position := get_global_mouse_position()
			var cell := IsoGrid.world_to_grid(mouse_position)

			if current_preview_valid:
				spawn_test_furniture(cell)


func spawn_test_furniture(cell: Vector2i) -> void:
	if occupied_cells.has(cell):
		print("CELDA OCUPADA: ", cell)
		return

	var furniture := FURNITURE_ITEM_SCENE.instantiate()
	furniture_root.add_child(furniture)

	furniture.setup("chair_01", cell, current_rotation)

	occupied_cells[cell] = furniture


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
	for decoration_data in data:
		var cell := Vector2i(
			decoration_data["x"],
			decoration_data["y"]
		)

		var rotation: int = decoration_data["rotation"]

		var furniture := FURNITURE_ITEM_SCENE.instantiate()
		furniture_root.add_child(furniture)

		furniture.setup(
			decoration_data["id"],
			cell,
			rotation
		)

		occupied_cells[cell] = furniture


func get_fake_save_data() -> Array:
	return [
		{
			"id": "chair_01",
			"x": 5,
			"y": 2,
			"rotation": 0
		},
		{
			"id": "chair_01",
			"x": 8,
			"y": 3,
			"rotation": 270
		},
		{
			"id": "chair_01",
			"x": 10,
			"y": 5,
			"rotation": 180
		}
	]
