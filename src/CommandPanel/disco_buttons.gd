extends Control

signal disco_button_pressed(is_disco: bool)


func _on_positive_button_pressed() -> void:
	disco_button_pressed.emit(true)


func _on_negative_button_pressed() -> void:
	disco_button_pressed.emit(false)
