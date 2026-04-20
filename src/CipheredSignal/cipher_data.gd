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
		alternative_content = ""
		hidden_text_content = ""
		image_texture = null
		image_texture_filter_green = null
		image_texture_filter_red = null
		audio_stream_1 = null
		audio_stream_2 = null
		audio_stream_3 = null
		success_message = ""
		fail_message = ""
		notify_property_list_changed()

# Only the relevant property is shown
@export_multiline var text_content: String = ""
@export_multiline var alternative_content: String = ""
@export var hidden_text_content: String = ""

@export var image_texture: Texture2D = null
@export var image_texture_filter_green: Texture2D = null
@export var image_texture_filter_red: Texture2D = null

@export var audio_stream_1: AudioTrack = null
@export var audio_stream_2: AudioTrack = null
@export var audio_stream_3: AudioTrack = null

@export var is_disco: bool = false

@export var success_message: String = ""
@export var fail_message: String = ""


func _validate_property(property: Dictionary) -> void:
	if property.name == "text_content":
		if cipher_type != CipherType.TEXT:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "alternative_content":
		if cipher_type != CipherType.TEXT:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "hidden_text_content":
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
	elif property.name == "audio_stream_1":
		if cipher_type != CipherType.AUDIO:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "audio_stream_2":
		if cipher_type != CipherType.AUDIO:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "audio_stream_3":
		if cipher_type != CipherType.AUDIO:
			property.usage = PROPERTY_USAGE_NO_EDITOR
