extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var grid_debug: Sprite2D = $GridDebug

var last_cell: Vector2i = Vector2i(999999, 999999)

func _process(_delta: float) -> void:
	if player:
		player.z_index = int(player.global_position.y)

		var cell: Vector2i = IsoGrid.world_to_grid(player.global_position)
		var grid_world_position: Vector2 = IsoGrid.grid_to_world(cell)

		grid_debug.global_position = grid_world_position
		grid_debug.z_index = int(grid_debug.global_position.y) - 1

		#if cell != last_cell:
			#print("----------------")
			#print("PLAYER GLOBAL: ", player.global_position)
			#print("PLAYER CELL: ", cell)
			#print("GRID DEBUG GLOBAL: ", grid_debug.global_position)
			#print("GRID WORLD EXPECTED: ", grid_world_position)
			#last_cell = cell
