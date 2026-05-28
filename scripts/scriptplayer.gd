#scriptplayer.gd
extends CharacterBody2D

@export var speed: float = 220.0
@export var nearest_cell_search_radius: int = 8

var can_move_by_click: bool = true

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	navigation_agent.target_position = global_position


func set_movement_enabled(value: bool) -> void:
	can_move_by_click = value

	if not can_move_by_click:
		velocity = Vector2.ZERO
		navigation_agent.target_position = global_position


func _input(event: InputEvent) -> void:
	if not can_move_by_click:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			move_to_mouse()


func move_to_mouse() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var target_cell: Vector2i = IsoGrid.world_to_grid(mouse_position)

	var final_cell: Vector2i = get_valid_target_cell(target_cell)
	var snapped_target: Vector2 = IsoGrid.grid_to_world(final_cell)

	var navigation_map: RID = get_world_2d().navigation_map
	var safe_target: Vector2 = NavigationServer2D.map_get_closest_point(
		navigation_map,
		snapped_target
	)

	navigation_agent.target_position = safe_target


func get_valid_target_cell(target_cell: Vector2i) -> Vector2i:
	var parent_node := get_parent()

	if parent_node == null:
		return target_cell

	if not parent_node.has_method("is_cell_blocked_for_movement"):
		return target_cell

	if not parent_node.is_cell_blocked_for_movement(target_cell):
		return target_cell

	for radius in range(1, nearest_cell_search_radius + 1):
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				if abs(x) != radius and abs(y) != radius:
					continue

				var candidate := target_cell + Vector2i(x, y)

				if not parent_node.is_cell_blocked_for_movement(candidate):
					return candidate

	return target_cell


func _physics_process(_delta: float) -> void:
	if not can_move_by_click:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var direction: Vector2 = next_path_position - global_position

	if direction.length() < 2.0:
		velocity = Vector2.ZERO
	else:
		velocity = direction.normalized() * speed

	move_and_slide()
