extends Node2D

@export var item_id: String = "chair_01"
@export var grid_position: Vector2i = Vector2i.ZERO
@export var grid_size: Vector2i = Vector2i(2, 2)
@export var rotation_degrees_data: int = 0

@export var front_texture: Texture2D
@export var back_texture: Texture2D


func setup(
	new_item_id: String,
	new_grid_position: Vector2i,
	new_rotation: int = 0,
	new_grid_size: Vector2i = Vector2i(2, 2)
) -> void:
	item_id = new_item_id
	grid_position = new_grid_position
	rotation_degrees_data = new_rotation
	grid_size = new_grid_size

	global_position = IsoGrid.grid_to_world(grid_position)

	apply_visual_direction()

	z_index = int(global_position.y)


func apply_visual_direction() -> void:
	var sprite := $Sprite2D as Sprite2D

	sprite.flip_h = false

	match rotation_degrees_data:
		0:
			if front_texture:
				sprite.texture = front_texture
			sprite.flip_h = false

		90:
			if back_texture:
				sprite.texture = back_texture
			sprite.flip_h = false

		180:
			if back_texture:
				sprite.texture = back_texture
			sprite.flip_h = true

		270:
			if front_texture:
				sprite.texture = front_texture
			sprite.flip_h = true


func to_save_data() -> Dictionary:
	return {
		"id": item_id,
		"x": grid_position.x,
		"y": grid_position.y,
		"size_x": grid_size.x,
		"size_y": grid_size.y,
		"rotation": rotation_degrees_data
	}
