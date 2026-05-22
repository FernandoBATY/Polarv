extends Node2D
var occupied_cells: Dictionary = {}
var current_preview_valid: bool = true
@onready var player: CharacterBody2D = $Player
@onready var grid_debug: Sprite2D = $GridDebug
@onready var furniture_root: Node2D = $FurnitureRoot
@onready var furniture_preview: Node2D = $FurniturePreview

var last_cell: Vector2i = Vector2i(999999, 999999)

const FURNITURE_ITEM_SCENE: PackedScene = preload("res://scenes/furniture/FurnitureItem.tscn")

func _ready() -> void:
	spawn_test_furniture(Vector2i(5, 2))

func _process(_delta: float) -> void:
	if player:
		player.z_index = int(player.global_position.y)

	update_grid_debug()
	update_furniture_preview()

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

	if current_preview_valid:
		preview_sprite.modulate = Color(0, 1, 0, 0.5)
	else:
		preview_sprite.modulate = Color(1, 0, 0, 0.5)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

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

	furniture.setup("chair_01", cell, 0)

	occupied_cells[cell] = furniture
