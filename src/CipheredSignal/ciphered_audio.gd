class_name CipheredAudio extends CipheredSignal

# gdlint: disable=class-definitions-order

@onready var _noise_sound_fake_source: AudioStream = preload("res://assets/sounds/noise.ogg")


func _get_fake_source() -> AudioStream:
	return _noise_sound_fake_source


var is_wrong_cipher_type: bool:
	get():
		return (
			Globals.current_level.level_state.current_cipher.cipher_type
			!= CipherData.CipherType.AUDIO
		)

# Ciphered audio
# Assign null if the current cipher is NOT an audio cipher.
# In that case, it will use a fake audio stream instead.
var source: AudioStream:
	set(new_source):
		if is_wrong_cipher_type:
			# Expect level.gd to give a null audio stream
			assert(new_source == null)
			new_source = _get_fake_source()

		source = new_source
		_reset()

@onready var _cipher_player: AudioStreamPlayer = $CipherPlayer
@onready var _noise_player: AudioStreamPlayer = $NoisePlayer

var _transformed_audio: AudioStream


func _reset() -> void:
	assert(source != null)

	var prng = RandomNumberGenerator.new()
	prng.seed = source.resource_path.hash()

	# Reset random pitch scale. 1.0 (correct pitch scale) is always within bounds
	_pitch_scale_lower_bound = prng.randf_range(PITCH_SCALE_ABSOLUTE_LOWER_BOUND, 1.0)
	_pitch_scale_upper_bound = prng.randf_range(
		max(1.0, _pitch_scale_lower_bound + PITCH_SCALE_MIN_AMPLITUDE),
		PITCH_SCALE_ABSOLUTE_UPPER_BOUND
	)
	speed_input.correct_value = inverse_lerp(
		_pitch_scale_lower_bound, _pitch_scale_upper_bound, 1.0
	)
	_speed_input_changed(speed_input.amount)

	# Reset random noise scale
	_noise_scale_lower_bound = NOISE_SCALE_ABSOLUTE_LOWER_BOUND
	_noise_scale_upper_bound = prng.randf_range(
		max(0.0, _noise_scale_lower_bound + NOISE_SCALE_MIN_AMPLITUDE),
		NOISE_SCALE_ABSOLUTE_UPPER_BOUND
	)
	noise_input.correct_value = prng.randf_range(SignalInput.MIN_VALUE, SignalInput.MAX_VALUE)
	_noise_input_changed(noise_input.amount)

	if source is AudioStreamMP3:
		source.loop = true
	elif source is AudioStreamOggVorbis:
		source.loop = true
	elif source is AudioStreamWAV:
		source.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		push_error("Unsupported audio stream type: %s" % source)

	_cipher_player.stream = source


# ----------------------------------------------------------------------------------------------------
# MARK: Pitch

@export var speed_input: SignalInput

const PITCH_SCALE_ABSOLUTE_LOWER_BOUND = 0.25
const PITCH_SCALE_ABSOLUTE_UPPER_BOUND = 3.0
const PITCH_SCALE_MIN_AMPLITUDE = 1.0

var _pitch_scale_lower_bound = PITCH_SCALE_ABSOLUTE_LOWER_BOUND
var _pitch_scale_upper_bound = PITCH_SCALE_ABSOLUTE_UPPER_BOUND


func _speed_input_changed(value: float) -> void:
	_cipher_player.pitch_scale = lerp(
		_pitch_scale_upper_bound, _pitch_scale_lower_bound, 1.0 - value
	)


# ----------------------------------------------------------------------------------------------------
# MARK: Noise

@export var noise_input: SignalInput

const NOISE_SCALE_ABSOLUTE_LOWER_BOUND = 0.0
const NOISE_SCALE_ABSOLUTE_UPPER_BOUND = 0.8
const NOISE_SCALE_MIN_AMPLITUDE = 0.6

var _noise_scale_lower_bound = NOISE_SCALE_ABSOLUTE_LOWER_BOUND
var _noise_scale_upper_bound = NOISE_SCALE_ABSOLUTE_UPPER_BOUND


func _noise_input_changed(value: float) -> void:
	_noise_player.volume_linear = lerp(
		_noise_scale_lower_bound,
		_noise_scale_upper_bound,
		1.0 - Utils.map_triangle(value, noise_input.correct_value)
	)


# ----------------------------------------------------------------------------------------------------
# MARK: Common


func _ready() -> void:
	speed_input.signal_input_changed.connect(_speed_input_changed)
	speed_input.trigger_update.call_deferred()
	noise_input.signal_input_changed.connect(_noise_input_changed)
	noise_input.trigger_update.call_deferred()


func _render() -> void:
	_transformed_audio = source
	super()


func get_transformed_audio() -> AudioStream:
	return _transformed_audio


func set_focused(focused: bool) -> void:
	if !is_node_ready():
		return

	if focused:
		if !_cipher_player.playing:
			_cipher_player.play()
		if !_noise_player.playing:
			_noise_player.play()
	else:
		_cipher_player.stop()
		_noise_player.stop()
	super(focused)
