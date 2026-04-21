extends Control

const CHAR_SELECTOR_SCENE := preload("res://scenes/ui/play_selector.tscn")
const RUN_SCENE = preload("res://scenes/run/run.tscn")
const HUB_SCENE = preload("res://scenes/hub/hub.tscn")

@onready var settings_menu: CanvasLayer = %SettingsMenu
@onready var continue_button: Button = %Continue
@onready var compendium_view: Control = %CompendiumView

@export var run_startup: RunStartup
@export var music: AudioStream
@export var button_sfx: AudioStream


func _ready() -> void:
	get_tree().paused = false
	continue_button.visible = SaveGame.load_data() != null
	MusicPlayer.play_track(MusicManager.Track.MAINMENU)
	
	# Hide compendium initially
	if compendium_view:
		compendium_view.hide()

func _on_continue_pressed() -> void:
	MusicPlayer.stop_music()
	SFXPlayer.play(button_sfx)
	
	var save := SaveGame.load_data()
	if save and save.was_in_hub:
		# Last save was in the Hub — return the player there
		get_tree().change_scene_to_packed(HUB_SCENE)
	else:
		# Last save was mid-run — resume the run
		run_startup.type = RunStartup.Type.CONTINUED_RUN
		get_tree().change_scene_to_packed(RUN_SCENE)

func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_packed(CHAR_SELECTOR_SCENE)
	SFXPlayer.play(button_sfx)

func _on_exit_pressed() -> void:
	get_tree().quit()
	SFXPlayer.play(button_sfx)

func _on_settings_pressed() -> void:
	settings_menu.show()
	SFXPlayer.play(button_sfx)

func _on_button_entered() -> void:
	SFXPlayer.play(button_sfx)

func _on_compendium_pressed() -> void:
	if compendium_view:
		compendium_view.show()
	SFXPlayer.play(button_sfx)
