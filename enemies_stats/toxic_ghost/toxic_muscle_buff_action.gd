extends EnemyAction

const POWER_STATUS = preload("res://statuses/power_up.tres")

@export var stacks_per_action := 2

var hp_threshold := 10
var usages := 0


func is_performable() -> bool:
	var hp_under_threshold := enemy.stats.health <= hp_threshold
	
	if usages == 0 or (usages == 1 and hp_under_threshold):
		usages += 1
		return true
	
	return false


func perform_action() -> void:
	if not enemy or not target:
		return
	
	var status_effect := StatusEffect.new()
	var power := POWER_STATUS.duplicate()
	power.stacks = stacks_per_action
	status_effect.status = power
	status_effect.execute([enemy])
	
	SFXPlayer.play(sound)
	
	Events.enemy_action_completed.emit(enemy)
