extends ThreadPassive


func activate_thread(owner: ThreadUI) -> void:
	var c := _add_mana.bind(owner)
	if not Events.player_hand_drawn.is_connected(c):
		Events.player_hand_drawn.connect(c, CONNECT_ONE_SHOT)


func _add_mana(owner: ThreadUI) -> void:
	owner.flash()
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		player.stats.mana += 1
