extends CharacterBody2D

@export var speed: float = 220.0

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
			var mouse_position: Vector2 = get_global_mouse_position()
			var target_cell: Vector2i = IsoGrid.world_to_grid(mouse_position)
			var snapped_target: Vector2 = IsoGrid.grid_to_world(target_cell)

			navigation_agent.target_position = snapped_target


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
