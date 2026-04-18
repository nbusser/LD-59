extends Control

class_name Monitor

@export var ciphered_text: CipheredText
@export var ciphered_image: CipheredImage
@export var ciphered_audio: CipheredAudio

@onready var _rendered_text = $Signal/RenderedText
@onready var _rendered_image = $Signal/RenderedImage
@onready var _rendered_audio = $Signal/RenderedAudio

enum CipherMode {
	TEXT = 0,
	IMAGE = 1,
	AUDIO = 2
}

func _ready() -> void:
	select(CipherMode.TEXT)
	ciphered_text.on_render.connect(_on_text_render)

func select(select: CipherMode):
	match select:
		CipherMode.TEXT:
			_rendered_text.visible = true
			_rendered_image.visible = false
			_rendered_audio.visible = false
		CipherMode.IMAGE:
			_rendered_text.visible = false
			_rendered_image.visible = true
			_rendered_audio.visible = false
		CipherMode.AUDIO:
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
