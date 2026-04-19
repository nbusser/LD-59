class_name CipheredSignal extends Node

signal on_render


func _render() -> void:
	on_render.emit()


func set_focused(_focus: bool) -> void:
	# Some derivate may want to do something when "focused"
	pass
