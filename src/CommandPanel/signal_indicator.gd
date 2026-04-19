class_name SignalIndicator
extends Control

@export var is_searching: bool = false
@export var value: int = 3

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
		progress_bar.value = index
		progress_bar_mask.value = index_mask
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
