extends EnemyAction

const WEAKENED_STATUS := preload("res://statuses/weakened.tres")
const FRAGILE_STATUS := preload("res://statuses/fragile.tres")

@export var block := 12

var status_duration := 1

func perform_action() -> void:
	if not enemy or not target:
		return
	
	enemy.play_animation("Casting")
	var player := target as Player
	if not player:
		return
	
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.sound = sound
	block_effect.execute([enemy])
	
	var status_effect := StatusEffect.new()
	var weakened := WEAKENED_STATUS.duplicate()
	weakened.duration = status_duration
	status_effect.status = weakened
	status_effect.execute([player])
	
	var status_effect_02 := StatusEffect.new()
	var frail := FRAGILE_STATUS.duplicate()
	frail.duration = status_duration
	status_effect_02.status = frail
	status_effect_02.execute([player])
	
	get_tree().create_timer(0.6, false).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
