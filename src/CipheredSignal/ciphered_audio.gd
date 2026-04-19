class_name CipheredAudio extends CipheredSignal

# gdlint: disable=class-definitions-order

var source: AudioStream:
	set(new_source):
		source = new_source
		_reset()
		_render()

var player: AudioStreamPlayer

var _transformed_audio: AudioStream


func _reset() -> void:
	assert(source != null)

	var prng = RandomNumberGenerator.new()
	prng.seed = source.resource_scene_unique_id.hash()

	# Reset random pitch scale
	pitch_scale_lower_bound = prng.randf_range(PITCH_SCALE_ABSOLUTE_LOWER_BOUND, 1.0)
	pitch_scale_upper_bound = prng.randf_range(
		max(1.0, pitch_scale_lower_bound + PITCH_SCALE_MIN_AMPLITUDE),
		PITCH_SCALE_ABSOLUTE_UPPER_BOUND
	)

	if source is AudioStreamMP3:
		source.loop = true
	elif source is AudioStreamOggVorbis:
		source.loop = true
	elif source is AudioStreamWAV:
		source.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		push_error("Unsupported audio stream type: %s" % source)

	player.stream = source


# MARK: Pitch

const PITCH_SCALE_ABSOLUTE_LOWER_BOUND = 0.25
const PITCH_SCALE_ABSOLUTE_UPPER_BOUND = 3.0
const PITCH_SCALE_MIN_AMPLITUDE = 1.0

@export var speed_input: SignalInput

var pitch_scale_lower_bound = PITCH_SCALE_ABSOLUTE_LOWER_BOUND
var pitch_scale_upper_bound = PITCH_SCALE_ABSOLUTE_UPPER_BOUND


func _speed_input_changed(value: float) -> void:
	player.pitch_scale = (
		pitch_scale_lower_bound + (pitch_scale_upper_bound - pitch_scale_lower_bound) * value
	)


# MARK: Common


func _ready() -> void:
	speed_input.signal_input_changed.connect(_speed_input_changed)

	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = source
	player.bus = "CipheredSignal"
	player.call_deferred("play")


func _render() -> void:
	_transformed_audio = source
	super()


func get_transformed_audio() -> AudioStream:
	return _transformed_audio
