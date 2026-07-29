extends CanvasLayer

signal furniture_selected(furniture_id: String)
signal inventory_button_pressed

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")
const FURNITURE_SLOT_SCENE: PackedScene = preload("res://scenes/ui/FurnitureSlot.tscn")

@onready var inventory_button: Button = $InventoryButton
@onready var window_base: WindowBase = $WindowBase
@onready var grid_container: GridContainer = $WindowBase/WindowMargin/VBoxContainer/ContentContainer/ScrollContainer/GridContainer


func _ready() -> void:
	window_base.window_closed.connect(_on_window_closed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	build_inventory()


func build_inventory() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	for item_id: String in FurnitureDatabase.ITEMS.keys():
		var item_data: Dictionary = FurnitureDatabase.get_item(item_id)
		var slot := FURNITURE_SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		slot.setup(item_id, item_data)
		slot.furniture_selected.connect(_on_slot_furniture_selected)


func _on_inventory_button_pressed() -> void:
	inventory_button_pressed.emit()
	if window_base.visible:
		close()
	else:
		open()


func open() -> void:
	window_base.open("Inventario")
	inventory_button.visible = false


func close() -> void:
	window_base.close()


func toggle() -> void:
	if window_base.visible:
		close()
	else:
		open()


func is_open() -> bool:
	return window_base.visible


func _on_window_closed() -> void:
	inventory_button.visible = true


func _on_slot_furniture_selected(furniture_id: String) -> void:
	furniture_selected.emit(furniture_id)
	close()