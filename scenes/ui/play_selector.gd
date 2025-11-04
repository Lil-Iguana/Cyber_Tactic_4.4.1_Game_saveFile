extends Control

const MAIN_MENU_PATH = "res://scenes/ui/main_menu.tscn"
const INTRO_SCENE = preload("res://cutscene.tscn")
const ASSASSIN_STATS := preload("res://characters/assassin/assassin.tres")
const WARRIOR_STATS := preload("res://characters/warrior/warrior.tres")
const WIZARD_STATS := preload("res://characters/wizard/wizard.tres")

@export var run_startup: RunStartup

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPotrait
@onready var tutorial_check_box: CheckBox = %TutorialCheckBox
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
	# Before starting a new run decide tutorial flags based on the checkbutton
	if tutorial_check_box:
		# If checked => player wants tutorials => reset flags
		if tutorial_check_box.button_pressed:
			DialogueState.reset_all()
			DialogueState.complete_full_battle()
		else:
			# If unchecked => skip tutorials
			DialogueState.complete_all()
	else:
		# If the checkbutton isn't present for any reason, default to showing tutorials
		DialogueState.reset_all()
		DialogueState.complete_full_battle()

	CardLibrary.discovered_cards.clear()

	# --- New: reset the CodexManager state ---
	for entry in CodexManager.entries.values():
		entry.is_unlocked = false
	CodexManager.discovered_ids.clear()
	var save_res := SaveGame.load_data() if SaveGame.load_data() else SaveGame.new()
	save_res.codex_discovered.clear()
	save_res.save_data()
	# (Optional) Hide any currently open BestiaryView
	if has_node("/root/Run/CurrentView/BestiaryView"):
		get_node("/root/Run/CurrentView/BestiaryView").hide()

	print("Start new Run with %s" % current_character.character_name)

	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character

	# Manually load and instance the intro screen scene
	var intro_screen = INTRO_SCENE.instantiate()  # Pass selected character

	# Replace the current scene
	get_tree().root.add_child(intro_screen)     # Add to scene tree
	MusicPlayer.stop()
	get_tree().current_scene.queue_free()       # Remove current scene


func _on_student_button_pressed() -> void:
	current_character = WARRIOR_STATS


func _on_wizard_button_2_pressed() -> void:
	current_character = WIZARD_STATS


func _on_assassin_button_3_pressed() -> void:
	current_character = ASSASSIN_STATS


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
