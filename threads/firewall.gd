extends ThreadPassive

@export var block := 5

var thread_ui: ThreadUI

func initialize_relic(owner: ThreadUI) -> void:
	thread_ui = owner
	Events.player_press_end_turn_button.connect(_on_player_press_end_turn_button)


func deactivate_relic(_owner: ThreadUI) -> void:
	Events.player_press_end_turn_button.disconnect(_on_player_press_end_turn_button)

func _on_player_press_end_turn_button(targets: Array[Node]) -> void:
	var player := targets[0].get_tree().get_nodes_in_group("player")[0] as Player
	if player.stats.block == 0:
		var block_effect := BlockEffect.new()
		block_effect.amount = block
		block_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
		block_effect.execute([player])
		
		thread_ui.flash()
