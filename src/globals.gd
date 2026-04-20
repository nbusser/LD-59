extends Node

signal scene_ended(status: EndSceneStatus, params: Dictionary)
signal glasses_state_changed(active: bool)

# Status sent along with signal end_scene()
enum EndSceneStatus {
	# Main meu
	MAIN_MENU_CLICK_START,
	MAIN_MENU_CLICK_SELECT_LEVEL,
	MAIN_MENU_CLICK_CREDITS,
	MAIN_MENU_CLICK_QUIT,
	# Level
	LEVEL_END,
	LEVEL_GAME_OVER,
	LEVEL_RESTART,
	# Game over screen
	GAME_OVER_RESTART,
	GAME_OVER_QUIT,
	# Score screen
	SCORE_SCREEN_NEXT,
	SCORE_SCREEN_RETRY,
	# Select level
	SELECT_LEVEL_SELECTED,
	SELECT_LEVEL_BACK,
	# Credits
	CREDITS_BACK,
}

const SAMPLE_GLOBAL_VARIABLE: int = 1

var current_level: Level

var dragged_object: Control

var display_mode: CipherData.CipherType = CipherData.CipherType.TEXT

var glasses_active = false:
	set(value):
		glasses_active = value
		glasses_state_changed.emit(value)


func get_current_cipher() -> CipherData:
	return current_level.level_state.current_cipher


func end_scene(status: EndSceneStatus, params: Dictionary = {}) -> void:
	scene_ended.emit(status, params)


func coin_flip() -> bool:
	return randi() % 2


func toggle_glasses() -> bool:
	glasses_active = !glasses_active
	return glasses_active
