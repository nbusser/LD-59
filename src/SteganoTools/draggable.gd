class_name Draggable extends Node

var controllable := true:
	get:
		return controllable
	set(value):
		controllable = value
		if value == false and _dragging:
			_release()

var _dragging := false
var _hovered := false

@onready var parent: TextureRect = get_parent()


func _release():
	Globals.dragged_object = null
	_dragging = false


func _catch():
	Globals.dragged_object = parent
	_dragging = true


func _ready() -> void:
	parent.mouse_entered.connect(_on_mouse_entered)
	parent.mouse_exited.connect(_on_mouse_exited)


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
