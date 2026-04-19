class_name CipheredImage
extends CipheredSignal

var source: Texture2D:
	set(new_source):
		source = new_source
		_render()
var _transformed_image: Texture2D


func _ready() -> void:
	_transformed_image = source
	_render()


func _render() -> void:
	_transformed_image = source
	super()


func get_transformed_image() -> ImageTexture:
	return _transformed_image
