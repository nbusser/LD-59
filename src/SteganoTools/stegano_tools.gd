class_name SteganoTools extends Control

@export var _sub_viewport_display: ColorRect
@export var _rendered_image: TextureRect

var _display_mode: CipherData.CipherType = CipherData.CipherType.TEXT

@onready var _green_filter = $ImageFilters/FilterGreen
@onready var _start_position_green: Vector2 = _green_filter.position

@onready var _red_filter = $ImageFilters/FilterRed
@onready var _start_position_red: Vector2 = _red_filter.position


func _is_stegano_image() -> bool:
	return (
		Globals.current_level.level_state.phase == LevelState.Phase.STEGANO
		and Globals.get_current_cipher().cipher_type == CipherData.CipherType.IMAGE
	)


func _ready():
	visible = false


func _on_level_phase_changed(phase: LevelState.Phase) -> void:
	# Pase system is unused now
	match phase:
		LevelState.Phase.STEGANO:
			visible = true
			if _is_stegano_image():
				_rendered_image.material.set_shader_parameter("enable_filter", true)
				_rendered_image.material.set_shader_parameter(
					"stegano_texture_sampler_green",
					Globals.get_current_cipher().image_texture_filter_green
				)
				_rendered_image.material.set_shader_parameter(
					"filter_green_size", _green_filter.get_size() / _sub_viewport_display.get_size()
				)
				_rendered_image.material.set_shader_parameter(
					"stegano_texture_sampler_red",
					Globals.get_current_cipher().image_texture_filter_red
				)
				_rendered_image.material.set_shader_parameter(
					"filter_red_size", _red_filter.get_size() / _sub_viewport_display.get_size()
				)

				for f in [_green_filter, _red_filter]:
					f.material.set_shader_parameter(
						"enable_filter", _display_mode == CipherData.CipherType.IMAGE
					)
					f.material.set_shader_parameter(
						"screen_size", _sub_viewport_display.get_size() / f.get_size()
					)
		_:
			visible = false


func _on_command_panel_cipher_type_selected(cipher_type: CipherData.CipherType) -> void:
	_display_mode = cipher_type
	var is_image := cipher_type == CipherData.CipherType.IMAGE
	for f in [_green_filter, _red_filter]:
		if f:
			f.material.set_shader_parameter("enable_filter", is_image)
			f.visible = is_image
	if not is_image and is_node_ready():
		_green_filter.position = _start_position_green
		_red_filter.position = _start_position_red


func _process(_delta: float):
	if not _is_stegano_image():
		return

	_rendered_image.material.set_shader_parameter(
		"filter_green_position",
		(
			(_green_filter.global_position - _sub_viewport_display.global_position)
			/ _sub_viewport_display.get_size()
		)
	)
	_rendered_image.material.set_shader_parameter(
		"filter_red_position",
		(
			(_red_filter.global_position - _sub_viewport_display.global_position)
			/ _sub_viewport_display.get_size()
		)
	)

	for f in [_green_filter, _red_filter]:
		f.material.set_shader_parameter(
			"screen_position",
			(_sub_viewport_display.global_position - f.global_position) / f.get_size()
		)
