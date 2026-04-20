class_name RenderedAudio extends Control

# audio spectrum visualizer constants
const VU_COUNT = 32
const FREQ_MAX = 11050.0

const WIDTH = 300
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60

const SAMPLE_COUNT = 100

const BALL = [
	Vector2(0.2500, 0.0000),
	Vector2(0.2310, 0.0957),
	Vector2(0.1768, 0.1768),
	Vector2(0.0957, 0.2310),
	Vector2(0.0000, 0.2500),
	Vector2(-0.0957, 0.2310),
	Vector2(-0.1768, 0.1768),
	Vector2(-0.2310, 0.0957),
	Vector2(-0.2500, 0.0000),
	Vector2(-0.2310, -0.0957),
	Vector2(-0.1768, -0.1768),
	Vector2(-0.0957, -0.2310),
	Vector2(0.0000, -0.2500),
	Vector2(0.0957, -0.2310),
	Vector2(0.1768, -0.1768),
	Vector2(0.2310, -0.0957),
	Vector2(0.2500, 0.0000),
]

const HAIRCUT = [
	Vector2(0.0000, -0.2800),
	Vector2(0.1200, -0.2200),
	Vector2(0.2000, -0.0800),
	Vector2(0.2000, 0.0800),
	Vector2(0.1800, 0.2000),
	Vector2(0.1000, 0.3000),
	Vector2(-0.0500, 0.3200),
	Vector2(-0.1800, 0.2800),
	Vector2(-0.2200, 0.1600),
	Vector2(-0.2000, 0.0000),
	Vector2(-0.2000, -0.1000),
	Vector2(-0.1200, -0.2200),
	Vector2(0.0000, -0.2800),
]

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

var noise_volume: float = 1.0
var _spectrum_points = PackedVector2Array()
var _shape_points = PackedVector2Array()
var _frequency_shape = 0.0
var _active_shape: CipherData.CipheredAudioShape = CipherData.CipheredAudioShape.NOTHING

@onready var _spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(
	AudioServer.get_bus_index("Cipher"), 0
)


func _ready():
	_spectrum_points.resize(SAMPLE_COUNT)
	_spectrum_points.fill(Vector2.ZERO)
	_rebuild_shape_points()


func _get_shape_const() -> Array:
	match _active_shape:
		CipherData.CipheredAudioShape.SHADES:
			return SHADES
		CipherData.CipheredAudioShape.BALL:
			return BALL
		CipherData.CipheredAudioShape.HAIRCUT:
			return HAIRCUT
		_:
			return SHADES


func _rebuild_shape_points() -> void:
	var pts = _get_shape_const()
	_shape_points.resize(pts.size())
	for i in range(pts.size()):
		_shape_points.set(i, pts[i] * WIDTH * Vector2(1., -1.))


func set_shape(shape: CipherData.CipheredAudioShape) -> void:
	_active_shape = shape
	if shape != CipherData.CipheredAudioShape.NOTHING:
		_rebuild_shape_points()


func _process(_delta: float) -> void:
	if visible:
		_update_audio_data()
		queue_redraw()


func _draw():
	# draw spectrum visualizer

	# Merge
	# TODO faire mieux comme interpolation, préservation des basses fréquences
	var v = _frequency_shape
	var v_lerp = v if _active_shape != CipherData.CipheredAudioShape.NOTHING else 0.0
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

		p.set(i, a.lerp(b, v_lerp))
		# p.set(i, a.lerp(b, 0))

	draw_polyline(p, Color.GREEN, 2.0, true)


func _update_audio_data() -> void:
	# inspiration from https://github.com/godotengine/godot-demo-projects/blob/master/audio/spectrum/show_spectrum.gd
	if _spectrum == null:
		return

	var v = _frequency_shape
	var data = []

	if _spectrum.get_magnitude_for_frequency_range(100, 4000).length() == 0.0:
		var t = Time.get_ticks_msec() / 1000.0
		for j in range(VU_COUNT):
			var freq_norm = float(j) / VU_COUNT
			var falloff = 1.0 / (1.0 + freq_norm * 6.0)

			var breath = 0.5 + 0.5 * sin(t * 0.8 * 4. + j * 0.3)

			var peak1 = exp(-pow((freq_norm - (0.15 + 0.08 * sin(t * 0.3))) * 12.0, 2.0))
			var peak2 = exp(-pow((freq_norm - (0.45 + 0.10 * sin(t * 0.17))) * 10.0, 2.0)) * 0.5
			var shimmer = 0.5 + 0.5 * sin(t * (3.0 + j * 0.4) + j * 1.3)

			var shape = (
				((falloff * 0.6 + peak1 * 0.9 + peak2 * 0.5) * breath * (0.75 + 0.25 * shimmer))
				* (1 + noise_volume)
			)
			data.append(clampf(shape, 0.0, 1.0))
	else:
		var prev_hz = 0
		for i in range(1, VU_COUNT + 1):
			var hz = i * (FREQ_MAX * (1 + v)) / VU_COUNT
			var magnitude = _spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
			data.append(energy)
			prev_hz = hz

	for i in range(SAMPLE_COUNT):
		var x = float(i) / SAMPLE_COUNT
		var y = 0.0
		for j in range(VU_COUNT):
			y += sin(x * (j + 1) * PI * 4) * data[j]
		y /= VU_COUNT
		y *= HEIGHT * 5
		_spectrum_points.set(i, Vector2(x * WIDTH - WIDTH / 2.0, y))


func set_frequency_shape(value: float) -> void:
	_frequency_shape = value
