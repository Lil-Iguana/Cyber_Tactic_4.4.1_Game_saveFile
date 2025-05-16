class_name CardDrawEffect
extends Effect

var cards_to_draw := 1


func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		print("no target")
		return

	var player_handler := targets[0].get_tree().get_first_node_in_group("player_handler") as PlayerHandler

	if not player_handler:
		print("no player handler")
		return

	player_handler.draw_cards_from_effect(cards_to_draw)
