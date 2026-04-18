extends Node


# Cannot use shuffle() when using a custom PRNG
func shuffle_with_prng(array: Array, prng: RandomNumberGenerator):
	for i in range(array.size() - 1, 0, -1):
		var j = prng.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp
