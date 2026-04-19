class_name Monitor extends Control

@export var ciphered_text: CipheredText
@export var ciphered_image: CipheredImage
@export var ciphered_audio: CipheredAudio

var spectrum: AudioEffectSpectrumAnalyzerInstance

var _current_selection: CipherData.CipherType = CipherData.CipherType.TEXT:
	set(value):
		_current_selection = value
		_display_cipher()

@onready var _rendered_text = $SubViewport/Signal/RenderedText
@onready var _rendered_audio = $SubViewport/Signal/RenderedAudio

@onready var _display = $Display


func _ready() -> void:
	_display_cipher()
	ciphered_text.on_render.connect(_on_text_render)
	ciphered_image.on_render.connect(_on_image_render)
	# Nothing to do on audio render -> done in real time


func _display_cipher():
	match _current_selection:
		CipherData.CipherType.TEXT:
			_rendered_text.visible = true
			# _rendered_image.visible = false
			_rendered_audio.visible = false
		CipherData.CipherType.IMAGE:
			_rendered_text.visible = false
			# _rendered_image.visible = true
			_rendered_audio.visible = false
		CipherData.CipherType.AUDIO:
			_rendered_text.visible = false
			# _rendered_image.visible = false
			_rendered_audio.visible = true


func _draw():
	# TODO décaler le sujbviewport au dessus de ce node pour que le
	# draw_polyline se fasse dedans
	_display.material.set_shader_parameter("texture_sampler", $SubViewport.get_texture())
	_display.material.set_shader_parameter("convol", -1.)


func _process(_delta: float) -> void:
	# _rendered_image.texture = ciphered_image.get_transformed_image()
	pass


func _on_text_render() -> void:
	_rendered_text.text = ciphered_text.get_transformed_text()


func _on_image_render() -> void:
	pass


func _on_audio_render() -> void:
	print("Audio render: TODO")


func _on_level_new_cipher_loaded(cipher_data: CipherData) -> void:
	_current_selection = cipher_data.cipher_type
