extends Node

var _window_stack: Array[WindowBase] = []
var _current_window: WindowBase = null

const WINDOW_BASE_SCENE: PackedScene = preload("res://scenes/ui/WindowBase.tscn")


func open_window(title: String, content_scene: PackedScene = preload("res://scenes/ui/WindowBase.tscn")) -> WindowBase:
	if _current_window:
		_current_window.close()
		_current_window = null

	var window: WindowBase = WINDOW_BASE_SCENE.instantiate()
	add_child(window)
	window.window_closed.connect(_on_window_closed.bind(window))
	window.open(title)
	_current_window = window
	_window_stack.append(window)
	return window


func close_current_window() -> void:
	if _current_window:
		_current_window.close()


func close_all_windows() -> void:
	for window in _window_stack:
		if is_instance_valid(window):
			window.queue_free()
	_window_stack.clear()
	_current_window = null


func _on_window_closed(window: WindowBase) -> void:
	_window_stack.erase(window)
	if window == _current_window:
		_current_window = null
	if is_instance_valid(window):
		window.queue_free()


func has_open_window() -> bool:
	return _current_window != null and _current_window.visible