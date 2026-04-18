class_name CipheredSignal extends Node

signal on_render


func _render() -> void:
	on_render.emit()
