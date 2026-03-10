extends Control

const MAIN_MENU_PATH    := "res://scenes/ui/main_menu.tscn"
const CHAR_SELECTOR     := preload("res://scenes/ui/play_selector.tscn")

@onready var pause_menu: PauseMenu = $PauseMenu

@export var music: AudioStream


func _ready() -> void:
	# Wire up the pause menu's "Save & Exit" signal
	pause_menu.save_and_quit.connect(_save_and_return_to_menu)

	# Play hub music if assigned
	if music:
		MusicPlayer.play_music(music, true)

	# Guarantee a hub save exists so Continue is enabled on main menu
	_ensure_hub_save()


func _ensure_hub_save() -> void:
	var existing := SaveGame.load_data()
	if existing == null or not existing.was_in_hub:
		SaveGame.save_hub_state()


func _on_new_run_button_pressed() -> void:
	# Clear the hub save before entering a fresh run
	SaveGame.delete_data()
	MusicPlayer.stop()
	get_tree().change_scene_to_packed(CHAR_SELECTOR)


func _on_main_menu_button_pressed() -> void:
	# Keep the hub save so Continue still works
	SaveGame.save_hub_state()
	MusicPlayer.stop()
	StaticTransition.transition_to_file(MAIN_MENU_PATH)


# Called by the PauseMenu "Save & Exit" button
func _save_and_return_to_menu() -> void:
	SaveGame.save_hub_state()
	MusicPlayer.stop()
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
