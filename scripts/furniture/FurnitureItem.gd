extends Node2D

@export var item_id: String = "chair_01"
@export var grid_position: Vector2i = Vector2i.ZERO
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var rotation_degrees_data: int = 0

func setup(new_item_id: String, new_grid_position: Vector2i, new_rotation: int = 0) -> void:
	item_id = new_item_id
	grid_position = new_grid_position
	rotation_degrees_data = new_rotation

	global_position = IsoGrid.grid_to_world(grid_position)

	apply_visual_direction()

	z_index = int(global_position.y)


func apply_visual_direction() -> void:
	var sprite := $Sprite2D as Sprite2D

	sprite.flip_h = false

	match rotation_degrees_data:
		0:
			sprite.flip_h = false
		90:
			sprite.flip_h = false
		180:
			sprite.flip_h = false
		270:
			sprite.flip_h = true

func to_save_data() -> Dictionary:
	return {
		"id": item_id,
		"x": grid_position.x,
		"y": grid_position.y,
		"rotation": rotation_degrees_data
	}
