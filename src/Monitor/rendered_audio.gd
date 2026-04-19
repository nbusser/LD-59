class_name RenderedAudio extends Control

# audio spectrum visualizer constants
const VU_COUNT = 32
const FREQ_MAX = 11050.0

const WIDTH = 300
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60

const SAMPLE_COUNT = 100

const HEART = [
	Vector2(-0.0, 1.0),
	Vector2(-0.5, 1.4),
	Vector2(-1.0, 1.3),
	Vector2(-1.3, 0.9),
	Vector2(-1.3, 0.5),
	Vector2(-0.7, -0.2),
	Vector2(-0.0, -0.8),
	Vector2(0.7, -0.2),
	Vector2(1.3, 0.5),
	Vector2(1.3, 0.9),
	Vector2(1.0, 1.3),
	Vector2(0.5, 1.4),
	Vector2(0.0, 1.0),
]

var _spectrum_points = PackedVector2Array()
var _shape_points = PackedVector2Array()

@onready var _spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(
	AudioServer.get_bus_index("Cipher"), 0
)


func _ready():
	_spectrum_points.resize(SAMPLE_COUNT)
	_spectrum_points.fill(Vector2.ZERO)

	_shape_points.resize(HEART.size())
	for i in range(HEART.size()):
		_shape_points.set(i, HEART[i] * WIDTH / 2. * Vector2(1., -1.))


func _process(_delta: float) -> void:
	if visible:
		_update_audio_data()
		queue_redraw()


func _draw():
	# draw spectrum visualizer

	# Merge
	# TODO faire mieux comme interpolation, préservation des basses fréquences
	var v = 0.0
	var p = PackedVector2Array()
	p.resize(SAMPLE_COUNT)

	for i in range(SAMPLE_COUNT):
		var a: Vector2 = _spectrum_points.get(i)
		var i2: float = float(i) * float(_shape_points.size()) / SAMPLE_COUNT
		var i2_fract = fmod(i2, 1.0)
		var i2_int = floor(i2)
		var b = Vector2.ZERO
		if i2_int >= _shape_points.size() - 1:
			b = _shape_points[i2_int]
		elif i2_int == 0:
			b = _shape_points[0]
		else:
			b = (_shape_points[i2_int] * (1 - i2_fract) + _shape_points[i2_int + 1] * i2_fract)

		p.set(i, a.lerp(b, v))

	draw_polyline(p, Color.GREEN, 2.0, true)


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
