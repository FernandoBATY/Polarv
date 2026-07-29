extends Node
class_name NavigationManager

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")
const NAV_BLOCKER_GROUP_NAME: String = "nav_blockers"

@export var navigation_blocker_margin: float = 10.0

var rebake_pending: bool = false

var navigation_region: NavigationRegion2D
var navigation_blockers: Node2D


func _ready() -> void:
	var p = get_parent()
	if p:
		navigation_region = p.get_node("NavigationRegion2D")
		navigation_blockers = p.get_node("NavigationBlockers")


func rebuild_blockers(furniture_root: Node2D) -> void:
	if navigation_blockers == null:
		return

	for child in navigation_blockers.get_children():
		child.queue_free()

	for furniture in furniture_root.get_children():
		if not furniture.has_method("to_save_data"):
			continue

		if not FurnitureDatabase.blocks_movement(furniture.item_id):
			continue

		_create_blocker_for_furniture(furniture)

	_request_rebake()


func _create_blocker_for_furniture(furniture: Node) -> void:
	var blocker := StaticBody2D.new()
	blocker.name = "NavBlocker_%s" % furniture.item_id
	blocker.add_to_group(NAV_BLOCKER_GROUP_NAME)

	var collision := CollisionPolygon2D.new()
	collision.polygon = _get_blocker_polygon(
		furniture.grid_position,
		furniture.grid_size
	)

	blocker.add_child(collision)
	navigation_blockers.add_child(blocker)


func _get_blocker_polygon(origin: Vector2i, size: Vector2i) -> PackedVector2Array:
	var top: Vector2 = IsoGrid.grid_to_world(origin)
	var right: Vector2 = IsoGrid.grid_to_world(origin + Vector2i(size.x, 0))
	var bottom: Vector2 = IsoGrid.grid_to_world(origin + Vector2i(size.x, size.y))
	var left: Vector2 = IsoGrid.grid_to_world(origin + Vector2i(0, size.y))

	var center: Vector2 = (top + right + bottom + left) / 4.0

	top = _push_away_from_center(top, center, navigation_blocker_margin)
	right = _push_away_from_center(right, center, navigation_blocker_margin)
	bottom = _push_away_from_center(bottom, center, navigation_blocker_margin)
	left = _push_away_from_center(left, center, navigation_blocker_margin)

	return PackedVector2Array([top, right, bottom, left])


func _push_away_from_center(point: Vector2, center: Vector2, amount: float) -> Vector2:
	var direction: Vector2 = point - center

	if direction.length() <= 0.01:
		return point

	return point + direction.normalized() * amount


func _request_rebake() -> void:
	if navigation_region == null:
		return

	if rebake_pending:
		return

	rebake_pending = true
	call_deferred("_rebake")


func _rebake() -> void:
	rebake_pending = false

	if navigation_region == null:
		return

	if navigation_region.navigation_polygon == null:
		print("ERROR: NavigationRegion2D no tiene NavigationPolygon.")
		return

	navigation_region.bake_navigation_polygon(false)

	await get_tree().process_frame

	NavigationServer2D.map_force_update(navigation_region.get_world_2d().navigation_map)

	print("NAVIGATION REBAKED AND FORCED")