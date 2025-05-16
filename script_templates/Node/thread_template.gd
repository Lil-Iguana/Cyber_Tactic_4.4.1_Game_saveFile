# meta-name: Relic
# meta-description: Create a Relic which can be acquired by the player.
extends ThreadPassive

var member_var := 0


func initialize_thread(_owner: ThreadUI) -> void:
	print("this happens once when we gain a new thread")


func activate_thread(_owner: ThreadUI) -> void:
	print("this happens at a specific times based on the Thread.Type property")


func deactivate_thread(_owner: ThreadUI) -> void:
	print("this gets called when a ThreadUI is exiting the SceneTree i.e. getting deleted")
	print("Event-based Relics should disconnect from the EventBus here.")


func get_tooltip() -> String:
	return tooltip
