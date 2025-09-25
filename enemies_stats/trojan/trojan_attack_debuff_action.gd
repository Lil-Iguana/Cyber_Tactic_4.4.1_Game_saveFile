extends EnemyAction

const FRAGILE_STATUS := preload("res://statuses/fragile.tres")

@export var damage := 6

var fragile_duration := 1

func perform_action() -> void:
	if not enemy or not target:
		return
	
	enemy.play_animation("Attacking")
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	var target_array: Array[Node] = [target]
	var damage_effect := DamageEffect.new()
	var status_effect := StatusEffect.new()
	var fragile := FRAGILE_STATUS.duplicate()
	var modified_dmg := enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	damage_effect.amount = modified_dmg
	damage_effect.sound = sound
	fragile.duration = fragile_duration
	status_effect.status = fragile
	
	# The enemy lunges forward, then the damage is dealt.
	# After 0.25 seconds, the enemy returns to its position.
	tween.tween_property(enemy, "global_position", end, 0.4)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_callback(status_effect.execute.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	
	# We signal the event bus that the enemy is done performing the action.
	tween.finished.connect(
		func(): 
			Events.enemy_action_completed.emit(enemy)
	)

func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return

	var modified_damage = player.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_TAKEN)
	var final_damage = enemy.modifier_handler.get_modified_value(modified_damage, Modifier.Type.DMG_DEALT)
	intent.current_text = intent.base_text % final_damage
