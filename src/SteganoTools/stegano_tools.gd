class_name SteganoTools extends Control

@export var _sub_viewport_display: ColorRect
@export var _rendered_image: TextureRect

@onready var _green_filter = $ImageFilters/FilterGreen
@onready var _red_filter = $ImageFilters/FilterRed


func _is_stegano_image() -> bool:
	return (
		Globals.current_level.level_state.phase == LevelState.Phase.STEGANO
		and Globals.get_current_cipher().cipher_type == CipherData.CipherType.IMAGE
	)


func _on_level_phase_changed(phase: LevelState.Phase) -> void:
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
		_:
			visible = false


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
