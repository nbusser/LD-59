class_name Level

extends Node

var level_state: LevelState

@onready var hud: HUD = $UI/HUD
@onready var timer: Timer = $Timer

func _ready():
	assert(level_state, "init must be called before creating Level scene")

	hud.init(level_state)
	timer.start(level_state.level_data.timer_duration)

	$UI/Fadein.fade()


func init(level_data_p: LevelData):
	level_state = LevelState.new(level_data_p)


func _on_Timer_timeout():
	# Simulates game state change
	level_state.nb_coins += randi() % 100

	await $UI/Fadeout.fade()

	if randi() % 4:
		Globals.end_scene(Globals.EndSceneStatus.LEVEL_GAME_OVER)
	else:
		Globals.end_scene(Globals.EndSceneStatus.LEVEL_END, {"new_nb_coins": level_state.nb_coins})
