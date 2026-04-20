class_name GameOver

extends Control


func init(successes: int, total: int):
	$CenterContainer/VBoxContainer/Score.text = str(successes) + "/" + str(total)


func _on_Restart_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.GAME_OVER_RESTART)


func _on_Quit_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.GAME_OVER_QUIT)
