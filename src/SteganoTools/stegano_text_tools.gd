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


func _ready() -> void:
	_setup_holey_sheets()


func _process(_delta: float):
	pass


func _setup_holey_sheets():
	var children: Array[HoleySheet] = []
	children.append_array(get_children())
	var ciphers: Array[CipherData] = Globals.current_level.level_state.level_data.ciphers.filter(
		func(cipher: CipherData):
			return (
				cipher.cipher_type == CipherData.CipherType.TEXT
				and cipher.hidden_text_content != null
				and cipher.hidden_text_content.length() > 0
			)
	)

	for i in children.size():
		var child = children[i]
		if i < ciphers.size():
			child.cipher_data = ciphers[i]
		else:
			child.hide()
