extends EnemyAction

@export var block := 6


func perform_action() -> void:
	if not enemy or not target:
		return
	
	enemy.play_casting()
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.sound = sound
	block_effect.execute([enemy])
	
	get_tree().create_timer(2.6, false).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
			enemy.play_idle()
	)
