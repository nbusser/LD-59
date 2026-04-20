class_name SteganoTools extends Control

@onready var _text_tools = $TextFilters
@onready var _image_tools = $ImageFilters


func _is_stegano_image() -> bool:
	return (
		Globals.current_level.level_state.phase == LevelState.Phase.STEGANO
		and Globals.get_current_cipher().cipher_type == CipherData.CipherType.IMAGE
	)


func _ready():
	visible = false
	_on_command_panel_cipher_type_selected(Globals.display_mode)


func _on_level_phase_changed(phase: LevelState.Phase) -> void:
	# Phase system is unused now
	match phase:
		LevelState.Phase.STEGANO:
			visible = true
			_text_tools.init()
			_image_tools.init()
		_:
			visible = false


func _on_command_panel_cipher_type_selected(cipher_type: CipherData.CipherType) -> void:
	if not is_node_ready():
		return
	match cipher_type:
		CipherData.CipherType.TEXT:
			_text_tools.toggle_tools(true)
			_image_tools.toggle_tools(false)
		CipherData.CipherType.IMAGE:
			_text_tools.toggle_tools(false)
			_image_tools.toggle_tools(true)
		CipherData.CipherType.AUDIO:
			_text_tools.toggle_tools(false)
			_image_tools.toggle_tools(false)


func _process(_delta: float):
	pass
