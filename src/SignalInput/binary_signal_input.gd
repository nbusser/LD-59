class_name BinarySignalInput
extends Control

signal signal_input_changed(value: bool)

var correct_value = false

var value: bool = false:
	set(new_value):
		value = new_value
		_update_render()
		emit_signal("signal_input_changed", value)

@onready var _button = %Button
@onready var _texture_rect = %TextureRect


# When the level is loaded, we want to notify the cipher about the default slider value
func _on_level_new_cipher_loaded(_cipher_data: CipherData):
	value = false


func _ready() -> void:
	var prng = RandomNumberGenerator.new()
	prng.seed = name.hash()

	_update_render()


func set_enable(enabled: bool) -> void:
	_button.disabled = not enabled


func trigger_update() -> void:
	emit_signal("signal_input_changed", value)


func _update_render():
	_texture_rect.flip_h = value


func _on_button_button_down() -> void:
	value = !value
