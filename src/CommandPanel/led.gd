class_name Led
extends Control

@export var enabled = true:
	set(value):
		enabled = value
		_update_render.call_deferred()

@onready var on: Control = %On
@onready var off: Control = %Off
@onready var light: PointLight2D = %PointLight2D


func _update_render():
	var tween = get_tree().create_tween()
	if enabled:
		tween.tween_property(on, "modulate", Color.WHITE, 0.1)
		tween.parallel().tween_property(light, "energy", 1.0, 0.1)
	else:
		tween.tween_property(on, "modulate", Color.TRANSPARENT, 0.1)
		tween.parallel().tween_property(light, "energy", 0.0, 0.1)


func _ready() -> void:
	_update_render()
	on.show()
