extends Node

class_name SignalInput

signal signal_input_changed(value: float)

# 0.0 -> 1.0
var amount: float = 0.5:
    get(): return amount
    set(new_amount):
        amount = new_amount
        emit_signal("signal_input_changed", amount)

