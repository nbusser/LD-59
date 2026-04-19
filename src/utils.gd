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
