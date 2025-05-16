extends ThreadPassive


func activate_thread(owner: ThreadUI) -> void:
	Events.player_hand_drawn.connect(_add_mana.bind(owner), CONNECT_ONE_SHOT)


func _add_mana(owner: ThreadUI) -> void:
	owner.flash()
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		player.stats.mana += 1
