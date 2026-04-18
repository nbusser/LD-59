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

	var cipher_data = level_state.level_data.ciphers[level_state.next_cipher_index]
	level_state.next_cipher_index += 1

	match cipher_data.cipher_type:
		CipherData.CipherType.TEXT:
			ciphered_text.source = cipher_data.text_content
		CipherData.CipherType.IMAGE:
			ciphered_image.source = cipher_data.image_texture
		CipherData.CipherType.AUDIO:
			ciphered_audio.source = cipher_data.audio_stream

	emit_signal("new_cipher_loaded", cipher_data)

func _on_Timer_timeout():
	await $UI/Fadeout.fade()
	Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)
