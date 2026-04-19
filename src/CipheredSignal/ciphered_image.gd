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

var _transformed_image: Dictionary = {
	"base_image": null, "shuffle_rows_strength": 0.0, "v_desync_strength": 0.0
}

@onready var _noise_image_fake_source: Texture2D = preload("res://assets/sprites/player.png")


func _get_fake_source() -> Texture2D:
	return _noise_image_fake_source


# ----------------------------------------------------------------------------------------------------
# MARK: Parameter sliders

@export var shuffle_rows_input: SignalInput

const _SHUFFLE_ROWS_SCALE_LOWER_BOUND = 0.0
const _SHUFFLE_ROWS_SCALE_UPPER_BOUND = 1.0

var _shuffle_rows_offset: float


func _shuffle_rows_input_changed(_value: float) -> void:
	_transformed_image["shuffle_rows_strength"] = lerp(
		_SHUFFLE_ROWS_SCALE_LOWER_BOUND,
		_SHUFFLE_ROWS_SCALE_UPPER_BOUND,
		Utils.wrap_triangle(_value, _shuffle_rows_offset)
	)
	_render()


@export var v_desync_input: SignalInput

const _V_DESYNC_SCALE_LOWER_BOUND = -1.0
const _V_DESYNC_SCALE_UPPER_BOUND = 1.0
var _v_desync_offset: float


func v_desync_input_changed(_value: float) -> void:
	_transformed_image["v_desync_strength"] = lerp(
		_V_DESYNC_SCALE_LOWER_BOUND,
		_V_DESYNC_SCALE_UPPER_BOUND,
		Utils.wrap_triangle(_value, _v_desync_offset)
	)
	_render()


# ----------------------------------------------------------------------------------------------------
# MARK: Common


func _ready() -> void:
	shuffle_rows_input.signal_input_changed.connect(_shuffle_rows_input_changed)
	v_desync_input.signal_input_changed.connect(v_desync_input_changed)
	_render()


func _render() -> void:
	_transformed_image["base_image"] = source
	super()


# Returns a dictionary containing the base image and all the shader parameters
func get_transformed_image() -> Dictionary:
	return _transformed_image
