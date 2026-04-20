class_name RenderedAudio extends Control

# audio spectrum visualizer constants
const VU_COUNT = 32
const FREQ_MAX = 11050.0

const WIDTH = 300
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60

const SAMPLE_COUNT = 100

const SHADES = [
	Vector2(-0.0683, -0.0231),
	Vector2(-0.1550, 0.0268),
	Vector2(-0.1126, 0.1338),
	Vector2(-0.2141, 0.0581),
	Vector2(-0.3081, 0.1338),
	Vector2(-0.2786, 0.0397),
	Vector2(-0.3635, -0.0194),
	Vector2(-0.2546, -0.0212),
	Vector2(-0.2196, -0.1338),
	Vector2(-0.1735, -0.0212),
	Vector2(-0.0683, -0.0231),
	Vector2(-0.0258, 0.0065),
	Vector2(0.0000, 0.0286),
	Vector2(0.0000, 0.0286),
	Vector2(0.0258, 0.0065),
	Vector2(0.0683, -0.0231),
	Vector2(0.1735, -0.0212),
	Vector2(0.2196, -0.1338),
	Vector2(0.2546, -0.0212),
	Vector2(0.3635, -0.0194),
	Vector2(0.2786, 0.0397),
	Vector2(0.3081, 0.1338),
	Vector2(0.2141, 0.0581),
	Vector2(0.1126, 0.1338),
	Vector2(0.1550, 0.0268),
	Vector2(0.0683, -0.0231),
]

var _spectrum_points = PackedVector2Array()
var _shape_points = PackedVector2Array()
var _frequency_shape = 0.0

@onready var _spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(
	AudioServer.get_bus_index("Cipher"), 0
)


func _ready():
	_spectrum_points.resize(SAMPLE_COUNT)
	_spectrum_points.fill(Vector2.ZERO)

	_shape_points.resize(SHADES.size())
	for i in range(SHADES.size()):
		_shape_points.set(i, SHADES[i] * WIDTH / 1. * Vector2(1., -1.))


func _process(_delta: float) -> void:
	if visible:
		_update_audio_data()
		queue_redraw()


func _draw():
	# draw spectrum visualizer

	# Merge
	# TODO faire mieux comme interpolation, préservation des basses fréquences
	# var v = 0.0
	var v = _frequency_shape
	var p = PackedVector2Array()
	var t = Time.get_ticks_msec()
	p.resize(SAMPLE_COUNT)

	for i in range(SAMPLE_COUNT):
		var a: Vector2 = _spectrum_points.get(i)
		a.y = _spectrum_points.get(int(i + float(SAMPLE_COUNT) * v) % SAMPLE_COUNT).y
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

		# distort b with frequency sin
		# var freq = i * FREQ_MAX / SAMPLE_COUNT
		var freq = b.x * FREQ_MAX / WIDTH
		b.y += .015 * WIDTH * sin(t * freq / 1000.0 * 1.) * sin(t * freq / 1000.0 * .2)

		p.set(i, a.lerp(b, v))
		# p.set(i, a.lerp(b, 0))

	draw_polyline(p, Color.GREEN, 2.0, true)


func _update_audio_data() -> void:
	# inspiration from https://github.com/godotengine/godot-demo-projects/blob/master/audio/spectrum/show_spectrum.gd
	if _spectrum == null:
		return

	var v = _frequency_shape

	var data = []
	var prev_hz = 0

	for i in range(1, VU_COUNT + 1):
		var hz = i * (FREQ_MAX * (1 + v)) / VU_COUNT
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


func set_frequency_shape(value: float) -> void:
	_frequency_shape = value
