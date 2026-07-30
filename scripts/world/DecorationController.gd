extends Node
class_name DecorationController

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")
const FURNITURE_ITEM_SCENE: PackedScene = preload("res://scenes/furniture/FurnitureItem.tscn")

var current_furniture_id: String = "chair_2x2"
var current_furniture_size: Vector2i = Vector2i(2, 2)
var current_rotation: int = 0
var preview_valid: bool = true
var rotation_tween: Tween = null
var is_rotating: bool = false
var move_ghost_sprite: Sprite2D = null
var preview_shadow: Sprite2D = null

var furniture_root: Node2D
var furniture_preview: Node2D
var preview_cells: Node2D
var grid_debug: Sprite2D
var selected_cells_root: Node2D

var occupancy_manager: OccupancyManager
var selection_manager: SelectionManager
var navigation_manager
var save_manager: SaveManager

signal furniture_placed(furniture: Node, cell: Vector2i)
signal rotation_changed(rotation: int)


func setup(f_root: Node2D, f_preview: Node2D, p_cells: Node2D, g_debug: Sprite2D,
			sel_root: Node2D, occ: OccupancyManager, sel: SelectionManager,
			nav, save: SaveManager) -> void:
	furniture_root = f_root
	furniture_preview = f_preview
	preview_cells = p_cells
	grid_debug = g_debug
	selected_cells_root = sel_root
	occupancy_manager = occ
	selection_manager = sel
	navigation_manager = nav
	save_manager = save

	preview_shadow = Sprite2D.new()
	preview_shadow.name = "PreviewShadow"
	preview_shadow.z_index = -10
	preview_shadow.modulate = Color(0, 0, 0, 0.2)
	furniture_preview.add_child(preview_shadow)


func select_furniture(furniture_id: String) -> void:
	if not FurnitureDatabase.has_item(furniture_id):
		print("ERROR: MUEBLE NO EXISTE EN DATABASE: ", furniture_id)
		return

	var data: Dictionary = FurnitureDatabase.get_item(furniture_id)
	current_furniture_id = furniture_id
	current_furniture_size = data["size"]

	print("FURNITURE SELECTED: ", current_furniture_id, " SIZE: ", current_furniture_size)


func update_preview() -> void:
	var mouse_pos: Vector2 = furniture_root.get_global_mouse_position()
	var cell: Vector2i = IsoGrid.world_to_grid(mouse_pos)
	var snapped_pos: Vector2 = IsoGrid.grid_to_world(cell)

	furniture_preview.global_position = snapped_pos
	furniture_preview.z_index = int(snapped_pos.y)

	var preview_id: String = current_furniture_id
	var preview_size: Vector2i = current_furniture_size
	var preview_rotation: int = current_rotation

	if selection_manager.is_moving and selection_manager.selected_furniture != null:
		preview_id = selection_manager.selected_furniture.item_id
		preview_size = FurnitureDatabase.get_size(preview_id)
		preview_rotation = selection_manager.selected_furniture.rotation_degrees_data

	var rotated_size: Vector2i = get_rotated_size(preview_size, preview_rotation)

	preview_valid = occupancy_manager.can_place_furniture(preview_id, cell, rotated_size)

	_update_preview_cells(cell, rotated_size, preview_valid)

	var preview_sprite := furniture_preview.get_node("Sprite2D") as Sprite2D
	if not is_rotating:
		preview_sprite.texture = FurnitureDatabase.get_texture_for_rotation(preview_id, preview_rotation)
		preview_sprite.flip_h = preview_rotation == 180 or preview_rotation == 270
		preview_sprite.position = IsoGrid.get_footprint_center(rotated_size)
		if preview_shadow:
			preview_shadow.texture = preview_sprite.texture
			preview_shadow.flip_h = preview_sprite.flip_h
			preview_shadow.position = preview_sprite.position + Vector2(4, -2)
	preview_sprite.modulate = Color(0, 1, 0, 0.5) if preview_valid else Color(1, 0, 0, 0.5)

	var name_label := furniture_preview.get_node_or_null("NameLabel") as Label
	if name_label:
		var data: Dictionary = FurnitureDatabase.get_item(preview_id)
		name_label.text = data.get("display_name", preview_id)

	_update_move_ghost()


func _update_preview_cells(origin: Vector2i, size: Vector2i, is_valid: bool) -> void:
	for child in preview_cells.get_children():
		child.queue_free()

	var origin_world: Vector2 = IsoGrid.grid_to_world(origin)
	var cells: Array[Vector2i] = occupancy_manager.get_cells_for_furniture(origin, size)
	var color := Color(0, 1, 0, 0.35) if is_valid else Color(1, 0, 0, 0.35)
	var border_color := Color(0, 1, 0, 0.7) if is_valid else Color(1, 0, 0, 0.7)

	for cell in cells:
		var fill_sprite := Sprite2D.new()
		fill_sprite.texture = grid_debug.texture
		fill_sprite.centered = true
		fill_sprite.position = IsoGrid.grid_to_world(cell) - origin_world
		fill_sprite.z_index = -10
		fill_sprite.modulate = color
		preview_cells.add_child(fill_sprite)

		var border_sprite := Sprite2D.new()
		border_sprite.texture = grid_debug.texture
		border_sprite.centered = true
		border_sprite.position = fill_sprite.position
		border_sprite.z_index = -9
		border_sprite.scale = Vector2(1.08, 1.08)
		border_sprite.modulate = border_color
		preview_cells.add_child(border_sprite)


func update_selected_cells_display() -> void:
	clear_selected_cells()

	if selection_manager.selected_furniture == null:
		return

	var origin: Vector2i = selection_manager.selected_furniture.grid_position
	var size: Vector2i = selection_manager.selected_furniture.grid_size
	var is_valid := true

	if selection_manager.is_moving:
		origin = IsoGrid.world_to_grid(furniture_root.get_global_mouse_position())
		var base_size: Vector2i = FurnitureDatabase.get_size(selection_manager.selected_furniture.item_id)
		size = get_rotated_size(base_size, selection_manager.selected_furniture.rotation_degrees_data)
		is_valid = occupancy_manager.can_place_furniture(selection_manager.selected_furniture.item_id, origin, size)

	var cells: Array[Vector2i] = occupancy_manager.get_cells_for_furniture(origin, size)
	var color := Color(0, 1, 0, 0.55) if is_valid else Color(1, 0, 0, 0.55)

	for cell in cells:
		var cell_sprite := Sprite2D.new()
		cell_sprite.texture = grid_debug.texture
		cell_sprite.centered = true
		cell_sprite.global_position = IsoGrid.grid_to_world(cell)
		cell_sprite.z_index = int(cell_sprite.global_position.y) - 5
		cell_sprite.modulate = color
		selected_cells_root.add_child(cell_sprite)


func clear_selected_cells() -> void:
	if selected_cells_root == null:
		return
	for child in selected_cells_root.get_children():
		child.queue_free()


func place_furniture(cell: Vector2i) -> bool:
	var rotated_size: Vector2i = get_rotated_size(current_furniture_size, current_rotation)

	if not occupancy_manager.can_place_furniture(current_furniture_id, cell, rotated_size):
		print("NO SE PUEDE COLOCAR: ", current_furniture_id, " CELL: ", cell, " SIZE: ", rotated_size)
		return false

	var furniture := FURNITURE_ITEM_SCENE.instantiate()
	furniture_root.add_child(furniture)
	furniture.setup(current_furniture_id, cell, current_rotation, rotated_size)

	occupancy_manager.occupy_furniture_cells(furniture)
	navigation_manager.rebuild_blockers(furniture_root)
	save_manager.save_decorations(_get_save_data())

	furniture_placed.emit(furniture, cell)
	return true


func handle_click(cell: Vector2i) -> void:
	if selection_manager.is_moving and selection_manager.selected_furniture != null:
		_confirm_move(cell)
		return

	var rotated_size: Vector2i = get_rotated_size(current_furniture_size, current_rotation)

	if occupancy_manager.can_place_furniture(current_furniture_id, cell, rotated_size):
		place_furniture(cell)
		return

	var clicked: Node = occupancy_manager.get_top_furniture_at_cell(cell)
	if clicked != null:
		selection_manager.select_existing(clicked)


func _confirm_move(cell: Vector2i) -> void:
	if selection_manager.selected_furniture == null:
		return

	var item_id: String = selection_manager.selected_furniture.item_id
	var rotation_data: int = selection_manager.selected_furniture.rotation_degrees_data
	var base_size: Vector2i = FurnitureDatabase.get_size(item_id)
	var rotated_size: Vector2i = get_rotated_size(base_size, rotation_data)

	if not occupancy_manager.can_place_furniture(item_id, cell, rotated_size):
		print("NO SE PUEDE MOVER A: ", cell)
		return

	selection_manager.selected_furniture.move_to_grid(cell, rotation_data, rotated_size)
	occupancy_manager.occupy_furniture_cells(selection_manager.selected_furniture)
	selection_manager.is_moving = false

	navigation_manager.rebuild_blockers(furniture_root)
	save_manager.save_decorations(_get_save_data())
	print("MUEBLE MOVIDO: ", item_id, " A ", cell)


func rotate_preview() -> void:
	var target_rotation: int = current_rotation + 90
	if target_rotation >= 360:
		target_rotation = 0

	var preview_sprite := furniture_preview.get_node("Sprite2D") as Sprite2D
	if not preview_sprite:
		current_rotation = target_rotation
		rotation_changed.emit(current_rotation)
		return

	if rotation_tween and rotation_tween.is_valid():
		rotation_tween.kill()

	preview_sprite.rotation = 0.0
	is_rotating = true

	rotation_tween = create_tween()
	rotation_tween.set_trans(Tween.TRANS_SINE)
	rotation_tween.set_ease(Tween.EASE_IN_OUT)
	rotation_tween.tween_property(preview_sprite, "rotation", deg_to_rad(-90), 0.12)
	rotation_tween.tween_callback(func():
		preview_sprite.rotation = 0.0
		current_rotation = target_rotation
		is_rotating = false
		rotation_changed.emit(current_rotation)
		print("DIRECTION: ", current_rotation))


func get_rotated_size(size: Vector2i, rotation: int) -> Vector2i:
	return Vector2i(size.y, size.x) if rotation == 90 or rotation == 270 else size


func _get_save_data() -> Array:
	var data: Array = []
	for furniture in furniture_root.get_children():
		if furniture.has_method("to_save_data"):
			data.append(furniture.to_save_data())
	return data


func _update_move_ghost() -> void:
	if selection_manager.is_moving and selection_manager.selected_furniture != null:
		if move_ghost_sprite == null:
			move_ghost_sprite = Sprite2D.new()
			move_ghost_sprite.name = "MoveGhost"
			furniture_root.add_child(move_ghost_sprite)

		var ghost_id: String = selection_manager.selected_furniture.item_id
		var ghost_pos: Vector2i = selection_manager.move_original_position
		var ghost_rot: int = selection_manager.move_original_rotation

		move_ghost_sprite.texture = FurnitureDatabase.get_texture_for_rotation(ghost_id, ghost_rot)
		move_ghost_sprite.global_position = IsoGrid.grid_to_world(ghost_pos)
		move_ghost_sprite.modulate = Color(1, 1, 1, 0.3)
		move_ghost_sprite.flip_h = ghost_rot == 180 or ghost_rot == 270
		move_ghost_sprite.z_index = int(move_ghost_sprite.global_position.y) - 1
		move_ghost_sprite.visible = true
	else:
		_clear_move_ghost()


func _clear_move_ghost() -> void:
	if move_ghost_sprite != null:
		move_ghost_sprite.queue_free()
		move_ghost_sprite = null