class_name ThreadUI
extends Control


@export var thread_passive: ThreadPassive : set = set_thread_passive

@onready var icon: TextureRect = $Icon
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_thread_passive(new_thread_passive: ThreadPassive) -> void:
	if not is_node_ready():
		await ready
	
	thread_passive = new_thread_passive
	icon.texture = thread_passive.icon


func flash() -> void:
	animation_player.play("flash")


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		Events.thread_tooltip_requested.emit(thread_passive)
