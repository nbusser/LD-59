class_name CipheredImage extends CipheredSignal

# gdlint: disable=class-definitions-order

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

var _transformed_image: Dictionary = {"base_image": null}

@onready var _noise_image_fake_source: Texture2D = preload("res://assets/sprites/player.png")


func _get_fake_source() -> Texture2D:
	return _noise_image_fake_source


# ----------------------------------------------------------------------------------------------------
# MARK: Blur

@export var blur_input: SignalInput

const _BLUR_SCALE_LOWER_BOUND = 0.0
const _BLUR_SCALE_UPPER_BOUND = 1.0

var _blur_offset: float


func _blur_input_changed(_value: float) -> void:
	pass
	#_cipher_player.pitch_scale = lerp(
	#_BLUR_SCALE_LOWER_BOUND, _BLUR_SCALE_UPPER_BOUND, Utils.wrap_triangle(value, _blur_offset)
	#)


# ----------------------------------------------------------------------------------------------------
# MARK: Common


func _ready() -> void:
	_transformed_image = {"base_image": source}
	_render()


func _render() -> void:
	_transformed_image = {"base_image": source}
	super()


# Returns a dictionary containing the base image and all the shader parameters
func get_transformed_image() -> Dictionary:
	return _transformed_image
