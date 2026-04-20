class_name Monitor extends Control

@export var _ciphered_text: CipheredText
@export var _ciphered_image: CipheredImage
@export var _ciphered_audio: CipheredAudio

var spectrum: AudioEffectSpectrumAnalyzerInstance

var _current_selection: CipherData.CipherType = CipherData.CipherType.TEXT:
	set(value):
		_current_selection = value
		_display_cipher()

@onready var _rendered_text = %RenderedText
@onready var _rendered_image = %RenderedImage
@onready var _rendered_audio = %RenderedAudio

@onready var _display = $Display

@onready var _signal = %Signal
@onready var _no_signal = %NoSignal


func enable_display():
	_signal.visible = true
	_no_signal.visible = false
	_current_selection = CipherData.CipherType.TEXT
	_rendered_audio.set_shape(Globals.current_level.level_state.current_cipher.secret_shape)


func disable_display():
	_signal.visible = false
	_no_signal.visible = true
	_current_selection = CipherData.CipherType.TEXT
	_rendered_audio.set_shape(CipherData.CipheredAudioShape.NOTHING)


func _ready() -> void:
	disable_display()
	_ciphered_text.on_render.connect(_on_text_render)
	_ciphered_image.on_render.connect(_on_image_render)
	_ciphered_audio.on_render.connect(_on_audio_render)
	Globals.glasses_state_changed.connect(_on_glasses_state_changed)
	Globals.mg_state_changed.connect(_on_mg_state_changed)


func _display_cipher():
	match _current_selection:
		CipherData.CipherType.TEXT:
			_rendered_text.visible = true
			_rendered_image.visible = false
			_rendered_audio.visible = false

			_ciphered_text.set_focused(true)
			_ciphered_image.set_focused(false)
			_ciphered_audio.set_focused(false)
		CipherData.CipherType.IMAGE:
			_rendered_text.visible = false
			_rendered_image.visible = true
			_rendered_audio.visible = false

			_ciphered_text.set_focused(false)
			_ciphered_image.set_focused(true)
			_ciphered_audio.set_focused(false)
		CipherData.CipherType.AUDIO:
			_rendered_text.visible = false
			_rendered_image.visible = false
			_rendered_audio.visible = true

			_ciphered_text.set_focused(false)
			_ciphered_image.set_focused(false)
			_ciphered_audio.set_focused(true)


func _draw():
	_display.material.set_shader_parameter("texture_sampler", $SubViewport.get_texture())
	_display.material.set_shader_parameter("convol", -1.)


func _on_text_render() -> void:
	if (
		Globals.glasses_active
		and Globals.current_level.level_state.phase == LevelState.Phase.STEGANO
	):
		_rendered_text.text = _ciphered_text.get_alternative_text()
	else:
		_rendered_text.text = _ciphered_text.get_transformed_text()


func _on_image_render() -> void:
	var transformed_image_dict = _ciphered_image.get_transformed_image()
	_rendered_image.material.set_shader_parameter(
		"shuffle_rows_strength", transformed_image_dict.get("shuffle_rows_strength", 0.0)
	)
	_rendered_image.material.set_shader_parameter(
		"v_desync_strength", transformed_image_dict.get("v_desync_strength", 0.0)
	)


func _process(_delta):
	_rendered_audio.set_frequency_shape(_ciphered_audio._frequency_shape_value)
	_rendered_audio.noise_volume = _ciphered_audio._noise_player.volume_linear


func _on_audio_render() -> void:
	# Nothing to do on audio render -> done in real time
	pass


func _on_level_new_cipher_loaded(_cipher_data: CipherData) -> void:
	pass


func _on_command_panel_cipher_type_selected(cipher_type: CipherData.CipherType) -> void:
	_current_selection = cipher_type


func _on_level_deciphering_started_stopped(started: bool) -> void:
	if started:
		enable_display()
	else:
		disable_display()


func _on_glasses_state_changed(_active: bool):
	_on_text_render()


func _on_mg_state_changed(active: bool):
	_rendered_image.material.set_shader_parameter("enable_magnifier", active)
