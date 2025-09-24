class_name RefineStatus
extends Status

func initialize_status(target):
	status_changed.connect(_on_status_changed.bind(target))
	_on_status_changed(target)

func _on_status_changed(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)
	
	var block_gained_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.BLOCK_GAINED)
	assert(block_gained_modifier, "No block_gained_modifier on %s" % target)
	
	var refine_modifier_value := block_gained_modifier.get_value("refine")
	
	if not refine_modifier_value:
		refine_modifier_value = ModifierValue.create_new_modifier("refine", ModifierValue.Type.FLAT)
	
	refine_modifier_value.flat_value = stacks
	block_gained_modifier.add_new_value(refine_modifier_value)

func get_tooltip() -> String:
	return tooltip % stacks
