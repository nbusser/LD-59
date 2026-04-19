@tool
class_name CipherData
extends Resource

enum CipherType {
	TEXT = 0,
	IMAGE = 1,
	AUDIO = 2,
}

@export var cipher_type: CipherType = CipherType.TEXT:
	set(v):
		cipher_type = v
		text_content = ""
		image_texture = null
		image_texture_filter_green = null
		image_texture_filter_red = null
		audio_stream = null
		notify_property_list_changed()

# Only the relevant property is shown
@export var text_content: String = ""

@export var image_texture: Texture2D = null
@export var image_texture_filter_green: Texture2D = null
@export var image_texture_filter_red: Texture2D = null

@export var audio_stream: AudioStream = null

@export var is_disco: bool = false


func _validate_property(property: Dictionary) -> void:
	if property.name == "text_content":
		if cipher_type != CipherType.TEXT:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "image_texture":
		if cipher_type != CipherType.IMAGE:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "image_texture_filter_green":
		if cipher_type != CipherType.IMAGE:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "image_texture_filter_red":
		if cipher_type != CipherType.IMAGE:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "audio_stream":
		if cipher_type != CipherType.AUDIO:
			property.usage = PROPERTY_USAGE_NO_EDITOR
