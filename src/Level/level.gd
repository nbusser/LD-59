class_name Level

extends Node

signal new_cipher_loaded(cipher_data: CipherData)

var level_state: LevelState

@onready var hud: HUD = $UI/HUD
@onready var timer: Timer = $Timer
@onready var monitor: Monitor = $Monitor

@onready var ciphered_text: CipheredText = $CipheredSignals/CipheredText
@onready var ciphered_image: CipheredImage = $CipheredSignals/CipheredImage
@onready var ciphered_audio: CipheredAudio = $CipheredSignals/CipheredAudio


func _ready():
	assert(level_state, "init must be called before creating Level scene")

	_load_next_cipher()

	hud.init(level_state)
	timer.start(level_state.level_data.timer_duration)

	$UI/Fadein.fade()


func init(level_data_p: LevelData):
	level_state = LevelState.new(level_data_p)


func _load_next_cipher():
	if level_state.next_cipher_index >= level_state.level_data.ciphers.size():
		Globals.end_scene(Globals.EndSceneStatus.LEVEL_END, {"new_nb_coins": 0})

	level_state.current_cipher = level_state.level_data.ciphers[level_state.next_cipher_index]
	level_state.next_cipher_index += 1

	match level_state.current_cipher.cipher_type:
		CipherData.CipherType.TEXT:
			ciphered_text.source = level_state.current_cipher.text_content
		CipherData.CipherType.IMAGE:
			ciphered_image.source = level_state.current_cipher.image_texture
		CipherData.CipherType.AUDIO:
			ciphered_audio.source = level_state.current_cipher.audio_stream

	emit_signal("new_cipher_loaded", level_state.current_cipher)


func _on_Timer_timeout():
	await $UI/Fadeout.fade()
	Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)


func _on_disco_buttons_disco_button_pressed(is_disco: bool) -> void:
	if level_state.current_cipher.is_disco != is_disco:
		Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)
	else:
		_load_next_cipher()
