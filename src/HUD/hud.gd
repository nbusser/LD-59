class_name HUD

extends Control

var level_name: String:
	set = set_level_name

var nb_coins: int:
	set = set_nb_coins

var level_number: int:
	set = set_level_number

@onready var level_number_label: Label = $VBoxContainer/VBoxContainer/LevelNumber/LevelNumberValue
@onready var coins_label: Label = $VBoxContainer/VBoxContainer/CoinNumber/CoinNumberValue
@onready var level_name_label: Label = $VBoxContainer/CenterContainer/LevelNameValue


func set_level_name(value: String) -> void:
	level_name_label.text = value


func set_nb_coins(value: int) -> void:
	coins_label.text = str(value)


func set_level_number(value: int) -> void:
	level_number_label.text = str(value)


func init(level_state: LevelState) -> void:
	level_name = level_state.level_data.name
