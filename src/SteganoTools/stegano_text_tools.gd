class_name SteganoTextTools extends Control

@onready var _sheet = $HoleySheet
@onready var _start_position_sheet: Vector2 = _sheet.position


func init():
	pass


func toggle_tools(enabled: bool) -> void:
	visible = enabled
	_sheet.visible = enabled
	if not enabled and is_node_ready():
		_sheet.position = _start_position_sheet


func _process(_delta: float):
	pass
