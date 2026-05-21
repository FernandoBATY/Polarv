class_name IsoGrid
extends RefCounted

const TILE_WIDTH: float = 128.0
const TILE_HEIGHT: float = 64.0
const HALF_WIDTH: float = TILE_WIDTH / 2.0
const HALF_HEIGHT: float = TILE_HEIGHT / 2.0

static func grid_to_world(cell: Vector2i) -> Vector2:
	var x := float(cell.x)
	var y := float(cell.y)

	return Vector2(
		(x - y) * HALF_WIDTH,
		(x + y) * HALF_HEIGHT
	)

static func world_to_grid(world_position: Vector2) -> Vector2i:
	var gx := (world_position.x / HALF_WIDTH + world_position.y / HALF_HEIGHT) / 2.0
	var gy := (world_position.y / HALF_HEIGHT - world_position.x / HALF_WIDTH) / 2.0

	return Vector2i(roundi(gx), roundi(gy))
