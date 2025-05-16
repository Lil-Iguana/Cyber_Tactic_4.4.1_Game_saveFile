extends ThreadPassive

@export var heal_amount := 6

func activate_thread(owner: ThreadUI) -> void:
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		player.stats.heal(heal_amount)
		owner.flash()
