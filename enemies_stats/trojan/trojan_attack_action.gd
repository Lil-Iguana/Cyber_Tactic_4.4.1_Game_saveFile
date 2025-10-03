extends EnemyAction

@export var damage := 8
@export var block := 4
@export var block_sound: AudioStream

func perform_action() -> void:
	if not enemy or not target:
		return
	
	enemy.play_attack()
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	var damage_effect := DamageEffect.new()
	var block_effect := BlockEffect.new()
	var target_array: Array[Node] = [target]
	var target_self: Array[Node] = [enemy]
	var modified_dmg := enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	
	damage_effect.amount = modified_dmg
	block_effect.amount = block
	damage_effect.sound = sound
	block_effect.sound = block_sound
	
	# The enemy lunges forward, then the damage is dealt.
	# After 0.25 seconds, the enemy returns to its position.
	tween.tween_property(enemy, "global_position", end, 0.4)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	tween.tween_interval(0.1)
	tween.tween_callback(block_effect.execute.bind(target_self))
	tween.tween_interval(0.6)
	
	# We signal the event bus that the enemy is done performing the action.
	tween.finished.connect(
		func(): 
			Events.enemy_action_completed.emit(enemy)
			enemy.play_idle()
	)

func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	var modified_damage = player.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_TAKEN)
	var final_damage = enemy.modifier_handler.get_modified_value(modified_damage, Modifier.Type.DMG_DEALT)
	intent.current_text = intent.base_text % final_damage
