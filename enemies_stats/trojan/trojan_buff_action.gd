extends EnemyAction

const POWER_UP_STATUS := preload("res://statuses/power_up.tres")

var base_block := 10
var usages := 0
var stacks_per_action := 1

func is_performable() -> bool:
	if usages == 0 and GlobalTurnNumber.get_turn_number() == 2:
		usages += 1
		return true
	
	return false

func perform_action():
	if not enemy or not target:
		return
	
	enemy.play_casting()
	
	var block_effect := BlockEffect.new()
	block_effect.amount = base_block
	block_effect.sound = sound
	block_effect.execute([enemy])
	
	var status_effect := StatusEffect.new()
	var power := POWER_UP_STATUS.duplicate()
	power.stacks = stacks_per_action
	status_effect.status = power
	status_effect.execute([enemy])
	
	Events.enemy_action_completed.emit(enemy)
