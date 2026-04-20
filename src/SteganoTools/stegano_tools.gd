class_name SteganoTools extends Control

@onready var _text_tools = $TextFilters
@onready var _image_tools = $ImageFilters

@onready var _glasses: TextureRect = %Glasses
@onready var _glasses_hover: TextureRect = %GlassesHover


func _is_stegano_image() -> bool:
	return (
		Globals.current_level.level_state.phase == LevelState.Phase.STEGANO
		and Globals.get_current_cipher().cipher_type == CipherData.CipherType.IMAGE
	)


func _ready():
	# visible = false
	_on_command_panel_cipher_type_selected(Globals.display_mode)
	_glasses_hover.hide()

	_text_tools.init.call_deferred()
	_image_tools.init.call_deferred()

	Globals.glasses_state_changed.connect(_on_glasses_state_changed)


func _on_level_phase_changed(phase: LevelState.Phase) -> void:
	pass


func _on_command_panel_cipher_type_selected(cipher_type: CipherData.CipherType) -> void:
	if not is_node_ready():
		return
	# match cipher_type:
	# 	CipherData.CipherType.TEXT:
	# 		_text_tools.toggle_tools(true)
	# 		_image_tools.toggle_tools(false)
	# 	CipherData.CipherType.IMAGE:
	# 		_text_tools.toggle_tools(false)
	# 		_image_tools.toggle_tools(true)
	# 	CipherData.CipherType.AUDIO:
	# 		_text_tools.toggle_tools(false)
	# 		_image_tools.toggle_tools(false)


func _process(_delta: float):
	pass


func _on_glasses_state_changed(active: bool):
	if active:
		_glasses.hide()
		_glasses_hover.hide()
	else:
		_glasses.show()


func _on_glasses_button_button_down() -> void:
	Globals.toggle_glasses()


func _on_glasses_button_mouse_exited() -> void:
	_glasses_hover.hide()


func _on_glasses_button_mouse_entered() -> void:
	if !Globals.glasses_active:
		_glasses_hover.show()
