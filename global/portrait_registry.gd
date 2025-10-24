extends Node

# Preload the portraits and tutorial images you need.
# Using preloads guarantees the resources are included in exported builds.
# Map keys can be friendly names you use in JSON (e.g. "cortana", "battle_ui").
static var PORTRAITS: Dictionary = {
	"cortana": preload("res://art/portrait_cortana.jpg"),
	"cortana_sleep": preload("res://art/portrait_cortana_sleep.jpg"),
	"cortana_look_down": preload("res://art/portrait_cortana_lookdown.jpg"),
	"cortana_serious": preload("res://art/portrait_cortana_serious.jpg"),
	"student": preload("res://art/portrait_student.jpg"),
	"hacker": preload("res://art/hacker.png"),
	"shopkeeper": preload("res://art/shopkeeper.png"),
	"default": preload("res://art/question_mark.png")
}

static var TUTORIAL_IMAGES: Dictionary = {
	"cards_demo": preload("res://art/cards_demo.png"),
	"icons_demo": preload("res://art/icons_demo.png"),
	"ransom_shadow": preload("res://art/illustrations/Ransom_Shad.png"),
	"trojan_shadow": preload("res://art/illustrations/Trojan_Shad.png"),
	"virus_shadow": preload("res://art/illustrations/Virus_Shad.png"),
	"worm_shadow": preload("res://art/illustrations/Worm_Shad.png"),
	"testing": preload("res://art/illustrations/testing_placeholder.png")
}

# Static access (recommended)
func get_portrait(key: String) -> Texture2D:
	if key == null or key == "":
		return null
	if PORTRAITS.has(key):
		return PORTRAITS[key] as Texture2D
	return null

func get_tutorial_image(key: String) -> Texture2D:
	if key == null or key == "":
		return null
	if TUTORIAL_IMAGES.has(key):
		return TUTORIAL_IMAGES[key] as Texture2D
	return null

# Instance access (useful if you add to Autoload)
func get_portrait_instance(key: String) -> Texture2D:
	return PortraitRegistry.get_portrait(key)

func get_tutorial_image_instance(key: String) -> Texture2D:
	return PortraitRegistry.get_tutorial_image(key)
