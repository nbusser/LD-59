class_name Draggable extends Node

const SCALE_DROPPED = 0.6
const ANIMATION_DURATION = 0.1

var controllable := true:
	get:
		return controllable
	set(value):
		controllable = value
		if value == false and _dragging:
			_release()

var _dragging := false
var _hovered := false

var tween: Tween

@onready var parent: Control = get_parent()


func _release():
	Globals.dragged_object = null
	_dragging = false
	tween = get_tree().create_tween()
	tween.parallel().tween_property(
		parent, "scale", Vector2.ONE * SCALE_DROPPED, ANIMATION_DURATION
	)
	tween.parallel().tween_property(
		parent,
		"global_position",
		parent.global_position + parent.get_size() * SCALE_DROPPED / 4,
		ANIMATION_DURATION
	)
	tween.parallel().tween_property(
		parent, "rotation_degrees", randf_range(-1, 1) * 10, ANIMATION_DURATION
	)
	parent.z_index = 0


func _catch():
	Globals.dragged_object = parent
	_dragging = true
	tween = get_tree().create_tween()
	tween.parallel().tween_property(parent, "scale", Vector2.ONE, ANIMATION_DURATION)
	# tween.tween_property(parent, "global_position", parent.global_position +parent.get_size() * SCALE_DROPPED / 4, ANIMATION_DURATION)
	tween.parallel().tween_property(parent, "rotation_degrees", 0, ANIMATION_DURATION)
	parent.z_index = 100


func _ready() -> void:
	parent.mouse_entered.connect(_on_mouse_entered)
	parent.mouse_exited.connect(_on_mouse_exited)
	_release()


func _input(event):
	if not controllable:
		return

	if event is InputEventMouseButton:
		if event.pressed:
			if _dragging:
				_release()
			elif _hovered and Globals.dragged_object == null:
				_catch()


func _process(_delta: float):
	if _dragging:
		parent.global_position = get_viewport().get_mouse_position() - (parent.get_size() / 2)


func _on_mouse_entered():
	_hovered = true


func _on_mouse_exited():
	_hovered = false
