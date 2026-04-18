extends Node

class_name CipheredSignal

signal on_render()

func _render() -> void:
	on_render.emit()
