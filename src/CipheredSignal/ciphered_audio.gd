class_name CipheredAudio extends CipheredSignal

# gdlint: disable=class-definitions-order

var source: AudioStream:
	set(new_source):
		source = new_source
		if source == null:
			_cipher_player.stop()
			_noise_player.stop()
		else:
			_reset()
			_render()

@onready var _cipher_player: AudioStreamPlayer = $CipherPlayer
@onready var _noise_player: AudioStreamPlayer = $NoisePlayer

var _transformed_audio: AudioStream


func _reset() -> void:
	assert(source != null)

	var prng = RandomNumberGenerator.new()
	prng.seed = source.resource_scene_unique_id.hash()

	# Reset random pitch scale
	_pitch_scale_lower_bound = prng.randf_range(PITCH_SCALE_ABSOLUTE_LOWER_BOUND, 1.0)
	_pitch_scale_upper_bound = prng.randf_range(
		max(1.0, _pitch_scale_lower_bound + PITCH_SCALE_MIN_AMPLITUDE),
		PITCH_SCALE_ABSOLUTE_UPPER_BOUND
	)

	# Reset random noise scale
	_noise_scale_lower_bound = prng.randf_range(NOISE_SCALE_ABSOLUTE_LOWER_BOUND, 0.0)
	_noise_scale_upper_bound = prng.randf_range(
		max(0.0, _noise_scale_lower_bound + NOISE_SCALE_MIN_AMPLITUDE),
		NOISE_SCALE_ABSOLUTE_UPPER_BOUND
	)

	if source is AudioStreamMP3:
		source.loop = true
	elif source is AudioStreamOggVorbis:
		source.loop = true
	elif source is AudioStreamWAV:
		source.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		push_error("Unsupported audio stream type: %s" % source)

	_cipher_player.stream = source

	_cipher_player.play()
	_noise_player.play()


# MARK: Pitch

@export var speed_input: SignalInput

const PITCH_SCALE_ABSOLUTE_LOWER_BOUND = 0.25
const PITCH_SCALE_ABSOLUTE_UPPER_BOUND = 3.0
const PITCH_SCALE_MIN_AMPLITUDE = 1.0

var _pitch_scale_lower_bound = PITCH_SCALE_ABSOLUTE_LOWER_BOUND
var _pitch_scale_upper_bound = PITCH_SCALE_ABSOLUTE_UPPER_BOUND


func _speed_input_changed(value: float) -> void:
	_cipher_player.pitch_scale = lerp(_pitch_scale_lower_bound, _pitch_scale_upper_bound, value)


# MARK: Noise

@export var noise_input: SignalInput

const NOISE_SCALE_ABSOLUTE_LOWER_BOUND = -25.0
const NOISE_SCALE_ABSOLUTE_UPPER_BOUND = 10.0
const NOISE_SCALE_MIN_AMPLITUDE = 8.0

var _noise_scale_lower_bound = NOISE_SCALE_ABSOLUTE_LOWER_BOUND
var _noise_scale_upper_bound = NOISE_SCALE_ABSOLUTE_UPPER_BOUND


func _noise_input_changed(value: float) -> void:
	_noise_player.volume_db = lerp(_noise_scale_lower_bound, _noise_scale_upper_bound, value)


# MARK: Common


func _ready() -> void:
	speed_input.signal_input_changed.connect(_speed_input_changed)
	noise_input.signal_input_changed.connect(_noise_input_changed)

	_cipher_player.stream = source
	_cipher_player.call_deferred("play")


func _render() -> void:
	_transformed_audio = source
	super()


func get_transformed_audio() -> AudioStream:
	return _transformed_audio
