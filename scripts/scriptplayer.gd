extends CharacterBody2D

@export var speed: float = 220.0
@export var stop_distance: float = 2.0

var target_position: Vector2
var can_move_by_click: bool = true


func _ready() -> void:
	target_position = global_position


func set_movement_enabled(value: bool) -> void:
	can_move_by_click = value

	if not can_move_by_click:
		target_position = global_position


func _input(event: InputEvent) -> void:
	if not can_move_by_click:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position: Vector2 = get_global_mouse_position()
		var target_cell: Vector2i = IsoGrid.world_to_grid(mouse_position)

		var parent_node := get_parent()

		if parent_node != null and parent_node.has_method("is_cell_blocked_for_movement"):
			if parent_node.is_cell_blocked_for_movement(target_cell):
				print("MOVIMIENTO BLOQUEADO EN CELDA: ", target_cell)
				return

		target_position = mouse_position


func _physics_process(delta: float) -> void:
	var direction: Vector2 = target_position - global_position

	if direction.length() > stop_distance:
		global_position += direction.normalized() * speed * delta
	else:
		global_position = target_position
