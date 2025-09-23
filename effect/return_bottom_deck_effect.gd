class_name ReturnBottomDeckEffect
extends Effect

func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		print("no target")
		return

	var player_handler := targets[0].get_tree().get_first_node_in_group("player_handler") as PlayerHandler

	if not player_handler:
		print("no player handler")
		return

	# connect the card_chosen signal if it's not already, and request the view
	if not Events.card_chosen.is_connected(player_handler.return_to_bottom_deck):
		Events.card_chosen.connect(player_handler.return_to_bottom_deck, CONNECT_ONE_SHOT)
		
	Events.hand_choice_requested.emit("Choose a card")
