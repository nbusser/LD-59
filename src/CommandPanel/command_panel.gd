class_name CommandPanel extends Control

signal cipher_type_selected(cipher_type: CipherData.CipherType)

@onready var text_signal_inputs: Node = $TextInputs
@onready var image_signal_inputs: Node = $ImageInputs
@onready var audio_signal_inputs: Node = $AudioInputs


func _ready() -> void:
	_on_text_pressed()


func _make_inputs_enabled(group: Node, enabled: bool) -> void:
	for input in group.get_children() as Array[SignalInput]:
		input.set_enable(enabled)


func _on_text_pressed() -> void:
	_make_inputs_enabled(text_signal_inputs, true)
	_make_inputs_enabled(image_signal_inputs, false)
	_make_inputs_enabled(audio_signal_inputs, false)
	emit_signal("cipher_type_selected", CipherData.CipherType.TEXT)


func _on_image_pressed() -> void:
	_make_inputs_enabled(text_signal_inputs, false)
	_make_inputs_enabled(image_signal_inputs, true)
	_make_inputs_enabled(audio_signal_inputs, false)
	emit_signal("cipher_type_selected", CipherData.CipherType.IMAGE)


func _on_audio_pressed() -> void:
	_make_inputs_enabled(text_signal_inputs, false)
	_make_inputs_enabled(image_signal_inputs, false)
	_make_inputs_enabled(audio_signal_inputs, true)
	emit_signal("cipher_type_selected", CipherData.CipherType.AUDIO)


func _on_level_deciphering_started_stopped(started: bool) -> void:
	for button in $SignalTypeButtons.get_children() as Array[Button]:
		button.disabled = not started

	if started:
		_on_text_pressed()
	else:
		_make_inputs_enabled(text_signal_inputs, false)
		_make_inputs_enabled(image_signal_inputs, false)
		_make_inputs_enabled(audio_signal_inputs, false)
