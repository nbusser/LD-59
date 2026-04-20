class_name CommandPanel extends Control

signal cipher_type_selected(cipher_type: CipherData.CipherType)

const MAX_QUALITY_WHEN_INCORRECT = 0.9

var level_state: LevelState
var _smoothed_signal_quality: float = 0.0
var _current_cipher_type: CipherData.CipherType:
	get():
		return Globals.display_mode
	set(value):
		Globals.display_mode = value
		_current_cipher_type = value
		match value:
			CipherData.CipherType.TEXT:
				_make_inputs_enabled(text_signal_inputs, true)
				_make_inputs_enabled(image_signal_inputs, false)
				_make_inputs_enabled(audio_signal_inputs, false)
				text_mode_button.button_pressed = true
			CipherData.CipherType.IMAGE:
				_make_inputs_enabled(text_signal_inputs, false)
				_make_inputs_enabled(image_signal_inputs, true)
				_make_inputs_enabled(audio_signal_inputs, false)
				image_mode_button.button_pressed = true
			CipherData.CipherType.AUDIO:
				_make_inputs_enabled(text_signal_inputs, false)
				_make_inputs_enabled(image_signal_inputs, false)
				_make_inputs_enabled(audio_signal_inputs, true)
				audio_mode_button.button_pressed = true
		emit_signal("cipher_type_selected", value)

@onready var text_signal_inputs: Node = $TextInputs
@onready var image_signal_inputs: Node = $ImageInputs
@onready var audio_signal_inputs: Node = $AudioInputs

@onready var text_mode_button: TextureButton = %TextModeButton
@onready var image_mode_button: TextureButton = %ImageModeButton
@onready var audio_mode_button: TextureButton = %AudioModeButton

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

	var quality = sqrt(
		clampf(
			lerp(
				0.1,
				1.2,
				_get_active_inputs().reduce(
					func(acc: float, input: SignalInput): return acc * input.get_quality(), 1.0
				)
			),
			0.0,
			1.0
		)
	)

	if _get_active_inputs().any(func(input: SignalInput): return !input.is_value_correct()):
		if quality > MAX_QUALITY_WHEN_INCORRECT:
			return MAX_QUALITY_WHEN_INCORRECT
		return quality

	return 1.0


func _process(delta: float) -> void:
	_smoothed_signal_quality += (get_signal_quality() - _smoothed_signal_quality) * delta
	signal_indicator.set_value_f(pow(_smoothed_signal_quality, 3.0))
