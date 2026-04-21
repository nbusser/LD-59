class_name MainMenu

extends Control

const IMAGES = [
	preload("res://assets/menu/1.png"),
	preload("res://assets/menu/2.png"),
	preload("res://assets/menu/3.png"),
	preload("res://assets/menu/4.png"),
	preload("res://assets/menu/5.png"),
]
const DISPLAY_DURATION := 4.0
const FADE_DURATION := 1.5

var _index := 0
@onready var _bg_back: TextureRect = $BgBack
@onready var _bg_front: TextureRect = $BgFront


func _ready() -> void:
	_bg_back.texture = IMAGES[0]
	_bg_front.texture = IMAGES[0]
	_run_slideshow()


func _run_slideshow() -> void:
	while true:
		await get_tree().create_timer(DISPLAY_DURATION).timeout
		_index = (_index + 1) % IMAGES.size()
		_bg_back.texture = IMAGES[_index]
		var tween := create_tween()
		tween.tween_property(_bg_front, "modulate:a", 0.0, FADE_DURATION)
		await tween.finished
		_bg_front.texture = IMAGES[_index]
		_bg_front.modulate.a = 1.0


func _on_Start_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_START)


func _on_select_level_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_SELECT_LEVEL)


func _on_Credits_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_CREDITS)


func _on_Quit_pressed() -> void:
	Globals.end_scene(Globals.EndSceneStatus.MAIN_MENU_CLICK_QUIT)
