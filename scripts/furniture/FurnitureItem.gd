#FurnitureItem.gd
extends Node2D

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

@export var item_id: String = "chair_2x2"
@export var grid_position: Vector2i = Vector2i.ZERO
@export var grid_size: Vector2i = Vector2i(2, 2)
@export var rotation_degrees_data: int = 0

var is_selected: bool = false


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
	set_selected(false)

	z_index = int(global_position.y)

	_play_place_animation()


func _play_place_animation() -> void:
	scale = Vector2(0.01, 0.01)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)


func apply_visual_direction() -> void:
	var sprite := $Sprite2D as Sprite2D

	sprite.flip_h = false
	sprite.texture = FurnitureDatabase.get_texture_for_rotation(
		item_id,
		rotation_degrees_data
	)

	match rotation_degrees_data:
		0:
			sprite.flip_h = false

		90:
			sprite.flip_h = false

		180:
			sprite.flip_h = true

		270:
			sprite.flip_h = true

	var rotated_size: Vector2i = grid_size
	if rotation_degrees_data == 90 or rotation_degrees_data == 270:
		rotated_size = Vector2i(grid_size.y, grid_size.x)
	sprite.position = IsoGrid.get_footprint_center(rotated_size)


func set_selected(value: bool) -> void:
	is_selected = value

	var sprite := $Sprite2D as Sprite2D

	if is_selected:
		sprite.modulate = Color(1.0, 1.0, 0.4, 1.0)
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)


func move_to_grid(new_grid_position: Vector2i, new_rotation: int, new_grid_size: Vector2i) -> void:
	grid_position = new_grid_position
	rotation_degrees_data = new_rotation
	grid_size = new_grid_size

	global_position = IsoGrid.grid_to_world(grid_position)

	apply_visual_direction()
	set_selected(true)

	z_index = int(global_position.y)


func to_save_data() -> Dictionary:
	return {
		"id": item_id,
		"x": grid_position.x,
		"y": grid_position.y,
		"size_x": grid_size.x,
		"size_y": grid_size.y,
		"rotation": rotation_degrees_data
	}


func play_delete_animation() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.15)
	tween.tween_callback(queue_free)
