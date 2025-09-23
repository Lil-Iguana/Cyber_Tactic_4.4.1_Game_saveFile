class_name LoseHealthEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		print("no target")
		return

	var player := targets[0].get_tree().get_first_node_in_group("player") as Player
	player.lose_health(amount)
	SFXPlayer.play(sound)
