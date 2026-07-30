extends Node2D

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")

var block_next_decoration_click: bool = false
var decoration_mode: bool = true

var selected_cells_root: Node2D

@onready var player: CharacterBody2D = $Player
@onready var grid_debug: Sprite2D = $GridDebug
@onready var furniture_root: Node2D = $FurnitureRoot
@onready var furniture_preview: Node2D = $FurniturePreview
@onready var preview_cells: Node2D = $FurniturePreview/PreviewCells
@onready var inventory_ui: CanvasLayer = $InventoryUI
@onready var save_manager: SaveManager = $SaveManager
@onready var occupancy_manager: OccupancyManager = $OccupancyManager
@onready var navigation_manager = $NavigationManager
@onready var selection_manager = $SelectionManager
@onready var decoration_controller = $DecorationController
@onready var hud: HUD = $HUD


func _ready() -> void:
	selected_cells_root = Node2D.new()
	selected_cells_root.name = "SelectedCells"
	add_child(selected_cells_root)

	if inventory_ui and inventory_ui.has_signal("furniture_selected"):
		inventory_ui.furniture_selected.connect(_on_inventory_furniture_selected)

	if inventory_ui and inventory_ui.has_signal("inventory_button_pressed"):
		inventory_ui.inventory_button_pressed.connect(_on_inventory_button_pressed)

	decoration_controller.setup(furniture_root, furniture_preview, preview_cells,
		grid_debug, selected_cells_root, occupancy_manager, selection_manager,
		navigation_manager, save_manager)

	save_manager.load_and_place(save_manager.load_decorations_from_file(),
		furniture_root, occupancy_manager, selection_manager,
		navigation_manager, decoration_controller)
	decoration_controller.select_furniture(decoration_controller.current_furniture_id)
	set_decoration_mode(decoration_mode)
	navigation_manager.rebuild_blockers(furniture_root)


func _process(_delta: float) -> void:
	if player:
		player.z_index = int(player.global_position.y)

	update_grid_debug()

	if decoration_mode:
		decoration_controller.update_preview()
		decoration_controller.update_selected_cells_display()
		furniture_preview.visible = true
		selected_cells_root.visible = true
	else:
		furniture_preview.visible = false
		selected_cells_root.visible = false


func set_decoration_mode(value: bool) -> void:
	decoration_mode = value

	if player and player.has_method("set_movement_enabled"):
		player.set_movement_enabled(not decoration_mode)

	if decoration_mode:
		if player and player.has_method("set_movement_enabled"):
			player.set_movement_enabled(false)
	else:
		if selection_manager.is_moving:
			cancel_selection_or_move()

		if selection_manager.selected_furniture != null:
			selection_manager.selected_furniture.set_selected(false)
			selection_manager.selected_furniture = null

		decoration_controller.clear_selected_cells()

		if inventory_ui and inventory_ui.has_method("close"):
			inventory_ui.close()

	print("DECORATION MODE: ", decoration_mode)
	if hud:
		hud.set_deco_mode(decoration_mode)


func update_grid_debug() -> void:
	var cell: Vector2i = IsoGrid.world_to_grid(player.global_position)
	grid_debug.global_position = IsoGrid.grid_to_world(cell)
	grid_debug.z_index = int(grid_debug.global_position.y) - 1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_D:
			set_decoration_mode(not decoration_mode)

		if event.pressed and event.keycode == KEY_I:
			print("I PRESSED. DECORATION MODE: ", decoration_mode)
			if decoration_mode:
				if inventory_ui and inventory_ui.has_method("toggle"):
					inventory_ui.toggle()
				else:
					print("ERROR: InventoryUI no tiene metodo toggle().")
			else:
				print("INVENTARIO BLOQUEADO: primero entra a modo decoracion con D.")

		if event.pressed and event.keycode == KEY_R and decoration_mode:
			if selection_manager.is_moving and selection_manager.selected_furniture != null:
				rotate_selected_for_move()
			else:
				decoration_controller.rotate_preview()

		if event.pressed and event.keycode == KEY_M and decoration_mode:
			start_move_selected()

		if event.pressed and decoration_mode and (event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE):
			delete_selected_furniture()

		if event.pressed and event.keycode == KEY_ESCAPE and decoration_mode:
			cancel_selection_or_move()

		if event.pressed and event.keycode == KEY_P:
			print(save_manager.load_decorations_from_file())

	if event is InputEventMouseButton:
		if decoration_mode and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if block_next_decoration_click:
				block_next_decoration_click = false
				print("CLICK BLOQUEADO POR UI")
				return

			if inventory_ui and inventory_ui.has_method("is_open") and inventory_ui.is_open():
				print("CLICK BLOQUEADO POR INVENTARIO ABIERTO")
				return

			decoration_controller.handle_click(IsoGrid.world_to_grid(get_global_mouse_position()))


func _on_inventory_furniture_selected(furniture_id: String) -> void:
	block_next_decoration_click = true
	decoration_controller.select_furniture(furniture_id)


func _on_inventory_button_pressed() -> void:
	block_next_decoration_click = true


func start_move_selected() -> void:
	if selection_manager.selected_furniture == null:
		print("NO HAY MUEBLE SELECCIONADO")
		return

	selection_manager.is_moving = true
	selection_manager.move_original_position = selection_manager.selected_furniture.grid_position
	selection_manager.move_original_rotation = selection_manager.selected_furniture.rotation_degrees_data
	selection_manager.move_original_size = selection_manager.selected_furniture.grid_size

	occupancy_manager.free_furniture_cells(selection_manager.selected_furniture)
	print("MOVIENDO: ", selection_manager.selected_furniture.item_id)


func rotate_selected_for_move() -> void:
	if selection_manager.selected_furniture == null:
		return

	var new_rotation: int = selection_manager.selected_furniture.rotation_degrees_data + 90
	if new_rotation >= 360:
		new_rotation = 0

	var base_size: Vector2i = FurnitureDatabase.get_size(selection_manager.selected_furniture.item_id)
	var rotated_size: Vector2i = decoration_controller.get_rotated_size(base_size, new_rotation)

	selection_manager.selected_furniture.move_to_grid(
		selection_manager.selected_furniture.grid_position, new_rotation, rotated_size)


func cancel_selection_or_move() -> void:
	if selection_manager.is_moving and selection_manager.selected_furniture != null:
		selection_manager.selected_furniture.move_to_grid(
			selection_manager.move_original_position,
			selection_manager.move_original_rotation,
			selection_manager.move_original_size)

		occupancy_manager.occupy_furniture_cells(selection_manager.selected_furniture)
		selection_manager.is_moving = false
		navigation_manager.rebuild_blockers(furniture_root)
		print("MOVIMIENTO CANCELADO")
		return

	if selection_manager.selected_furniture != null:
		selection_manager.selected_furniture.set_selected(false)
		selection_manager.selected_furniture = null
		decoration_controller.clear_selected_cells()
		print("SELECCION CANCELADA")


func delete_selected_furniture() -> void:
	if selection_manager.selected_furniture == null:
		print("NO HAY MUEBLE SELECCIONADO")
		return

	var furniture = selection_manager.selected_furniture

	if selection_manager.is_moving:
		selection_manager.is_moving = false
	else:
		occupancy_manager.free_furniture_cells(furniture)

	selection_manager.selected_furniture = null
	decoration_controller.clear_selected_cells()

	print("MUEBLE BORRADO: ", furniture.item_id)

	if furniture.has_method("play_delete_animation"):
		furniture.play_delete_animation()
	else:
		furniture.queue_free()

	navigation_manager.rebuild_blockers(furniture_root)
	save_manager.save_decorations(save_manager.collect_save_data(furniture_root))