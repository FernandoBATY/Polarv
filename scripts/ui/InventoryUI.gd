extends CanvasLayer

signal furniture_selected(furniture_id: String)
signal inventory_button_pressed

const FurnitureDatabase = preload("res://scripts/FurnitureDatabase.gd")
const FURNITURE_SLOT_SCENE: PackedScene = preload("res://scenes/ui/FurnitureSlot.tscn")

var current_filter: String = ""

@onready var inventory_button: Button = $InventoryButton
@onready var window_base: WindowBase = $WindowBase
@onready var category_filter: HBoxContainer = $WindowBase/WindowMargin/VBoxContainer/CategoryFilter
@onready var grid_container: GridContainer = $WindowBase/WindowMargin/VBoxContainer/ContentContainer/ScrollContainer/GridContainer


func _ready() -> void:
	window_base.window_closed.connect(_on_window_closed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	build_category_buttons()
	build_inventory()


func build_category_buttons() -> void:
	for child in category_filter.get_children():
		child.queue_free()

	var all_btn := Button.new()
	all_btn.text = "Todas"
	all_btn.pressed.connect(_on_filter_pressed.bind(""))
	all_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	category_filter.add_child(all_btn)

	for cat: String in FurnitureDatabase.get_categories():
		var btn := Button.new()
		btn.text = cat.capitalize()
		btn.pressed.connect(_on_filter_pressed.bind(cat))
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		category_filter.add_child(btn)


func _on_filter_pressed(category: String) -> void:
	current_filter = category
	build_inventory()


func build_inventory() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	var items

	if current_filter == "":
		items = FurnitureDatabase.ITEMS.keys()
	else:
		items = FurnitureDatabase.get_items_by_category(current_filter)

	for item_id: String in items:
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