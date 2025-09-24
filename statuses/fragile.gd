class_name FragileStatus
extends Status

const MODIFIER := -0.25

func initialize_status(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)
	
	var block_gained_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.BLOCK_GAINED)
	assert(block_gained_modifier, "No block_gained_modifier on %s" % target)
	
	var fragile_modifier_value := block_gained_modifier.get_value("fragile")
	
	if not fragile_modifier_value:
		fragile_modifier_value = ModifierValue.create_new_modifier("fragile", ModifierValue.Type.PERCENT_BASED)
		fragile_modifier_value.percent_value = MODIFIER
		block_gained_modifier.add_new_value(fragile_modifier_value)
	
	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(block_gained_modifier))

func _on_status_changed(block_gained_modifier: Modifier) -> void:
	if duration <= 0 and block_gained_modifier:
		block_gained_modifier.remove_value("fragile")

func get_tooltip() -> String:
	return tooltip % duration
