extends Node
class_name SelectionManager

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

var selected_furniture: Node = null
var is_moving: bool = false
var move_original_position: Vector2i = Vector2i.ZERO
var move_original_rotation: int = 0
var move_original_size: Vector2i = Vector2i(2, 2)

signal furniture_selected(furniture: Node)
signal furniture_deselected()
signal move_started(furniture: Node, original_pos: Vector2i)
signal move_confirmed(furniture: Node, new_cell: Vector2i)
signal move_cancelled(furniture: Node)
signal furniture_deleted(furniture: Node)


func select_existing(furniture: Node) -> void:
	if selected_furniture != null and selected_furniture != furniture:
		selected_furniture.set_selected(false)

	selected_furniture = furniture
	selected_furniture.set_selected(true)
	is_moving = false

	furniture_selected.emit(furniture)


func select_new(furniture_id: String) -> void:
	if not FurnitureDatabase.has_item(furniture_id):
		print("ERROR: MUEBLE NO EXISTE EN DATABASE: ", furniture_id)
		return

	if selected_furniture != null:
		selected_furniture.set_selected(false)

	selected_furniture = null
	is_moving = false

	furniture_selected.emit(null)


func deselect() -> void:
	if selected_furniture != null:
		selected_furniture.set_selected(false)

	selected_furniture = null
	is_moving = false

	furniture_deselected.emit()


func start_move() -> bool:
	if selected_furniture == null:
		print("NO HAY MUEBLE SELECCIONADO")
		return false

	is_moving = true
	move_original_position = selected_furniture.grid_position
	move_original_rotation = selected_furniture.rotation_degrees_data
	move_original_size = selected_furniture.grid_size

	move_started.emit(selected_furniture, move_original_position)
	return true


func confirm_move() -> void:
	is_moving = false
	move_confirmed.emit(selected_furniture, selected_furniture.grid_position)


func cancel_move() -> void:
	if not is_moving:
		return

	is_moving = false
	move_cancelled.emit(selected_furniture)


func get_rotation_for_move() -> int:
	if selected_furniture == null:
		return 0

	var new_rotation: int = selected_furniture.rotation_degrees_data + 90
	if new_rotation >= 360:
		new_rotation = 0

	return new_rotation


func delete_selected() -> bool:
	if selected_furniture == null:
		print("NO HAY MUEBLE SELECCIONADO")
		return false

	var furniture := selected_furniture

	if not is_moving:
		furniture_deleted.emit(furniture)

	furniture.queue_free()

	selected_furniture = null
	is_moving = false

	return true


func can_rotate_for_move() -> bool:
	return selected_furniture != null and is_moving