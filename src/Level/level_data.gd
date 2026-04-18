class_name LevelData

extends Resource

enum LevelType { CIPHERED_SIGNAL }

# In this class, put the settings of your level

@export var name := "Level"
@export var timer_duration := 100
@export var type := LevelType.CIPHERED_SIGNAL
