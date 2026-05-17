extends Node2D

@onready var player: CharacterBody2D = $Player

func _process(_delta: float) -> void:
	if player:
		player.z_index = int(player.global_position.y)
