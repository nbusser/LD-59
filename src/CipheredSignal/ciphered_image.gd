class_name CipheredImage
extends CipheredSignal

var is_wrong_cipher_type: bool:
	get():
		return (
			Globals.current_level.level_state.current_cipher.cipher_type
			!= CipherData.CipherType.IMAGE
		)

var source: Texture2D:
	set(new_source):
		if is_wrong_cipher_type:
			# Expect level.gd to give a null texture
			assert(new_source == null)
			new_source = _get_fake_source()

		source = new_source
		_render()

var _transformed_image: Texture2D

@onready var _noise_image_fake_source: Texture2D = preload("res://assets/sprites/player.png")


func _get_fake_source() -> Texture2D:
	return _noise_image_fake_source


func _ready() -> void:
	_transformed_image = source
	_render()


func _render() -> void:
	_transformed_image = source
	super()


func get_transformed_image() -> Texture2D:
	return _transformed_image
