class_name CipheredAudio extends CipheredSignal

# gdlint: disable=class-definitions-order

@onready var _noise_sound_fake_source: AudioStream = preload("res://assets/sounds/noise.ogg")


func _get_fake_source() -> Array[AudioTrack]:
	var fake_tracks: Array[AudioTrack] = []
	for i in range(_cipher_players.size()):
		var track: AudioTrack = AudioTrack.new()
		track.stream = _noise_sound_fake_source
		track.reverse_stream = _noise_sound_fake_source
		fake_tracks.append(track)
	return fake_tracks


var is_wrong_cipher_type: bool:
	get():
		return (
			Globals.current_level.level_state.current_cipher.cipher_type
			!= CipherData.CipherType.AUDIO
		)

# Ciphered audio
# Assign [] if the current cipher is NOT an audio cipher.
# In that case, it will use a fake audio stream instead.
var source: Array[AudioTrack]:
	set(new_source):
		if is_wrong_cipher_type:
			# Expect level.gd to give a [] audio stream
			assert(new_source.size() == 0)
			new_source = _get_fake_source()

		assert(new_source.size() == _cipher_players.size())
		for stream in source:
			assert(stream != null)

		source = new_source
		_reset()

@onready var _cipher_players: Array[AudioStreamPlayer] = [
	$CipherTracks/Track1, $CipherTracks/Track2, $CipherTracks/Track3
]
@onready var _noise_player: AudioStreamPlayer = $NoisePlayer

var _transformed_audio: AudioStream


func _reset() -> void:
	assert(source.size() == _cipher_players.size())

	var prng = RandomNumberGenerator.new()
	prng.seed = source[0].resource_path.hash()

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

	# Reset random frequency shape position
	frequency_shape.correct_value = prng.randf_range(SignalInput.MIN_VALUE, SignalInput.MAX_VALUE)
	print("correct", frequency_shape.correct_value)
	_frequency_shape_changed(frequency_shape.amount)
	_shape_noise.seed = prng.randi()

	# Reset random noise scale
	_noise_scale_lower_bound = NOISE_SCALE_ABSOLUTE_LOWER_BOUND
	_noise_scale_upper_bound = prng.randf_range(
		max(0.0, _noise_scale_lower_bound + NOISE_SCALE_MIN_AMPLITUDE),
		NOISE_SCALE_ABSOLUTE_UPPER_BOUND
	)
	noise_input.correct_value = prng.randf_range(SignalInput.MIN_VALUE, SignalInput.MAX_VALUE)
	_noise_input_changed(noise_input.amount)

	for i in range(source.size()):
		_tracks_mixer_lower_bounds[i] = TRACK_MIXERS_LOWER_BOUND
		_tracks_mixer_upper_bounds[i] = prng.randf_range(
			max(0.0, _tracks_mixer_lower_bounds[i] + TRACK_MIXERS_MIN_AMPLITUDE),
			TRACK_MIXERS_UPPER_BOUND
		)
		_track_mixers[i].correct_value = inverse_lerp(
			_tracks_mixer_lower_bounds[i], _tracks_mixer_upper_bounds[i], 1.0
		)
		_track_mixers[i].correct_value = prng.randf_range(
			SignalInput.MIN_VALUE, SignalInput.MAX_VALUE
		)
		_track_mixer_input_changed(i, _track_mixers[i].amount)

		var track := source[i]
		for stream in [track.stream, track.reverse_stream]:
			if stream is AudioStreamMP3:
				stream.loop = true
			elif stream is AudioStreamOggVorbis:
				stream.loop = true
			elif stream is AudioStreamWAV:
				stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			else:
				push_error("Unsupported audio stream type: %s" % stream)
		_cipher_players[i].stream = track.stream


# ----------------------------------------------------------------------------------------------------
# MARK: Shape

@export var frequency_shape: SignalInput

const FREQUENCY_SHAPE_PEAK_HALF_WIDTH = 0.06

var _frequency_shape_peak = 0.0
var _frequency_shape_value = 0.0

var _shape_noise = FastNoiseLite.new()


func _frequency_shape_changed(value: float) -> void:
	var noise = (_shape_noise.get_noise_1d(value) + 1.0) * 0.25
	var t = absf(value - frequency_shape.correct_value) / FREQUENCY_SHAPE_PEAK_HALF_WIDTH
	_frequency_shape_peak = maxf(0.0, 1.0 - t)
	_frequency_shape_value = _frequency_shape_peak + noise


# ----------------------------------------------------------------------------------------------------
# MARK: Pitch

@export var speed_input: SignalInput

const PITCH_SCALE_ABSOLUTE_LOWER_BOUND = 0.25
const PITCH_SCALE_ABSOLUTE_UPPER_BOUND = 3.0
const PITCH_SCALE_MIN_AMPLITUDE = 1.0

var _pitch_scale_lower_bound = PITCH_SCALE_ABSOLUTE_LOWER_BOUND
var _pitch_scale_upper_bound = PITCH_SCALE_ABSOLUTE_UPPER_BOUND


func _speed_input_changed(value: float) -> void:
	# Note: cannot use pitch effect on the whole bus because it doesn't affect the tempo
	for track in _cipher_players:
		track.pitch_scale = lerp(_pitch_scale_upper_bound, _pitch_scale_lower_bound, 1.0 - value)


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
# MARK: Tracks mixing

@export var track_1_mixer: SignalInput
@export var track_2_mixer: SignalInput
@export var track_3_mixer: SignalInput

@onready var _track_mixers: Array[SignalInput] = [track_1_mixer, track_2_mixer, track_3_mixer]

const TRACK_MIXERS_LOWER_BOUND = 0.0
const TRACK_MIXERS_UPPER_BOUND = 1.0
const TRACK_MIXERS_MIN_AMPLITUDE = 0.6

var _tracks_mixer_lower_bounds: Array[float] = [
	TRACK_MIXERS_LOWER_BOUND,
	TRACK_MIXERS_LOWER_BOUND,
	TRACK_MIXERS_LOWER_BOUND,
]

var _tracks_mixer_upper_bounds: Array[float] = [
	TRACK_MIXERS_UPPER_BOUND,
	TRACK_MIXERS_UPPER_BOUND,
	TRACK_MIXERS_UPPER_BOUND,
]


func _track_mixer_input_changed(index: int, value: float) -> void:
	_cipher_players[index].volume_linear = lerp(
		_tracks_mixer_lower_bounds[index],
		_tracks_mixer_upper_bounds[index],
		1.0 - Utils.map_triangle(value, _track_mixers[index].correct_value)
	)


# ----------------------------------------------------------------------------------------------------
# MARK: Reverse

@export var track_1_reverse_button: BinarySignalInput
@export var track_2_reverse_button: BinarySignalInput
@export var track_3_reverse_button: BinarySignalInput

@onready var _reverse_buttons: Array[BinarySignalInput] = [
	track_1_reverse_button, track_2_reverse_button, track_3_reverse_button
]


func _reverse_button_input_changed(index: int, value: bool) -> void:
	var player := _cipher_players[index]

	var was_playing := player.playing
	var cursor := player.get_playback_position()
	var stream_length := player.stream.get_length()

	if value:
		player.stream = source[index].reverse_stream
	else:
		player.stream = source[index].stream

	if was_playing:
		var absolute_pos := cursor if not value else stream_length - cursor
		var new_timestamp := stream_length - absolute_pos if value else absolute_pos
		player.play(new_timestamp)

		# Try to resync everything, but seems unnecessary
		# for i in range(_cipher_players.size()):
		# 	var player_2 := _cipher_players[i]
		# 	var is_reverse := _reverse_buttons[i].value
		#   var new_timestamp := stream_length - absolute_pos if is_reverse else absolute_pos

		# 	if player_2 == player:
		# 		player.play(new_timestamp)
		# 	else:
		# 		player_2.seek(new_timestamp)


# ----------------------------------------------------------------------------------------------------
# MARK: Common


func _ready() -> void:
	speed_input.signal_input_changed.connect(_speed_input_changed)
	speed_input.trigger_update.call_deferred()

	noise_input.signal_input_changed.connect(_noise_input_changed)
	noise_input.trigger_update.call_deferred()

	assert(_track_mixers.size() == _cipher_players.size())
	for i in range(_track_mixers.size()):
		var mixer = _track_mixers[i]
		assert(mixer != null)
		var mixer_callback = func(value: float): _track_mixer_input_changed(i, value)
		mixer.signal_input_changed.connect(mixer_callback)
		mixer.trigger_update.call_deferred()

	assert(_reverse_buttons.size() == _cipher_players.size())
	for i in range(_reverse_buttons.size()):
		var button = _reverse_buttons[i]
		assert(button != null)
		var reverse_callback = func(value: bool): _reverse_button_input_changed(i, value)
		button.signal_input_changed.connect(reverse_callback)
		button.trigger_update.call_deferred()

	frequency_shape.signal_input_changed.connect(_frequency_shape_changed)
	frequency_shape.trigger_update.call_deferred()

	_shape_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_shape_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_shape_noise.fractal_octaves = 4
	_shape_noise.frequency = 2.


func _render() -> void:
	# TODO: blend
	_transformed_audio = source[0].stream
	super()


func get_transformed_audio() -> AudioStream:
	return _transformed_audio


func set_focused(focused: bool) -> void:
	if !is_node_ready():
		return

	if focused:
		for player in _cipher_players:
			if !player.playing:
				player.play()
		if !_noise_player.playing:
			_noise_player.play()
	else:
		for player in _cipher_players:
			player.stop()
		_noise_player.stop()
	super(focused)
