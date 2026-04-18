class_name Monitor extends Control

# audio spectrum visualizer constants
const VU_COUNT = 32
const FREQ_MAX = 11050.0

const WIDTH = 300
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60

const SAMPLE_COUNT = 100

@export var ciphered_text: CipheredText
@export var ciphered_image: CipheredImage
@export var ciphered_audio: CipheredAudio

var spectrum: AudioEffectSpectrumAnalyzerInstance
var spectrum_points = PackedVector2Array()

var _current_selection: CipherData.CipherType = CipherData.CipherType.TEXT:
	set(value):
		_current_selection = value
		_display_cipher()

@onready var _rendered_text = $Signal/RenderedText
@onready var _rendered_image = $Signal/RenderedImage
@onready var _rendered_audio = $Signal/RenderedAudio


func _ready() -> void:
	_display_cipher()
	ciphered_text.on_render.connect(_on_text_render)

	# setup spectrum visualizer
	spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("CipheredSignal"), 0)
	spectrum_points.resize(SAMPLE_COUNT)
	spectrum_points.fill(Vector2.ZERO)


func _display_cipher():
	match _current_selection:
		CipherData.CipherType.TEXT:
			_rendered_text.visible = true
			_rendered_image.visible = false
			_rendered_audio.visible = false
		CipherData.CipherType.IMAGE:
			_rendered_text.visible = false
			_rendered_image.visible = true
			_rendered_audio.visible = false
		CipherData.CipherType.AUDIO:
			_rendered_text.visible = false
			_rendered_image.visible = false
			_rendered_audio.visible = true


func _draw():
	match _current_selection:
		CipherData.CipherType.AUDIO:
			# draw spectrum visualizer
			draw_polyline(spectrum_points, Color.GREEN, 2.0, true)


func _process(_delta: float) -> void:
	match _current_selection:
		CipherData.CipherType.AUDIO:
			_update_audio_data()
			queue_redraw()


func _update_audio_data() -> void:
	# inspiration from https://github.com/godotengine/godot-demo-projects/blob/master/audio/spectrum/show_spectrum.gd
	if spectrum == null:
		return

	var data = []
	var prev_hz = 0

	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		data.append(energy)
		prev_hz = hz

	for i in range(SAMPLE_COUNT):
		var x = float(i) / SAMPLE_COUNT  # 0-1
		var y = 0
		for j in range(VU_COUNT):
			y += sin(x * (j + 1) * PI * 4) * data[j]
		y /= VU_COUNT
		y *= HEIGHT * 5
		spectrum_points.set(i, Vector2(x * WIDTH - WIDTH / 2.0, y))


func _on_text_render() -> void:
	_rendered_text.text = ciphered_text.get_transformed_text()


func _on_image_render() -> void:
	# TODO
	print("Image render: TODO")


func _on_audio_render() -> void:
	print("Audio render: TODO")


func _on_level_new_cipher_loaded(cipher_data: CipherData) -> void:
	_current_selection = cipher_data.cipher_type
