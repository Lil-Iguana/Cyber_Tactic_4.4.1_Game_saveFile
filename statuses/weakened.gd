class_name WeakenedStatus
extends Status

const MODIFIER := -0.25

func initialize_status(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)
	
	var dmg_dealt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "No dmg_dealt_modifier on %s" % target)
	
	var weakened_modifier_value := dmg_dealt_modifier.get_value("weakened")
	
	if not weakened_modifier_value:
		weakened_modifier_value = ModifierValue.create_new_modifier("weakened", ModifierValue.Type.PERCENT_BASED)
		weakened_modifier_value.percent_value = MODIFIER
		dmg_dealt_modifier.add_new_value(weakened_modifier_value)
	
	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(dmg_dealt_modifier))

func _on_status_changed(dmg_dealt_modifier: Modifier) -> void:
	if duration <= 0 and dmg_dealt_modifier:
		dmg_dealt_modifier.remove_value("weakened")

func get_tooltip() -> String:
	return tooltip % duration
