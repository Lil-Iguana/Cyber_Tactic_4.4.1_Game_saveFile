extends Node

# Preload your character model scenes here. Update paths/keys to match your project.
# Using preloads guarantees the resources are included in exported builds.
static var MODELS: Dictionary = {
	"cortana": preload("res://art/3d_models/cortana_3DModel.tscn")
	# add more keys here...
}

func get_model(key_or_path: String) -> PackedScene:
	if key_or_path == "":
		return null
	# prefer key lookup
	if MODELS.has(key_or_path):
		return MODELS[key_or_path] as PackedScene
	# fallback to treating value as res:// path
	if ResourceLoader.exists(key_or_path):
		var loaded := ResourceLoader.load(key_or_path)
		if loaded and loaded is PackedScene:
			return loaded as PackedScene
	return null
