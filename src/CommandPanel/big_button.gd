class_name BigButton
extends Control

signal pressed

@export var texture: Texture2D

@export var disabled = false:
	set(value):
		disabled = value
		if value:
			_is_open = false
			cover_button.disabled = true
			real_button.disabled = true
		else:
			cover_button.disabled = false
			real_button.disabled = false

var _is_open = false:
	set(value):
		_is_open = value
		if value:
			cover_button.hide()
			cover_up.show()
		else:
			cover_button.show()
			cover_up.hide()

@onready var cover_button: TextureButton = %CoverButton
@onready var real_button: TextureButton = %RealButton
@onready var cover_up: TextureRect = %CoverUp


func _on_real_button_mouse_exited() -> void:
	_is_open = false


func _on_real_button_button_down() -> void:
	pressed.emit()
	_is_open = false


func _on_cover_button_button_down() -> void:
	_is_open = true


func _ready() -> void:
	real_button.texture_normal = texture
