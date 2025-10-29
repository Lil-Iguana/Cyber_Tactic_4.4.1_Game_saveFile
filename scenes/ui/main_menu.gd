extends Control

const CHAR_SELECTOR_SCENE := preload("res://scenes/ui/play_selector.tscn")
const RUN_SCENE = preload("res://scenes/run/run.tscn")

@onready var settings_menu: CanvasLayer = %SettingsMenu
@onready var continue_button: Button = %Continue

@export var run_startup: RunStartup
@export var music: AudioStream
@export var button_sfx: AudioStream


func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null
	MusicPlayer.play_music(music, true)

func _on_continue_pressed() -> void:
	run_startup.type = RunStartup.Type.CONTINUED_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)
	MusicPlayer.stop()
	SFXPlayer.play(button_sfx)

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
