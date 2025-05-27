extends Node

var global_turn_number := 1 # counts number of global turns for conditional enemy actions


func _ready() -> void:
	Events.battle_over_screen_requested.connect(reset_turn_number)

func get_turn_number() -> int:
	return global_turn_number

func turn_number_increase() -> void:
	global_turn_number += 1
	print("Global Turn Number: ", global_turn_number)

func reset_turn_number(_text, _type) -> void:
	global_turn_number = 1
	print("Global Turn Number reset")
	print("Global Turn Number: ", global_turn_number)
