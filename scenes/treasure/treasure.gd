class_name Treasure
extends Control

@export var treasure_thread_pool: Array[ThreadPassive]
@export var thread_handler: ThreadHandler
@export var char_stats: CharacterStats

@onready var animation_player: AnimationPlayer = %AnimationPlayer
var found_thread: ThreadPassive


func generate_thread() -> void:
	var available_threads := treasure_thread_pool.filter(
		func(thread: ThreadPassive):
			var can_appear := thread.can_appear_as_reward(char_stats)
			var already_had_it := thread_handler.has_thread(thread.id)
			return can_appear and not already_had_it
	)
	found_thread = RNG.array_pick_random(available_threads)


# Called from the AnimationPlayer, at the
# end of the 'open' animation.
func _on_treasure_opened() -> void:
	Events.treasure_room_exited.emit(found_thread)


func _on_treasure_chest_gui_input(event: InputEvent) -> void:
	if animation_player.current_animation == "open":
		return
	
	if event.is_action_pressed("left_mouse"):
		animation_player.play("open")
