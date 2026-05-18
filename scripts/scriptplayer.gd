extends CharacterBody2D

@export var speed: float = 220.0
@export var stop_distance: float = 2.0

var target_position: Vector2

func _ready():
	target_position = global_position

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		target_position = get_global_mouse_position()

func _physics_process(delta):
	var direction = target_position - global_position

	if direction.length() > stop_distance:
		global_position += direction.normalized() * speed * delta
	else:
		global_position = target_position
