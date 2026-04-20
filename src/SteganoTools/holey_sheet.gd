@tool
class_name HoleySheet
extends Control

@export var cipher_data: CipherData = null:
	set(value):
		cipher_data = value
		_update_holes.call_deferred()

@export var overlay_texture: Texture2D:
	set(value):
		overlay_texture = value
		if overlay_texture_rect:
			overlay_texture_rect.texture = value

@onready var rendered_text: RichTextLabel = %RenderedText
@onready var overlay_texture_rect: TextureRect = %OverlayTextureRect


func _ready() -> void:
	overlay_texture_rect.texture = overlay_texture
	_update_holes()


func _update_holes() -> void:
	if cipher_data == null:
		rendered_text.text = ""

	var text = ""

	var indexes = Utils.get_hidden_text_indexes(
		cipher_data.text_content, cipher_data.hidden_text_content
	)

	for i in range(cipher_data.text_content.length()):
		if cipher_data.text_content[i] == "\n":
			text += "\n"
		elif cipher_data.text_content[i] == " ":
			text += " "
		elif indexes.has(i):
			# print(i, " ", cipher_data.text_content[i])
			text += "█"
		else:
			# text += cipher_data.text_content[i]
			text += " "

	rendered_text.text = text
