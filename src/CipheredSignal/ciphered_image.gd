class_name CipheredImage
extends CipheredSignal

var source: Image
var _transformed_image: ImageTexture


func _ready() -> void:
	pass


func _render() -> void:
	_transformed_image = ImageTexture.create_from_image(source)
	super()


func get_transformed_image() -> ImageTexture:
	return _transformed_image
