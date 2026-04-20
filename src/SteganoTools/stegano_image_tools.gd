class_name SteganoImageTools extends Control

@export var _sub_viewport_display: ColorRect
@export var _rendered_image: TextureRect

@onready var _green_filter = $FilterGreen
@onready var _start_position_green: Vector2 = _green_filter.position

@onready var _red_filter = $FilterRed
@onready var _start_position_red: Vector2 = _red_filter.position

@onready var _magnifier = $MagnifyingGlass
@onready var _start_position_magnifier: Vector2 = _magnifier.position


func _is_stegano_image() -> bool:
	return (
		Globals.current_level.level_state.phase == LevelState.Phase.STEGANO
		and Globals.get_current_cipher().cipher_type == CipherData.CipherType.IMAGE
	)


func init():
	if _is_stegano_image():
		var cipher = Globals.get_current_cipher()
		(
			_rendered_image
			. material
			. set_shader_parameter(
				"texture_samplers",
				[
					cipher.image_texture,
					cipher.image_texture_filter_green,
					cipher.image_texture_filter_red,
				]
			)
		)
		(
			_rendered_image
			. material
			. set_shader_parameter(
				"magnified_texture_samplers",
				[
					cipher.image_texture,
					cipher.image_texture_filter_green,
					cipher.image_texture_filter_red,
				]
			)
		)

	_rendered_image.material.set_shader_parameter("enable_filter", true)
	_rendered_image.material.set_shader_parameter(
		"filter_green_size", _green_filter.get_size() / _sub_viewport_display.get_size()
	)
	_rendered_image.material.set_shader_parameter(
		"filter_red_size", _red_filter.get_size() / _sub_viewport_display.get_size()
	)

	_rendered_image.material.set_shader_parameter("enable_magnifier", true)
	_rendered_image.material.set_shader_parameter("magnifier_zoom", 2.5)

	for f in [_green_filter, _red_filter]:
		f.material.set_shader_parameter(
			"enable_filter", Globals.display_mode == CipherData.CipherType.IMAGE
		)
		f.material.set_shader_parameter(
			"screen_size", _sub_viewport_display.get_size() / f.get_size()
		)


func toggle_tools(enabled: bool) -> void:
	visible = enabled
	for f in [_green_filter, _red_filter] as Array[Control]:
		f.material.set_shader_parameter("enable_filter", enabled)
		f.visible = enabled
		f.get_node("Draggable").controllable = enabled
	_magnifier.visible = enabled
	_magnifier.get_node("Draggable").controllable = enabled
	if _rendered_image.material:
		_rendered_image.material.set_shader_parameter("enable_magnifier", enabled)
	if not enabled and is_node_ready():
		_green_filter.position = _start_position_green
		_red_filter.position = _start_position_red
		_magnifier.position = _start_position_magnifier


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

	var display_size = _sub_viewport_display.get_size()
	var lens_inner_radius = _magnifier.get_size().x * 0.8 / 2.0
	_rendered_image.material.set_shader_parameter(
		"magnifier_center",
		(
			(
				_magnifier.global_position
				+ _magnifier.get_size() / 2.0
				- _sub_viewport_display.global_position
			)
			/ display_size
		)
	)
	_rendered_image.material.set_shader_parameter(
		"magnifier_radius", Vector2(lens_inner_radius, lens_inner_radius) / display_size
	)

	for f in [_green_filter, _red_filter]:
		f.material.set_shader_parameter(
			"screen_position",
			(_sub_viewport_display.global_position - f.global_position) / f.get_size()
		)
