class_name CipheredAudio
extends CipheredSignal

var source: AudioStream:
	set(new_source):
		source = new_source
		_reset()
		_render()

var player: AudioStreamPlayer

var _transformed_audio: AudioStream


func _reset() -> void:
	if source == null:
		return

	var prng = RandomNumberGenerator.new()
	prng.seed = source.resource_scene_unique_id.hash()

	if source is AudioStreamMP3:
		source.loop = true
	elif source is AudioStreamOggVorbis:
		source.loop = true
	elif source is AudioStreamWAV:
		source.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		push_error("Unsupported audio stream type: %s" % source)

	player.stream = source


func _ready() -> void:
	_reset()

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
