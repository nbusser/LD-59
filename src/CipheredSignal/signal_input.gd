class_name SignalInput
extends Node

signal signal_input_changed(value: float)

const MIN_VALUE: float = 0.0
const MAX_VALUE: float = 1.0
const STEP: float = 0.01
const N_VALUES: int = int((MAX_VALUE - MIN_VALUE) / STEP) + 1

# 0.0 -> 1.0
var amount: float = 0.5:
	get():
		return amount
	set(new_amount):
		amount = new_amount
		emit_signal("signal_input_changed", amount)

@onready var _slider = $VSlider


func _on_v_slider_value_changed(value: float) -> void:
	amount = value


# When the level is loaded, we want to notify the cipher about the default slider value
func _on_level_new_cipher_loaded(_cipher_data: CipherData):
	_on_v_slider_value_changed(_slider.value)


func _ready() -> void:
	_slider.min_value = MIN_VALUE
	_slider.max_value = MAX_VALUE
	_slider.step = STEP

	var prng = RandomNumberGenerator.new()
	prng.seed = name.hash()
	_slider.value = prng.randf() * (MAX_VALUE - MIN_VALUE) + MIN_VALUE


func set_enable(enabled: bool) -> void:
	_slider.editable = enabled
