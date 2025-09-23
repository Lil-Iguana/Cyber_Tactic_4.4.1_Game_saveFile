class_name CheckCardTypeInHand
extends Effect

var type_to_check: Card.Type

func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		print("no target")
		return

	var player_handler := targets[0].get_tree().get_first_node_in_group("player_handler") as PlayerHandler

	if not player_handler:
		print("no player handler")
		return

	for card_ui: CardUI in player_handler.hand.get_children():
		if card_ui.card.type == type_to_check:
			Events.card_type_found_in_hand.emit(true)
			return
	
	Events.card_type_found_in_hand.emit(false)
