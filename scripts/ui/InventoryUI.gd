extends CanvasLayer

signal furniture_selected(furniture_id: String)

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")
const FURNITURE_SLOT_SCENE: PackedScene = preload("res://scenes/ui/FurnitureSlot.tscn")

@onready var open_button: Button = $OpenButton
@onready var panel: Panel = $Panel
@onready var grid_container: GridContainer = $Panel/ScrollContainer/GridContainer


func _ready() -> void:
	panel.visible = false
	build_inventory()

	if not open_button.pressed.is_connected(toggle):
		open_button.pressed.connect(toggle)


func build_inventory() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	for item_id: String in FurnitureDatabase.ITEMS.keys():
		var item_data: Dictionary = FurnitureDatabase.get_item(item_id)

		var slot := FURNITURE_SLOT_SCENE.instantiate()
		grid_container.add_child(slot)

		slot.setup(item_id, item_data)
		slot.furniture_selected.connect(_on_slot_furniture_selected)


func open() -> void:
	panel.visible = true
	print("INVENTORY OPEN")


func close() -> void:
	panel.visible = false
	print("INVENTORY CLOSED")


func toggle() -> void:
	panel.visible = not panel.visible
	print("INVENTORY TOGGLE: ", panel.visible)


func _on_slot_furniture_selected(furniture_id: String) -> void:
	furniture_selected.emit(furniture_id)
	close()
