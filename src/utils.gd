extends Node


# Cannot use shuffle() when using a custom PRNG
func shuffle_with_prng(array: Array, prng: RandomNumberGenerator):
	for i in range(array.size() - 1, 0, -1):
		var j = prng.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp


# Allows sliders to be 0 -> 1 -> 0
func wrap_triangle(value: float, offset: float) -> float:
	var shifted: float = fmod(value + offset, SignalInput.MAX_VALUE * 2)
	if shifted <= SignalInput.MAX_VALUE:
		return shifted
	return (SignalInput.MAX_VALUE * 2) - shifted


# map 0 -> 1 to 0 -> 1 -> 0, 1 being at the offset.
# f(0) = 0
# f(offset) = 1
# f(1) = 0
func map_triangle(x: float, offset: float) -> float:
	if x <= offset:
		return x / offset
	return 1 - (x - offset) / (1 - offset)


# map 0 -> 1 to -1 -> 0 -> 1, 0 being at the offset.
# f(0) = -1
# f(offset - margin_around_zero) = 0
# f(offset + margin_around_zero) = 0
# f(1) = 1
func map_triangle_ascending(x: float, offset: float, margin_around_zero: float = 0.0) -> float:
	var low = offset - margin_around_zero
	var high = offset + margin_around_zero
	if x <= low:
		return (x / low) - 1.0
	if x <= high:
		return 0.0
	return (x - high) / (1.0 - high)
