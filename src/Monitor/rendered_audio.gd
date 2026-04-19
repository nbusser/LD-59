class_name RenderedAudio extends Control

# audio spectrum visualizer constants
const VU_COUNT = 32
const FREQ_MAX = 11050.0

const WIDTH = 300
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60

const SAMPLE_COUNT = 100

var _spectrum_points = PackedVector2Array()

@onready var _spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(
	AudioServer.get_bus_index("CipheredSignal"), 0
)


func _ready():
	_spectrum_points.resize(SAMPLE_COUNT)
	_spectrum_points.fill(Vector2.ZERO)


func _process(_delta: float) -> void:
	if visible:
		_update_audio_data()
		queue_redraw()


func _draw():
	# draw spectrum visualizer
	draw_polyline(_spectrum_points, Color.GREEN, 2.0, true)


func _update_audio_data() -> void:
	# inspiration from https://github.com/godotengine/godot-demo-projects/blob/master/audio/spectrum/show_spectrum.gd
	if _spectrum == null:
		return

	var data = []
	var prev_hz = 0

	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		var magnitude = _spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
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
		_spectrum_points.set(i, Vector2(x * WIDTH - WIDTH / 2.0, y))
