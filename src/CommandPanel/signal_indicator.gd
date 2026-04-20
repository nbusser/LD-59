class_name SignalIndicator
extends Control

@export var is_searching: bool = false
@export var value: int = 3
@export var color: Color = Color.RED:
	set(value):
		color = value
		_update_color.call_deferred()

var _min_value = 0:
	set(value):
		_min_value = value
		_update_lights.call_deferred()

var _max_value = 0:
	set(value):
		_max_value = value
		_update_lights.call_deferred()

@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var progress_bar_mask: TextureProgressBar = $ProgressBarMask


func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec()
	var max_value = int(progress_bar.max_value)
	if is_searching:
		var index: int = clampi(
			int(Utils.map_triangle(fmod(time / 800.0, 1.0), 0.5) * max_value) + 1, 1, max_value
		)
		var index_mask: int = (max_value + index - 1) % max_value
		_min_value = index_mask
		_max_value = index
	else:
		var jitter = round(
			(
				sin(
					(
						(
							time / 953.0
							+ fmod(time + 1e4, 9463.34) / 277
							+ fmod(time + 1e3, 51532.23) / 103
						)
						/ 5.0
					)
				)
				* 1.5
			)
		)
		progress_bar.value = clampi(value + jitter, 0, max_value)
		progress_bar_mask.value = 0


func set_value_f(value_f: float) -> int:
	value = int(value_f * progress_bar.max_value)
	return value


func _update_color():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", color, 0.1)


func _update_lights():
	progress_bar_mask.value = _min_value
	progress_bar.value = _max_value


func _ready() -> void:
	_update_color()
