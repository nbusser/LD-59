class_name BinarySignalInput
extends Control

signal signal_input_changed(value: bool)

const MIN_VALUE: float = 0.0
const MAX_VALUE: float = 1.0
const STEP: float = 0.01
const N_VALUES: int = int((MAX_VALUE - MIN_VALUE) / STEP) + 1

@export var correct_value_threshold: float = 0.05

var correct_value = false

var value: bool = false:
	set(new_value):
		value = new_value
		emit_signal("signal_input_changed", value)

@onready var ok_label = $OkLabel
@onready var _check_button = $CheckButton


func _on_check_button_toggled(toggled_on: bool) -> void:
	value = toggled_on


# When the level is loaded, we want to notify the cipher about the default slider value
func _on_level_new_cipher_loaded(_cipher_data: CipherData):
	_on_check_button_toggled(_check_button.toggled)


func _ready() -> void:
	var prng = RandomNumberGenerator.new()
	prng.seed = name.hash()


func set_enable(enabled: bool) -> void:
	_check_button.editable = enabled


func trigger_update() -> void:
	emit_signal("signal_input_changed", value)


func is_value_correct() -> bool:
	return correct_value == value


func _process(_delta: float) -> void:
	ok_label.visible = is_value_correct()
