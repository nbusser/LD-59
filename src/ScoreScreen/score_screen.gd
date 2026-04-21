class_name ScoreScreen

extends Control

var nb_successes: int = -1
var total: int = -1

@onready var good_ending: Control = $GoodEnding
@onready var bad_ending: Control = $BadEnding


func _display_ending():
	$Score/Label.text = "Your score: " + str(self.nb_successes) + "/" + str(self.total)

	good_ending.visible = false
	bad_ending.visible = false

	if nb_successes >= total * 0.8:
		good_ending.visible = true
	else:
		bad_ending.visible = true


func _ready() -> void:
	assert(nb_successes >= 0 and total > 0)
	_display_ending()


func init(nb_successes_p: int, total_p: int) -> void:
	self.nb_successes = nb_successes_p
	self.total = total_p


func _on_retry_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.GAME_OVER_RESTART)


func _on_credits_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.SCORE_SCREEN_NEXT)
