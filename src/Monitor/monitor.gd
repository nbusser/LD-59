extends Control

class_name Monitor

@export var ciphered_text: CipheredText
@export var ciphered_image: CipheredImage
@export var ciphered_audio: CipheredAudio

@onready var _rendered_text = $Signal/RenderedText
@onready var _rendered_image = $Signal/RenderedImage
@onready var _rendered_audio = $Signal/RenderedAudio

func _ready() -> void:
	_display_cipher(CipherData.CipherType.TEXT)
	ciphered_text.on_render.connect(_on_text_render)

func _display_cipher(selection: CipherData.CipherType):
	match selection:
		CipherData.CipherType.TEXT:
			_rendered_text.visible = true
			_rendered_image.visible = false
			_rendered_audio.visible = false
		CipherData.CipherType.IMAGE:
			_rendered_text.visible = false
			_rendered_image.visible = true
			_rendered_audio.visible = false
		CipherData.CipherType.AUDIO:
			_rendered_text.visible = false
			_rendered_image.visible = false
			_rendered_audio.visible = true

func _on_text_render() -> void:
	_rendered_text.text = ciphered_text.get_transformed_text()

func _on_image_render() -> void:
	# TODO
	print("Image render: TODO")

func _on_audio_render() -> void:
	print("Audio render: TODO")


func _on_level_new_cipher_loaded(cipher_data: CipherData) -> void:
	_display_cipher(cipher_data.cipher_type)
