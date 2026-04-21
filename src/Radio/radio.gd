class_name Radio
extends Control

var _muted := false
var _sfx_volume := 1.0
var _music_volume := 1.0

@onready var sfx_slider: HSlider = %SfxSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var mute_button: TextureButton = %MuteButton


func _ready() -> void:
	sfx_slider.value = _sfx_volume
	music_slider.value = _music_volume


func _on_sfx_slider_value_changed(value: float) -> void:
	_sfx_volume = value
	if not _muted:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	_music_volume = value
	if not _muted:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_mute_button_toggled(toggled: bool) -> void:
	_muted = toggled
	var sfx_db = -80.0 if _muted else linear_to_db(_sfx_volume)
	var music_db = -80.0 if _muted else linear_to_db(_music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Others"), sfx_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Cipher"), sfx_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
