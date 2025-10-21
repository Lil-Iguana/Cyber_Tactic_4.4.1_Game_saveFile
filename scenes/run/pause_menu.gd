class_name PauseMenu
extends CanvasLayer

signal save_and_quit

@onready var back_to_game_button: Button = %BackToGameButton
@onready var settings_button: Button = %SettingsButton
@onready var save_and_quit_button: Button = %SaveAndQuitButton
@onready var settings_menu: CanvasLayer = %SettingsMenu


func _ready() -> void:
	back_to_game_button.pressed.connect(_unpause)
	settings_button.pressed.connect(_on_settings_pressed)
	save_and_quit_button.pressed.connect(_on_save_and_quit_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# Don't toggle pause if settings menu is open
		if settings_menu.visible:
			return
			
		if visible:
			_unpause()
		else:
			_pause()
			
		get_viewport().set_input_as_handled()


func _pause() -> void:
	show()
	get_tree().paused = true


func _unpause() -> void:
	hide()
	settings_menu.hide()  # Also hide settings when unpausing
	get_tree().paused = false


func _on_settings_pressed() -> void:
	settings_menu.show()


func _on_save_and_quit_button_pressed() -> void:
	get_tree().paused = false
	save_and_quit.emit()
