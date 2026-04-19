class_name CipheredText

extends CipheredSignal

# gdlint: disable=class-definitions-order


func _get_fake_source() -> String:
	var prng = RandomNumberGenerator.new()
	prng.seed = (
		Globals.current_level.name.hash() + Globals.current_level.level_state.next_cipher_index
	)

	var nb_words = prng.randi_range(5, 15)

	const CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result = ""
	for i in range(nb_words):
		var word_length = prng.randi_range(3, 10)
		for j in range(word_length):
			var char_index = prng.randi_range(0, CHARS.length() - 1)
			result += CHARS[char_index]
		if i < nb_words - 1:
			result += " "
	return result


var is_wrong_cipher_type: bool:
	get():
		return (
			Globals.current_level.level_state.current_cipher.cipher_type
			!= CipherData.CipherType.TEXT
		)

var source: String = "":
	set(new_source):
		if is_wrong_cipher_type:
			# Expect level.gd to give an empty string
			assert(new_source == "")
			new_source = _get_fake_source()

		source = new_source
		_reset()
		_render()

var _transformed_text: String = ""


func _reset() -> void:
	var prng = RandomNumberGenerator.new()
	prng.seed = source.hash()

	# "Zero values" means that the text is unfiltered.
	# We want to ensure to have strictly 10% of slider value as zero values.
	const ZERO_VALUE_TARGET_COUNT: int = int(SignalInput.N_VALUES / 10.0)

	# Regenerate the rot possibilities
	_rot_frequencies.clear()
	# Fill zero values
	for i in range(ZERO_VALUE_TARGET_COUNT):
		_rot_frequencies.append(0)
	for i in range(SignalInput.N_VALUES):
		var frequency = clamp(prng.randfn(0.35, 0.2), SignalInput.STEP, 1.0)
		_rot_frequencies.append(frequency)
	Utils.shuffle_with_prng(_rot_frequencies, prng)

	# Regenerate the splits possibilities
	_word_shuffle_n_splits.clear()
	var source_n_words: int = source.split(" ").size()
	var max_splits: int = int(log(source_n_words) / log(2))

	# Fill zero values
	for i in range(ZERO_VALUE_TARGET_COUNT):
		_word_shuffle_n_splits.append(0)
	while _word_shuffle_n_splits.size() < SignalInput.N_VALUES:
		# All the zero values are pre-filled
		var min_split = 1
		var i_split = prng.randi_range(min_split, max_splits)
		_word_shuffle_n_splits.append(i_split)

	# Shuffle the splits because of the pre inserted zeroes
	Utils.shuffle_with_prng(_word_shuffle_n_splits, prng)

	# Regenerate the space shuffle possibilities
	_space_shuffle_frequencies.clear()

	# Fill zero values
	for i in range(ZERO_VALUE_TARGET_COUNT):
		_space_shuffle_frequencies.append(0)
	while _space_shuffle_frequencies.size() < SignalInput.N_VALUES:
		# All the zero values are pre-filled
		var frequency = prng.randf_range(0 + SignalInput.STEP, 1.0)
		_space_shuffle_frequencies.append(frequency)

	# Shuffle the splits because of the pre inserted zeroes
	Utils.shuffle_with_prng(_space_shuffle_frequencies, prng)


# ----------------------------------------------------------------------------------------------------
# MARK: Helper


func _segment_text(text: String, n_segments: int, prng: RandomNumberGenerator) -> Array[String]:
	assert(n_segments >= 0)
	var words = text.split(" ")
	if words.size() == 0:
		return [text]

	var split_indices: Array[int] = []
	while split_indices.size() < n_segments - 1:
		var idx = prng.randi_range(1, words.size() - 1)
		if idx not in split_indices:
			split_indices.append(idx)
	split_indices.sort()

	var segments: Array[String] = []
	var prev = 0
	for idx in split_indices:
		segments.append(" ".join(words.slice(prev, idx)))
		prev = idx
	segments.append(" ".join(words.slice(prev, words.size())))

	return segments


# ----------------------------------------------------------------------------------------------------
# MARK: ROT

@export var rot_input: SignalInput

# Big randomized array of all possible slider values.
# Contains the portion of the source text being rotted.
# Guaranteed to contain strictly 10% of 0s (no transformation).
var _rot_frequencies: Array[float] = []

# Index of the rotation in _rot_frequencies
var letter_rot_index: int = 0:
	get():
		return letter_rot_index
	set(rot_index):
		letter_rot_index = rot_index
		_render()


func _rot_input_changed(value: float) -> void:
	var idx = int(value * _rot_frequencies.size()) % _rot_frequencies.size()
	letter_rot_index = idx


func _rot_n(text: String, slider_index: int) -> String:
	assert(_rot_frequencies.size() > 0)

	var frequency: float = _rot_frequencies[slider_index % _rot_frequencies.size()]
	if frequency == 0.0:
		return text

	var prng = RandomNumberGenerator.new()
	prng.seed = source.hash() + slider_index

	var words = text.split(" ")
	if words.size() <= 1:
		return text

	# Segmenting the text
	var max_segments = max(1, int(log(words.size()) / log(2)))
	var n_segments = prng.randi_range(1, max_segments)

	var segments = _segment_text(text, n_segments, prng)

	# Apply ROT13 on certain segments according to the frequency
	for i in range(segments.size()):
		if prng.randf() < frequency:
			segments[i] = _apply_rot13(segments[i])

	return " ".join(segments)


func _apply_rot13(text: String) -> String:
	var result := ""
	for ch in text:
		var code = ch.unicode_at(0)
		if code >= 65 and code <= 90:  # A-Z
			result += char(65 + (code - 65 + 13) % 26)
		elif code >= 97 and code <= 122:  # a-z
			result += char(97 + (code - 97 + 13) % 26)
		else:
			result += ch
	return result


# ----------------------------------------------------------------------------------------------------
# MARK: Words shuffle

@export var word_shuffle_input: SignalInput

# Index of the shuffle in _word_shuffle_n_splits
var words_shuffle_index = 0:
	get():
		return words_shuffle_index
	set(words_shuffle_index_value):
		words_shuffle_index = words_shuffle_index_value
		_render()

# Big randomized array of all possible slider values.
# Contains the number of segments shuffle.
# Guaranteed to contain strictly 10% of 0s (no transformation).
var _word_shuffle_n_splits: Array[int] = []


func _word_shuffle_input_changed(value: float) -> void:
	var idx = int(value * _word_shuffle_n_splits.size()) % _word_shuffle_n_splits.size()
	words_shuffle_index = idx


func _shuffle_words(text: String, slider_index: int) -> String:
	assert(_word_shuffle_n_splits.size() > 0)
	var n_splits = _word_shuffle_n_splits[slider_index % _word_shuffle_n_splits.size()]

	# Ensures that we always have the same splits by controlling the seed
	var prng = RandomNumberGenerator.new()
	prng.seed = source.hash() + slider_index

	var segments = _segment_text(text, n_splits, prng)

	Utils.shuffle_with_prng(segments, prng)

	return " ".join(segments)


# ----------------------------------------------------------------------------------------------------
# MARK: Space shuffle

@export var space_shuffle_input: SignalInput

# Big randomized array of all possible slider values.
# Contains the frequency of shuffling spaces.
# Guaranteed to contain strictly 10% of 0s (no transformation).
var _space_shuffle_frequencies: Array[float] = []

# Index of the shuffle in _space_shuffle_frequencies
var space_shuffle_index = 0:
	get():
		return space_shuffle_index
	set(space_shuffle_index_value):
		space_shuffle_index = space_shuffle_index_value
		_render()


func _space_shuffle_input_changed(value: float) -> void:
	var idx = int(value * _space_shuffle_frequencies.size()) % _space_shuffle_frequencies.size()
	space_shuffle_index = idx


func _shuffle_spaces(text: String, slider_index: int) -> String:
	assert(_space_shuffle_frequencies.size() > 0)
	var shuffle_frequency = _space_shuffle_frequencies[
		slider_index % _space_shuffle_frequencies.size()
	]

	var prng = RandomNumberGenerator.new()
	prng.seed = source.hash() + slider_index

	var spaces_to_move: int = 0

	var chars = text.split("")
	for i in range(chars.size()):
		if chars[i] == " " and prng.randf() < shuffle_frequency:
			chars[i] = ""
			spaces_to_move += 1

	for i in range(spaces_to_move):
		var insert_pos = prng.randi_range(0, chars.size())
		chars.insert(insert_pos, " ")
	return "".join(chars)


# ----------------------------------------------------------------------------------------------------
# MARK: Common


func _ready() -> void:
	rot_input.signal_input_changed.connect(_rot_input_changed)
	word_shuffle_input.signal_input_changed.connect(_word_shuffle_input_changed)
	space_shuffle_input.signal_input_changed.connect(_space_shuffle_input_changed)
	_reset()
	_render()


func _render():
	# Apply rot13
	_transformed_text = _rot_n(source, letter_rot_index)

	# Apply word shuffle
	_transformed_text = _shuffle_words(_transformed_text, words_shuffle_index)

	# Apply space shuffle
	_transformed_text = _shuffle_spaces(_transformed_text, space_shuffle_index)

	super()


func get_transformed_text() -> String:
	return _transformed_text
