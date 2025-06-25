extends CardState

@onready var player_node = get_tree().get_first_node_in_group("player") as Player

var played: bool


func enter() -> void:
	played = false
	
	if not card_ui.targets.is_empty():
		Events.tooltip_hide_requested.emit()
		played = true
		card_ui.play()
		if player_node:
			var model_node: Node = player_node.model_3d.get_child(0)
			if model_node.has_node("AnimationPlayer"):
				var anim_player := model_node.get_node("AnimationPlayer") as AnimationPlayer
				if anim_player.has_animation("Attacking"):
					anim_player.play("Attacking")
			
					# Wait for animation to finish, then go to Idle
					anim_player.animation_finished.connect(
						func(anim_name):
							if anim_name == "Attacking":
								anim_player.play("Idle"),
						CONNECT_ONE_SHOT  # Optional: only connect once
			)


func post_enter() -> void:
	transition_requested.emit(self, CardState.State.BASE)
	if player_node:
		var model_node: Node = player_node.model_3d.get_child(0)
		if model_node.has_node("AnimationPlayer"):
			var anim_player := model_node.get_node("AnimationPlayer") as AnimationPlayer
			if anim_player.has_animation("Attacking"):
				anim_player.play("Attacking")
			
				# Wait for animation to finish, then go to Idle
				anim_player.animation_finished.connect(
					func(anim_name):
						if anim_name == "Attacking":
							anim_player.play("Idle"),
					CONNECT_ONE_SHOT  # Optional: only connect once
				)
