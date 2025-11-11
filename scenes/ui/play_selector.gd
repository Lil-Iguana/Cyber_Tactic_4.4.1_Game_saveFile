extends Control

const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"
const INTRO_SCENE = preload("res://cutscene.tscn")
const RUN_SCENE = preload("res://scenes/run/run.tscn")
const ASSASSIN_STATS := preload("res://characters/assassin/assassin.tres")
const WARRIOR_STATS := preload("res://characters/warrior/warrior.tres")
const WIZARD_STATS := preload("res://characters/wizard/wizard.tres")

@export var run_startup: RunStartup

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPotrait
@onready var back_button: Button = %BackButton

var current_character: CharacterStats : set = set_current_character


func _ready() -> void:
	set_current_character(WARRIOR_STATS)


func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait.texture = current_character.portrait


func _on_start_button_pressed() -> void:
	MusicPlayer.stop()
	# Clear discovered cards for new run
	CardLibrary.discovered_cards.clear()

	print("Start new Run with %s" % current_character.character_name)

	# Set up run startup
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character

	# Load meta progression
	var meta = MetaProgression.load_meta()
	meta.increment_runs_started()

	# Check if this is the first time playing
	if not meta.has_seen_intro:
		# First time - show intro and mark as seen
		meta.mark_intro_seen()
		
		# Load and show intro scene
		var intro_screen = INTRO_SCENE.instantiate()
		get_tree().root.add_child(intro_screen)
		get_tree().current_scene.queue_free()
	else:
		# Not first time - go directly to run
		get_tree().change_scene_to_packed(RUN_SCENE)


func _on_student_button_pressed() -> void:
	current_character = WARRIOR_STATS


func _on_wizard_button_2_pressed() -> void:
	current_character = WIZARD_STATS


func _on_assassin_button_3_pressed() -> void:
	current_character = ASSASSIN_STATS


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
