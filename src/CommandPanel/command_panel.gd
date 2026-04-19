class_name CommandPanel extends Control

signal cipher_type_selected(cipher_type: CipherData.CipherType)

var level_state: LevelState
var _current_cipher_type: CipherData.CipherType:
	set(value):
		_current_cipher_type = value
		match value:
			CipherData.CipherType.TEXT:
				_make_inputs_enabled(text_signal_inputs, true)
				_make_inputs_enabled(image_signal_inputs, false)
				_make_inputs_enabled(audio_signal_inputs, false)
			CipherData.CipherType.IMAGE:
				_make_inputs_enabled(text_signal_inputs, false)
				_make_inputs_enabled(image_signal_inputs, true)
				_make_inputs_enabled(audio_signal_inputs, false)
			CipherData.CipherType.AUDIO:
				_make_inputs_enabled(text_signal_inputs, false)
				_make_inputs_enabled(image_signal_inputs, false)
				_make_inputs_enabled(audio_signal_inputs, true)
		emit_signal("cipher_type_selected", value)

@onready var text_signal_inputs: Node = $TextInputs
@onready var image_signal_inputs: Node = $ImageInputs
@onready var audio_signal_inputs: Node = $AudioInputs

@onready var signal_indicator: SignalIndicator = $SignalIndicator


func init(_level_state: LevelState) -> void:
	level_state = _level_state


func _ready() -> void:
	_on_text_pressed()


func _make_inputs_enabled(group: Node, enabled: bool) -> void:
	for input in group.get_children() as Array[SignalInput]:
		input.set_enable(enabled)


func _get_active_inputs() -> Array[SignalInput]:
	var nodes: Array[SignalInput] = []
	match _current_cipher_type:
		CipherData.CipherType.TEXT:
			nodes.append_array(text_signal_inputs.get_children())
		CipherData.CipherType.IMAGE:
			nodes.append_array(image_signal_inputs.get_children())
		CipherData.CipherType.AUDIO:
			nodes.append_array(audio_signal_inputs.get_children())
	return nodes


func _on_text_pressed() -> void:
	_current_cipher_type = CipherData.CipherType.TEXT


func _on_image_pressed() -> void:
	_current_cipher_type = CipherData.CipherType.IMAGE


func _on_audio_pressed() -> void:
	_current_cipher_type = CipherData.CipherType.AUDIO


func _on_level_deciphering_started_stopped(started: bool) -> void:
	for button in $SignalTypeButtons.get_children() as Array[Button]:
		button.disabled = not started

	if started:
		_on_text_pressed()
	else:
		_make_inputs_enabled(text_signal_inputs, false)
		_make_inputs_enabled(image_signal_inputs, false)
		_make_inputs_enabled(audio_signal_inputs, false)


func get_signal_quality() -> float:
	if !level_state:
		return 0.0

	if _current_cipher_type != level_state.current_cipher.cipher_type:
		return 0.0

	return _get_active_inputs().reduce(
		func(quality: float, input: SignalInput): return quality * input.get_quality(), 1.0
	)


func _process(_delta: float) -> void:
	signal_indicator.set_value_f(pow(get_signal_quality(), 3.0))
