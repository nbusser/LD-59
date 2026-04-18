class_name CipheredAudio
extends CipheredSignal

var source: AudioStream
var _transformed_audio: AudioStream


func _ready() -> void:
	pass


func _render() -> void:
	_transformed_audio = source
	super()


func get_transformed_audio() -> AudioStream:
	return _transformed_audio
