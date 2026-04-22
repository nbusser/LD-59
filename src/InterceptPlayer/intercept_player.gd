class_name InterceptPlayer extends Node

@export var sound_pool: Array[AudioStream] = []

var _index := 0

@onready var _timer: Timer = $Timer
@onready var _noise: AudioStreamPlayer = $NoisePlayer
@onready var _message: AudioStreamPlayer = $MessagePlayer


func _ready() -> void:
	_noise.finished.connect(_noise.play)


func trigger() -> void:
	if sound_pool.is_empty():
		return
	_timer.wait_time = randf_range(5.0, 10.0)
	_timer.start()


func reset() -> void:
	_timer.stop()
	_noise.stop()
	_message.stop()


func _on_timer_timeout() -> void:
	if _index >= sound_pool.size():
		return

	_message.stream = sound_pool[_index % sound_pool.size()]
	_index += 1

	var bus_idx := AudioServer.get_bus_index("Intercept")

	_noise.volume_db = -80.0
	_noise.play()
	var tw := create_tween()
	tw.tween_property(_noise, "volume_db", 0.0, 0.5)
	await tw.finished
	_noise.stop()

	AudioServer.set_bus_bypass_effects(bus_idx, true)
	_message.play()
	await _message.finished
	AudioServer.set_bus_bypass_effects(bus_idx, false)

	_noise.volume_db = -80.0
	_noise.play()
	tw = create_tween()
	tw.tween_property(_noise, "volume_db", 0.0, 0.5)
	await tw.finished
	tw = create_tween()
	tw.tween_property(_noise, "volume_db", -80.0, 0.5)
	await tw.finished
	_noise.stop()
