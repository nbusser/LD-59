extends Node

class_name CipheredSignal

var _rot_input: SignalInput
var _rot_scale: int = 25
var _rot_random_offset: float = randf()

var source: String = ""

var _transformed_text: String = ""

var letter_rot: 
    get(): return letter_rot
    set(rot):
        letter_rot = rot
        render()

func _ready() -> void:
    _rot_input.signal_input_changed.connect(_rot_input_changed)

func _rot_input_changed(value: float) -> void:
    var rot_value = int(value * _rot_scale + _rot_random_offset)
    letter_rot = rot_value
    print("Rot input: {value} new value {rot_value}")

func render() -> String:
    # Apply rot25
    return _transformed_text
