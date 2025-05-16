class_name PowerUpStatus
extends Status


func get_tooltip() -> String:
	return tooltip % stacks


func initialize_status(target: Node) -> void:
	status_changed.connect(_on_status_changed.bind(target))
	_on_status_changed(target)


func _on_status_changed(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)
	
	var dmg_dealt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "No dmg_dealt_modifier on %s" % target)
	
	var power_up_modifier_value := dmg_dealt_modifier.get_value("power_up")
	
	if not power_up_modifier_value:
		power_up_modifier_value = ModifierValue.create_new_modifier("power_up", ModifierValue.Type.FLAT)
	
	power_up_modifier_value.flat_value = stacks
	dmg_dealt_modifier.add_new_value(power_up_modifier_value)
