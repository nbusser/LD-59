class_name Level

extends Node

signal deciphering_started_stopped(started: bool)
signal phase_changed(phase: LevelState.Phase)

var level_state: LevelState

@onready var hud: HUD = $UI/HUD
@onready var timer: Timer = $Timer
@onready var command_panel: CommandPanel = $UI/CommandPanel

@onready var ciphered_text: CipheredText = $CipheredSignals/CipheredText
@onready var ciphered_image: CipheredImage = $CipheredSignals/CipheredImage
@onready var ciphered_audio: CipheredAudio = $CipheredSignals/CipheredAudio

@onready var glasses_overlay: Control = %GlassesOverlay
@onready var intercept_player: InterceptPlayer = $InterceptPlayer

@onready var carton: Control = %Carton
@onready var carton_text: Control = %CartonText


func _ready():
	assert(level_state, "init must be called before creating Level scene")

	_load_next_cipher()

	hud.init(level_state)
	if level_state.level_data.timer_duration > 0:
		timer.start(level_state.level_data.timer_duration)

	command_panel.init(level_state)

	deciphering_started_stopped.emit(false)

	$UI/Fadein.fade()
	Globals.glasses_state_changed.connect(_on_glasses_state_changed)


func init(level_data_p: LevelData):
	level_state = LevelState.new(level_data_p)


func _load_next_cipher():
	switch_phase(LevelState.Phase.DESCRAMBLE)

	if level_state.next_cipher_index == level_state.level_data.ciphers.size():
		Globals.end_scene(
			Globals.EndSceneStatus.LEVEL_END,
			{
				"successes": level_state.successes_counter,
				"total": len(level_state.level_data.ciphers)
			}
		)
		return

	level_state.current_cipher = level_state.level_data.ciphers[level_state.next_cipher_index]
	level_state.next_cipher_index += 1

	match level_state.current_cipher.cipher_type:
		CipherData.CipherType.TEXT:
			ciphered_text.source = level_state.current_cipher.text_content
			ciphered_image.source = null
			ciphered_audio.source = []
		CipherData.CipherType.IMAGE:
			ciphered_text.source = ""
			ciphered_image.source = level_state.current_cipher.image_texture
			ciphered_audio.source = []
		CipherData.CipherType.AUDIO:
			ciphered_text.source = ""
			ciphered_image.source = null
			ciphered_audio.source = [
				level_state.current_cipher.audio_stream_1,
				level_state.current_cipher.audio_stream_2,
				level_state.current_cipher.audio_stream_3
			]

	await _play_searching_signal_animation()

	deciphering_started_stopped.emit(true)
	if level_state.current_cipher.cipher_type != CipherData.CipherType.AUDIO:
		intercept_player.trigger()

	switch_phase(LevelState.Phase.STEGANO)


func switch_phase(phase: LevelState.Phase):
	level_state.phase = phase
	phase_changed.emit(phase)


func _on_Timer_timeout():
	await $UI/Fadeout.fade()
	Globals.end_scene(
		Globals.EndSceneStatus.LEVEL_GAME_OVER,
		{"successes": level_state.successes_counter, "total": len(level_state.level_data.ciphers)}
	)


func _on_disco_buttons_disco_button_pressed(is_disco: bool) -> void:
	intercept_player.reset()
	deciphering_started_stopped.emit(false)

	if level_state.current_cipher.is_disco != is_disco:
		await _play_cipher_decoded_animation(false)
	else:
		level_state.successes_counter += 1
		await _play_cipher_decoded_animation(true)

	_load_next_cipher()


func _play_searching_signal_animation():
	$AnimationPlayer.play("searching_signal")
	await $AnimationPlayer.animation_finished


func _play_signal_found_animation():
	$AnimationPlayer.play("signal_found")
	# await $AnimationPlayer.animation_finished


func _play_cipher_decoded_animation(success: bool):
	carton.visible = true
	if success:
		$Audio/Success.play()
		var text = level_state.current_cipher.success_message
		if !text or text.length() < 1:
			text = (
				[
					"No doubt!",
					"Blasphemy!",
					"Obvious.",
					"Sneaky!",
					"Keen eye!",
					"Well found!",
					"Nice one",
					"Got 'em!",
					"Good job!",
				]
				. pick_random()
			)
		carton_text.text = text
		carton.size = Vector2.ZERO
		await get_tree().create_timer(1.5).timeout
	else:
		$Audio/Failure.play()
		carton_text.text = level_state.current_cipher.fail_message
		carton.size = Vector2.ZERO
		await get_tree().create_timer(5.0).timeout

	carton.visible = false

	await _play_signal_found_animation()
	await get_tree().create_timer(0.8).timeout


func _on_glasses_state_changed(active: bool):
	glasses_overlay.visible = active
