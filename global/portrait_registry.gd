extends Node

# Preload the portraits and tutorial images you need.
# Using preloads guarantees the resources are included in exported builds.
# Map keys can be friendly names you use in JSON (e.g. "cortana", "battle_ui").
static var PORTRAITS: Dictionary = {
	"cortana": preload("res://art/cortana.png"),
	"cortana_sleep": preload("res://art/cortana_sleep.png"),
	"cortana_look_down": preload("res://art/cortana_lookdown.png"),
	"student": preload("res://art/pixil-frame-0.png"),
	"default": preload("res://art/question_mark.png")
}

static var TUTORIAL_IMAGES: Dictionary = {
	"cards_demo": preload("res://art/cards_demo.png"),
	"icons_demo": preload("res://art/icons_demo.png"),
	"testing": preload("res://art/illustrations/testing_placeholder.png")
}

func get_portrait(key_or_path: String) -> Texture2D:
	if key_or_path == "":
		return PORTRAITS.get("default", null)
	if PORTRAITS.has(key_or_path):
		return PORTRAITS[key_or_path]
	# fallback to load path if it exists
	if ResourceLoader.exists(key_or_path):
		var r = ResourceLoader.load(key_or_path)
		if r and r is Texture2D:
			return r
	return PORTRAITS.get("default", null)

func get_tutorial_image(key_or_path: String) -> Texture2D:
	if key_or_path == "":
		return null
	if TUTORIAL_IMAGES.has(key_or_path):
		return TUTORIAL_IMAGES[key_or_path]
	if ResourceLoader.exists(key_or_path):
		var r = ResourceLoader.load(key_or_path)
		if r and r is Texture2D:
			return r
	return null
